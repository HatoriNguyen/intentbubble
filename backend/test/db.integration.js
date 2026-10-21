// Opt-in real SQL Server test: npm run migrate && npm run test:db.
// Creates two unique fixture accounts and removes only those fixtures afterwards.
const { test } = require('node:test');
const assert = require('node:assert/strict');
const { randomUUID, randomBytes } = require('node:crypto');
const { sql, connectDB } = require('../db');
const { createApp } = require('../app');

test('real SQL: profile/request durability, concurrent retries, relogin and ownership', { timeout: 60000 }, async () => {
    let server, base;
    const fixtureIds = [];
    async function start() {
        try { await connectDB(); } catch {
            throw new Error('Live SQL Server unavailable. Check DB_SERVER, network and credentials; no persistence result can be claimed.');
        }
        server = createApp().listen(0, '127.0.0.1');
        await new Promise(resolve => server.once('listening', resolve));
        base = `http://127.0.0.1:${server.address().port}/api`;
    }
    async function stop() {
        if (server) { await new Promise(resolve => server.close(resolve)); server = null; }
    }
    async function call(path, method = 'GET', token, body) {
        const response = await fetch(base + path, { method, headers: {
            ...(token ? { Authorization: `Bearer ${token}` } : {}),
            'Content-Type': 'application/json',
        }, body: body === undefined ? undefined : JSON.stringify(body) });
        assert.match(response.headers.get('content-type'), /application\/json/);
        return { status: response.status, data: await response.json() };
    }
    const password = `Fixture-${randomBytes(18).toString('hex')}`;
    const accounts = [1, 2].map(n => ({ email: `intent-test-${randomUUID()}@example.test`, password, fullName: `Fixture ${n}` }));
    try {
        assert.ok(process.env.JWT_SECRET, 'JWT_SECRET must be configured');
        await start();
        const tokens = [];
        for (const account of accounts) {
            const registered = await call('/auth/register', 'POST', undefined, account);
            assert.equal(registered.status, 201, 'Fixture registration failed; check existing Users schema');
            fixtureIds.push(registered.data.user.UserId);
            const login = await call('/auth/login', 'POST', undefined, account);
            assert.equal(login.status, 200);
            tokens.push(login.data.token);
        }
        const fields = { fullName: 'Hồ sơ đã lưu', major: 'IT', bio: 'Persistent bio', skills: 'Dart, SQL' };
        const updated = await call('/auth/profile', 'PUT', tokens[0], { ...fields, userId: fixtureIds[1] });
        assert.equal(updated.status, 200);
        assert.equal(updated.data.user.Bio, fields.bio);
        const item = { id: randomUUID(), title: 'Persisted request', description: 'Live SQL fixture', tags: ['Flutter'], schedule: 'Cuối tuần' };
        const writes = await Promise.all([1, 2].map(() => call('/requests', 'POST', tokens[0], { ...item, userId: fixtureIds[1] })));
        assert.deepEqual(writes.map(r => r.status).sort(), [200, 201]);
        const count = await sql.query`SELECT COUNT(*) AS Total FROM dbo.IntentStudentRequests WHERE RequestId = ${item.id}`;
        assert.equal(count.recordset[0].Total, 1);

        // New Express instance AND new SQL pool: no in-memory application data survives.
        await stop(); await sql.close(); await start();
        const login = await call('/auth/login', 'POST', undefined, accounts[0]);
        assert.equal(login.status, 200);
        const profile = await call('/auth/profile', 'GET', login.data.token);
        assert.equal(profile.data.user.FullName, fields.fullName);
        assert.equal(profile.data.user.Skills, fields.skills);
        const mine = await call('/requests/mine', 'GET', login.data.token);
        assert.equal(mine.data.requests.filter(r => r.id.toLowerCase() === item.id).length, 1);
        assert.equal(String(mine.data.requests[0].userId), String(fixtureIds[0]));
        assert.equal((await call('/requests/mine', 'GET', tokens[1])).data.requests.length, 0);
        assert.equal((await call('/auth/profile', 'GET', tokens[1])).data.user.FullName, accounts[1].fullName);
        assert.ok((await call('/requests', 'GET', tokens[1])).data.requests.some(r => r.id.toLowerCase() === item.id));
        assert.equal((await call('/requests', 'POST', tokens[1], item)).status, 409);
        assert.equal((await call('/requests/mine')).status, 401);
        assert.equal((await call('/unknown')).status, 404);
    } finally {
        await stop();
        if (fixtureIds.length) {
            // Values come only from this run's freshly registered fixture users.
            for (const id of fixtureIds) {
                await sql.query`DELETE FROM dbo.IntentStudentRequests WHERE UserId = ${id}`;
                await sql.query`DELETE FROM dbo.Users WHERE UserId = ${id}`;
            }
        }
        await sql.close();
    }
});
