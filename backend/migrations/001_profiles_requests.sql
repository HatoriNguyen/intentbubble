-- Additive and repeatable. Run against the existing database configured in .env.
SET XACT_ABORT ON;
BEGIN TRANSACTION;
IF OBJECT_ID(N'dbo.Users', N'U') IS NULL
    THROW 50001, 'Expected existing dbo.Users table. No database was created.', 1;

-- An existing intent store must be mapped before any parallel store is created.
-- The supplied SSMS screenshot confirms this table exists on MSI\DB2K5.
IF OBJECT_ID(N'dbo.Intents', N'U') IS NOT NULL
   AND OBJECT_ID(N'dbo.IntentStudentRequests', N'U') IS NULL
    THROW 50003, 'Existing dbo.Intents detected. Inspect its schema and map request persistence before migrating.', 1;

IF COL_LENGTH('dbo.Users', 'Major') IS NULL
    ALTER TABLE dbo.Users ADD Major nvarchar(255) NULL;
IF COL_LENGTH('dbo.Users', 'Bio') IS NULL
    ALTER TABLE dbo.Users ADD Bio nvarchar(2000) NULL;
IF COL_LENGTH('dbo.Users', 'Skills') IS NULL
    ALTER TABLE dbo.Users ADD Skills nvarchar(2000) NULL;

IF OBJECT_ID(N'dbo.IntentStudentRequests', N'U') IS NULL
BEGIN
    -- Inherit the real Users.UserId type instead of assuming int or UUID.
    DECLARE @userType nvarchar(128);
    SELECT @userType = CASE
        WHEN t.name IN ('int', 'bigint', 'uniqueidentifier') THEN t.name
        WHEN t.name IN ('varchar', 'nvarchar') AND c.max_length > 0 THEN
            t.name + '(' + CAST(CASE WHEN t.name = 'nvarchar' THEN c.max_length / 2
                                    ELSE c.max_length END AS varchar(10)) + ')'
        END
    FROM sys.columns c JOIN sys.types t ON c.user_type_id = t.user_type_id
    WHERE c.object_id = OBJECT_ID(N'dbo.Users') AND c.name = 'UserId';
    IF @userType IS NULL
        THROW 50002, 'Unsupported Users.UserId type; inspect schema before migrating.', 1;

    DECLARE @ddl nvarchar(max) = N'CREATE TABLE dbo.IntentStudentRequests (
        RequestId uniqueidentifier NOT NULL PRIMARY KEY,
        UserId ' + @userType + N' NOT NULL,
        Title nvarchar(200) NOT NULL,
        Description nvarchar(4000) NOT NULL,
        Tags nvarchar(max) NOT NULL CHECK (ISJSON(Tags) = 1),
        Schedule nvarchar(200) NOT NULL,
        CreatedAt datetime2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_IntentStudentRequests_Users FOREIGN KEY (UserId)
            REFERENCES dbo.Users(UserId)
    );
    CREATE INDEX IX_IntentStudentRequests_User_Created
        ON dbo.IntentStudentRequests(UserId, CreatedAt DESC);';
    EXEC sys.sp_executesql @ddl;
END;
COMMIT TRANSACTION;
