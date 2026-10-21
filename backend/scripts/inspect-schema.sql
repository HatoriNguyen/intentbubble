-- Read-only diagnostics. Run in SSMS connected to the existing MSI\DB2K5 instance.
-- Outputs metadata only: no account records, passwords, password hashes or tokens.
USE [INTENT_DB];
GO

SELECT
    CAST(SERVERPROPERTY('MachineName') AS nvarchar(128)) AS MachineName,
    CAST(SERVERPROPERTY('InstanceName') AS nvarchar(128)) AS InstanceName,
    DB_NAME() AS DatabaseName,
    CONNECTIONPROPERTY('net_transport') AS CurrentTransport,
    CONNECTIONPROPERTY('local_net_address') AS CurrentServerAddress,
    CONNECTIONPROPERTY('local_tcp_port') AS CurrentTcpPort;

SELECT
    s.name AS SchemaName, t.name AS TableName,
    c.column_id AS ColumnOrder, c.name AS ColumnName, ty.name AS DataType,
    c.max_length AS MaxLengthBytes, c.is_nullable AS IsNullable,
    c.is_identity AS IsIdentity, dc.definition AS DefaultDefinition
FROM sys.tables t
JOIN sys.schemas s ON s.schema_id = t.schema_id
JOIN sys.columns c ON c.object_id = t.object_id
JOIN sys.types ty ON ty.user_type_id = c.user_type_id
LEFT JOIN sys.default_constraints dc ON dc.object_id = c.default_object_id
WHERE s.name = 'dbo' AND t.name IN ('Intents', 'Users', 'IntentStudentRequests')
ORDER BY t.name, c.column_id;

SELECT
    OBJECT_SCHEMA_NAME(i.object_id) AS SchemaName,
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName, i.is_primary_key AS IsPrimaryKey,
    i.is_unique AS IsUnique, c.name AS ColumnName,
    ic.key_ordinal AS KeyOrder, i.filter_definition AS FilterDefinition
FROM sys.indexes i
JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id
JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
WHERE i.object_id IN (OBJECT_ID('dbo.Intents'), OBJECT_ID('dbo.Users'))
ORDER BY TableName, IndexName, ic.key_ordinal;

SELECT
    fk.name AS ForeignKeyName,
    OBJECT_NAME(fk.parent_object_id) AS TableName,
    pc.name AS ColumnName,
    OBJECT_NAME(fk.referenced_object_id) AS ReferencedTable,
    rc.name AS ReferencedColumn
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fkc ON fkc.constraint_object_id = fk.object_id
JOIN sys.columns pc ON pc.object_id = fkc.parent_object_id AND pc.column_id = fkc.parent_column_id
JOIN sys.columns rc ON rc.object_id = fkc.referenced_object_id AND rc.column_id = fkc.referenced_column_id
WHERE fk.parent_object_id = OBJECT_ID('dbo.Intents');

SELECT name AS CheckConstraintName, definition AS CheckDefinition
FROM sys.check_constraints
WHERE parent_object_id = OBJECT_ID('dbo.Intents');
