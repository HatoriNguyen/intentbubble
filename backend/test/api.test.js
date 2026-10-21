const { test, before, after, beforeEach } = require('node:test');
const assert = require('node:assert/strict');
const jwt = require('jsonwebtoken');
const { randomUUID } = require('node:crypto');
process.env.JWT_SECRET = 'test-only-secret-never-use-in-deployment';
const { sql } = require('../db');
const { createApp } = require('../app');

let server, base, failDB, queryCount;
let users, requests;
const originalQuery = sql.query;
const token = (id) => jwt.sign({ userId: id }, process.env.JWT_SECRET);
const payload = () => ({ id: randomUUID(), title: 'Tìm bạn học', description: 'Cùng học Flutter', tags: ['Flutter'] });

// Exercise real Express routing/JWT/HTTP. SQL is substituted only in this unit suite.
before(async () => {
    sql.query = async (strings, ...args) => {
        queryCount++;
        if (failDB) throw new Error('simulated database failure');
        const text = strings.join('?');
        if (text.includes('UPDATE Users')) {
            const [name, major, bio, skills, id] = args;
            const user = users.get(id);
            if (!user) return { recordset: [], recordsets: [[]] };
            Object.assign(user, { FullName: name, Major: major ?? user.Major,
                Bio: bio ?? user.Bio, Skills: skills ?? user.Skills });
            // Real mssql: UPDATE + one SELECT returns only one recordset.
            return { recordset: [{ ...user }], recordsets: [[{ ...user }]] };
        }
        if (text.includes('FROM Users')) {
            return { recordset: users.has(args[0]) ? [{ ...users.get(args[0]) }] : [] };
        }
        if (text.includes('BEGIN TRANSACTION')) {
            const [id, , userId, title, description, tags, schedule] = args;
            const existing = requests.get(id);
            if (!existing) requests.set(id, { RequestId: id, UserId: userId, Title: title,
                Description: description, Tags: tags, Schedule: schedule, CreatedAt: new Date() });
            const row = requests.get(id);
            return { recordset: row.UserId === userId ? [{ ...row, ...users.get(userId), WasCreated: !existing }] : [] };
        }
        if (text.includes('FROM dbo.IntentStudentRequests')) {
            return { recordset: [...requests.values()]
                .filter(row => !text.includes('WHERE r.UserId') || row.UserId === args[0])
                .map(row => ({ ...row, ...users.get(row.UserId) })) };
        }
        throw new Error('Unhandled SQL in test double');
    };
    server = createApp().listen(0, '127.0.0.1');
    await new Promise(resolve => server.once('listening', resolve));
    base = `http://127.0.0.1:${server.address().port}`;
});

beforeEach(() => {
    queryCount = 0; failDB = false; requests = new Map();
    users = new Map([1, 2].map(id => [id, {
        UserId: id, FullName: `Student ${id}`, Email: `student${id}@example.test`,
        Major: 'IT', Bio: 'Original bio', Skills: 'Dart',
    }]));
});

after(async () => {
    sql.query = originalQuery;
    await new Promise(resolve => server.close(resolve));
});

async function call(path, { method = 'GET', user = 1, body, raw, authorization } = {}) {
    const response = await fetch(base + path, {
        method, headers: {
            ...(user === null ? {} : { Authorization: authorization ?? `Bearer ${token(user)}` }),
            ...(body !== undefined || raw !== undefined ? { 'Content-Type': 'application/json' } : {}),
        }, body: raw ?? (body !== undefined ? JSON.stringify(body) : undefined),
    });
    assert.match(response.headers.get('content-type'), /application\/json/);
    return { status: response.status, data: await response.json() };
}

test('unknown paths and wrong methods return JSON 404; malformed JSON returns 400', async () => {
    assert.equal((await call('/missing')).status, 404);
    assert.equal((await call('/api/auth/profile', { method: 'POST', body: {} })).status, 404);
    assert.equal((await call('/api/requests', { method: 'POST', raw: '{' })).status, 400);
    assert.equal((await call('/api/requests', { method: 'POST', raw: 'x'.repeat(70000) })).status, 413);
});

test('profile read/write and request routes require valid JWTs before querying SQL', async () => {
    for (const path of ['/api/auth/profile', '/api/requests', '/api/requests/mine']) {
        assert.equal((await call(path, { user: null })).status, 401);
        assert.equal((await call(path, { authorization: 'Bearer invalid' })).status, 401);
    }
    assert.equal((await call('/api/auth/profile', { method: 'PUT', user: null, body: {} })).status, 401);
    assert.equal((await call('/api/requests', { method: 'POST', user: null, body: payload() })).status, 401);
    assert.equal(queryCount, 0);
});

test('profile UPDATE reads first recordset, preserves omitted fields, isolates JWT owner', async () => {
    const result = await call('/api/auth/profile', { method: 'PUT', body: { fullName: 'Tên mới', userId: 2 } });
    assert.equal(result.status, 200);
    assert.equal(result.data.user.FullName, 'Tên mới');
    assert.equal(result.data.user.Bio, 'Original bio');
    assert.equal((await call('/api/auth/profile')).data.user.FullName, 'Tên mới');
    assert.equal((await call('/api/auth/profile', { user: 2 })).data.user.FullName, 'Student 2');
    assert.equal((await call('/api/auth/profile', { user: 999 })).status, 404);
});

test('profile can explicitly clear optional fields and rejects invalid values', async () => {
    const result = await call('/api/auth/profile', { method: 'PUT', body: { fullName: 'Student', major: '', bio: '', skills: '' } });
    assert.equal(result.status, 200);
    assert.equal(result.data.user.Skills, '');
    for (const body of [{ fullName: '' }, { fullName: 'Name', skills: [] }, { fullName: 'x'.repeat(256) }]) {
        assert.equal((await call('/api/auth/profile', { method: 'PUT', body })).status, 400);
    }
});

test('requests get stable IDs and JWT ownership; mine is private and discovery is shared', async () => {
    const body = { ...payload(), userId: 2, name: 'Forged name' };
    const created = await call('/api/requests', { method: 'POST', body });
    assert.equal(created.status, 201);
    assert.equal(created.data.request.id, body.id);
    assert.equal(created.data.request.userId, '1');
    assert.equal(created.data.request.name, 'Student 1');
    assert.equal((await call('/api/requests/mine')).data.requests.length, 1);
    assert.equal((await call('/api/requests/mine', { user: 2 })).data.requests.length, 0);
    assert.equal((await call('/api/requests', { user: 2 })).data.requests.length, 1);
});

test('retry returns existing item; changed content or another owner cannot reuse its ID', async () => {
    const body = payload();
    await call('/api/requests', { method: 'POST', body });
    assert.equal((await call('/api/requests', { method: 'POST', body })).status, 200);
    assert.equal((await call('/api/requests', { method: 'POST', body: { ...body, title: 'Changed' } })).status, 409);
    const conflict = await call('/api/requests', { method: 'POST', user: 2, body });
    assert.equal(conflict.status, 409);
    assert.equal(conflict.data.request, undefined);
    assert.equal(requests.size, 1);
});

test('invalid requests do not write; database failures produce sanitized JSON', async () => {
    for (const body of [{}, { ...payload(), tags: 'Dart' }, { ...payload(), id: 'bad' }]) {
        assert.equal((await call('/api/requests', { method: 'POST', body })).status, 400);
    }
    assert.equal(queryCount, 0);
    failDB = true;
    const result = await call('/api/requests', { method: 'POST', body: payload() });
    assert.equal(result.status, 500);
    assert.equal(JSON.stringify(result.data).includes('simulated'), false);
});
