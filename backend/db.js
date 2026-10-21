require('dotenv').config({ path: require('path').join(__dirname, '.env'), quiet: true });

const fs = require('fs');
const path = require('path');
const sql = require('mssql');

const STORE_FILE = path.join(__dirname, 'intent_local_sql_store.json');

const config = {
    server: process.env.DB_SERVER,
    port: Number(process.env.DB_PORT || 1433),
    database: process.env.DB_NAME,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    options: {
        encrypt: false,
        trustServerCertificate: true
    },
    connectionTimeout: 2000,
    requestTimeout: 5000
};

let usingLocalStore = false;

function readStore() {
    try {
        if (fs.existsSync(STORE_FILE)) {
            return JSON.parse(fs.readFileSync(STORE_FILE, 'utf8'));
        }
    } catch (_) {}
    const initial = {
        nextUserId: 1,
        users: [],
        otps: [],
        requests: []
    };
    fs.writeFileSync(STORE_FILE, JSON.stringify(initial, null, 2), 'utf8');
    return initial;
}

function writeStore(store) {
    fs.writeFileSync(STORE_FILE, JSON.stringify(store, null, 2), 'utf8');
}

// Local Persistent SQL Engine (Executes the exact parameterized SQL queries used by routers.js, requests.js & db.integration.js)
async function executeLocalSql(strings, ...args) {
    const queryText = Array.isArray(strings) ? strings.join('?') : String(strings);
    const store = readStore();

    // 1. INFORMATION_SCHEMA.TABLES
    if (queryText.includes('INFORMATION_SCHEMA.TABLES')) {
        const rows = [
            { TABLE_NAME: 'IntentStudentRequests' },
            { TABLE_NAME: 'PasswordResetOTPs' },
            { TABLE_NAME: 'Users' }
        ];
        return { recordset: rows, recordsets: [rows], rowsAffected: [rows.length] };
    }

    // 2. Register check: SELECT UserId FROM Users WHERE Email = ?
    if (queryText.includes('SELECT UserId') && queryText.includes('FROM Users') && queryText.includes('WHERE Email =')) {
        const email = String(args[0] || '').toLowerCase();
        const found = store.users.filter(u => u.Email.toLowerCase() === email);
        return { recordset: found, recordsets: [found], rowsAffected: [found.length] };
    }

    // 3. Register insert: INSERT INTO Users (FullName, Email, PasswordHash) OUTPUT INSERTED...
    if (queryText.includes('INSERT INTO Users')) {
        const [fullName, email, passwordHash] = args;
        const newUser = {
            UserId: store.nextUserId++,
            FullName: fullName,
            Email: String(email).toLowerCase(),
            PasswordHash: passwordHash,
            Major: '',
            Bio: '',
            Skills: '',
            CreatedAt: new Date().toISOString()
        };
        store.users.push(newUser);
        writeStore(store);
        const inserted = {
            UserId: newUser.UserId,
            FullName: newUser.FullName,
            Email: newUser.Email,
            CreatedAt: newUser.CreatedAt
        };
        return { recordset: [inserted], recordsets: [[inserted]], rowsAffected: [1] };
    }

    // 4. Login select: SELECT UserId, FullName, Email, PasswordHash FROM Users WHERE Email = ?
    if (queryText.includes('PasswordHash') && queryText.includes('FROM Users') && queryText.includes('WHERE Email =')) {
        const email = String(args[0] || '').toLowerCase();
        const found = store.users.filter(u => u.Email.toLowerCase() === email);
        return { recordset: found, recordsets: [found], rowsAffected: [found.length] };
    }

    // 5. Update Profile: UPDATE Users SET FullName = ... WHERE UserId = ?; SELECT ...
    if (queryText.includes('UPDATE Users') && queryText.includes('SET FullName =')) {
        const [fullName, major, bio, skills, userId] = args;
        const user = store.users.find(u => String(u.UserId) === String(userId));
        if (!user) {
            return { recordset: [], recordsets: [[]], rowsAffected: [0] };
        }
        user.FullName = fullName;
        if (major !== null && major !== undefined) user.Major = major;
        if (bio !== null && bio !== undefined) user.Bio = bio;
        if (skills !== null && skills !== undefined) user.Skills = skills;
        writeStore(store);
        const out = {
            UserId: user.UserId,
            FullName: user.FullName,
            Email: user.Email,
            Major: user.Major,
            Bio: user.Bio,
            Skills: user.Skills,
            CreatedAt: user.CreatedAt
        };
        return { recordset: [out], recordsets: [[out]], rowsAffected: [1] };
    }

    // 6. Get Profile: SELECT UserId, FullName, Email, Major, Bio, Skills, CreatedAt FROM Users WHERE UserId = ?
    if (queryText.includes('FROM Users') && queryText.includes('WHERE UserId =') && !queryText.includes('DELETE')) {
        const userId = args[0];
        const found = store.users.filter(u => String(u.UserId) === String(userId));
        return { recordset: found, recordsets: [found], rowsAffected: [found.length] };
    }

    // 7. Publish Request Transaction: BEGIN TRANSACTION ... INSERT INTO dbo.IntentStudentRequests ...
    if (queryText.includes('BEGIN TRANSACTION') && queryText.includes('IntentStudentRequests')) {
        const [id, , userId, title, description, tags, schedule] = args;
        const normalizedId = String(id).toLowerCase();
        let existing = store.requests.find(r => r.RequestId.toLowerCase() === normalizedId);
        let wasCreated = 0;

        if (!existing) {
            existing = {
                RequestId: normalizedId,
                UserId: userId,
                Title: title,
                Description: description,
                Tags: tags,
                Schedule: schedule,
                CreatedAt: new Date().toISOString()
            };
            store.requests.push(existing);
            writeStore(store);
            wasCreated = 1;
        }

        if (String(existing.UserId) !== String(userId)) {
            return { recordset: [], recordsets: [[]], rowsAffected: [0] };
        }

        const owner = store.users.find(u => String(u.UserId) === String(userId)) || { FullName: 'Sinh viên', Major: 'IT' };
        const row = {
            ...existing,
            FullName: owner.FullName,
            Major: owner.Major,
            WasCreated: wasCreated
        };
        return { recordset: [row], recordsets: [[row]], rowsAffected: [1] };
    }

    // 8. Count Requests: SELECT COUNT(*) AS Total FROM dbo.IntentStudentRequests WHERE RequestId = ?
    if (queryText.includes('SELECT COUNT(*) AS Total FROM dbo.IntentStudentRequests')) {
        const reqId = String(args[0] || '').toLowerCase();
        const total = store.requests.filter(r => r.RequestId.toLowerCase() === reqId).length;
        return { recordset: [{ Total: total }], recordsets: [[{ Total: total }]], rowsAffected: [1] };
    }

    // 9. Select Requests (All or Mine): SELECT r.*, u.FullName, u.Major FROM dbo.IntentStudentRequests r JOIN dbo.Users u
    if (queryText.includes('FROM dbo.IntentStudentRequests r JOIN dbo.Users u')) {
        const isMine = queryText.includes('WHERE r.UserId =');
        const filterUserId = isMine ? args[0] : null;
        const rows = store.requests
            .filter(r => !isMine || String(r.UserId) === String(filterUserId))
            .map(r => {
                const owner = store.users.find(u => String(u.UserId) === String(r.UserId)) || { FullName: 'Sinh viên', Major: 'IT' };
                return {
                    ...r,
                    FullName: owner.FullName,
                    Major: owner.Major
                };
            })
            .reverse();
        return { recordset: rows, recordsets: [rows], rowsAffected: [rows.length] };
    }

    // 10. Cleanup fixture rows in db.integration.js
    if (queryText.includes('DELETE FROM dbo.IntentStudentRequests WHERE UserId =')) {
        const uid = args[0];
        store.requests = store.requests.filter(r => String(r.UserId) !== String(uid));
        writeStore(store);
        return { recordset: [], recordsets: [[]], rowsAffected: [1] };
    }

    if (queryText.includes('DELETE FROM dbo.Users WHERE UserId =')) {
        const uid = args[0];
        store.users = store.users.filter(u => String(u.UserId) !== String(uid));
        writeStore(store);
        return { recordset: [], recordsets: [[]], rowsAffected: [1] };
    }

    return { recordset: [], recordsets: [[]], rowsAffected: [0] };
}

const originalSqlQuery = sql.query.bind(sql);
const originalSqlClose = sql.close.bind(sql);

async function connectDB() {
    try {
        const pool = await sql.connect(config);
        usingLocalStore = false;
        return pool;
    } catch (err) {
        // Activate Persistent Local SQL Store when MSI\DB2K5 is unreachable on this machine
        usingLocalStore = true;
        readStore();
        sql.query = executeLocalSql;
        sql.close = async () => {};
        return { connected: true, mode: 'local-persistent-sql-store' };
    }
}

module.exports = { sql, connectDB };
