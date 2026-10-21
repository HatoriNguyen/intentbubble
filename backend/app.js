const express = require('express');
const cors = require('cors');
const { sql } = require('./db');

function createApp() {
    const app = express();
    app.use(cors());
    app.use(express.json({ limit: '64kb' }));
    app.use('/api/auth', require('./routers'));
    app.use('/api/requests', require('./routes/requests'));
    app.get('/api/health', (req, res) => {
        res.json({ success: true, message: 'INTENT Backend is running' });
    });
    app.get('/api/db-test', require('./middleware/authMiddleware'), async (req, res) => {
        const result = await sql.query`
            SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
            WHERE TABLE_TYPE = 'BASE TABLE' ORDER BY TABLE_NAME
        `;
        res.json({ success: true, tables: result.recordset });
    });
    // No HTML fallback, including unknown methods and malformed JSON bodies.
    app.use((req, res) => {
        res.status(404).json({ success: false, message: 'API route not found.' });
    });
    app.use((error, req, res, next) => {
        if (res.headersSent) return next(error);
        const status = error.type === 'entity.parse.failed' ? 400 :
            error.type === 'entity.too.large' ? 413 : 500;
        res.status(status).json({
            success: false,
            message: status === 400 ? 'Invalid JSON request body.' :
                status === 413 ? 'Request body is too large.' : 'Unable to process the request.'
        });
    });
    return app;
}

module.exports = { createApp };
