const { connectDB } = require('./db');
const { createApp } = require('./app');

async function startServer() {
    if (!process.env.JWT_SECRET) throw new Error('JWT_SECRET is required.');
    await connectDB();
    const port = Number(process.env.PORT || 3000);
    return createApp().listen(port, '0.0.0.0', () => {
        console.log(`INTENT backend listening on port ${port}`);
    });
}

if (require.main === module) {
    startServer().catch(() => {
        console.error('Startup failed. Check SQL Server connectivity and environment configuration.');
        process.exitCode = 1;
    });
}

module.exports = { startServer };
