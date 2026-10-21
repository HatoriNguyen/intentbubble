const express = require('express');
const { sql } = require('../db');
const auth = require('../middleware/authMiddleware');
const router = express.Router();
router.use(auth);

function serialize(row) {
    return {
        id: row.RequestId, userId: String(row.UserId), name: row.FullName,
        major: row.Major || 'Sinh viên', title: row.Title,
        description: row.Description, tags: JSON.parse(row.Tags),
        schedule: row.Schedule, createdAt: row.CreatedAt, match: 100
    };
}

// Published requests are visible to all authenticated students, as in Discover.
router.get('/', async (req, res) => {
    const result = await sql.query`
        SELECT r.*, u.FullName, u.Major
        FROM dbo.IntentStudentRequests r JOIN dbo.Users u ON u.UserId = r.UserId
        ORDER BY r.CreatedAt DESC, r.RequestId DESC
    `;
    res.json({ success: true, requests: result.recordset.map(serialize) });
});

router.get('/mine', async (req, res) => {
    const result = await sql.query`
        SELECT r.*, u.FullName, u.Major
        FROM dbo.IntentStudentRequests r JOIN dbo.Users u ON u.UserId = r.UserId
        WHERE r.UserId = ${req.user.userId}
        ORDER BY r.CreatedAt DESC, r.RequestId DESC
    `;
    res.json({ success: true, requests: result.recordset.map(serialize) });
});

router.post('/', async (req, res) => {
    const { id, title, description, tags, schedule = 'Chưa cập nhật lịch' } = req.body || {};
    if (typeof id !== 'string' || !/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(id) ||
        typeof title !== 'string' || !title.trim() || title.trim().length > 200 ||
        typeof description !== 'string' || !description.trim() || description.trim().length > 4000 ||
        !Array.isArray(tags) || tags.length > 30 ||
        tags.some(tag => typeof tag !== 'string' || !tag.trim() || tag.length > 100) ||
        typeof schedule !== 'string' || schedule.length > 200) {
        return res.status(400).json({ success: false, message: 'Invalid request fields or request ID.' });
    }
    const normalizedTags = JSON.stringify(tags.map(tag => tag.trim()));
    // The key range lock and PK make retries atomic, including concurrent clients.
    const result = await sql.query`
        SET XACT_ABORT ON;
        BEGIN TRANSACTION;
        DECLARE @created bit = 0;
        IF NOT EXISTS (SELECT 1 FROM dbo.IntentStudentRequests WITH (UPDLOCK, HOLDLOCK)
                       WHERE RequestId = ${id})
        BEGIN
            INSERT INTO dbo.IntentStudentRequests
                (RequestId, UserId, Title, Description, Tags, Schedule)
            VALUES (${id}, ${req.user.userId}, ${title.trim()}, ${description.trim()},
                    ${normalizedTags}, ${schedule});
            SET @created = 1;
        END;
        SELECT r.*, u.FullName, u.Major, @created AS WasCreated
        FROM dbo.IntentStudentRequests r JOIN dbo.Users u ON u.UserId = r.UserId
        WHERE r.RequestId = ${id} AND r.UserId = ${req.user.userId};
        COMMIT TRANSACTION;
    `;
    const row = result.recordset[0];
    if (!row || row.Title !== title.trim() || row.Description !== description.trim() ||
        row.Tags !== normalizedTags || row.Schedule !== schedule) {
        return res.status(409).json({ success: false, message: 'Request ID is already in use. Keep the original content when retrying.' });
    }
    res.status(row.WasCreated ? 201 : 200).json({ success: true, request: serialize(row) });
});

module.exports = router;
