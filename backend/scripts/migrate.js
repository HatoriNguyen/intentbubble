const fs = require('node:fs');
const path = require('node:path');
const { sql, connectDB } = require('../db');

async function migrate() {
    try {
        const pool = await connectDB();
        const text = fs.readFileSync(path.join(__dirname, '../migrations/001_profiles_requests.sql'), 'utf8');
        await pool.request().batch(text);
        console.log('Profile/request migration completed. Existing rows were preserved.');
    } catch {
        console.error('Migration failed. Check SQL Server access, dbo.Users schema and DDL permissions.');
        process.exitCode = 1;
    } finally {
        await sql.close();
    }
}

migrate();
