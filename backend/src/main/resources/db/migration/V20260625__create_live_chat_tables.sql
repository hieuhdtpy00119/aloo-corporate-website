-- Managed live-chat schema. This migration is intentionally additive and
-- idempotent so baselining an existing installation cannot remove chat data.

IF OBJECT_ID(N'dbo.chat_sessions', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.chat_sessions (
        id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        session_token NVARCHAR(64) NOT NULL,
        visitor_name NVARCHAR(180) NOT NULL,
        visitor_phone NVARCHAR(40) NOT NULL,
        status NVARCHAR(20) NOT NULL CONSTRAINT DF_chat_sessions_status DEFAULT N'OPEN',
        assigned_admin_id BIGINT NULL,
        last_message_at DATETIME2 NULL,
        created_at DATETIME2 NOT NULL,
        updated_at DATETIME2 NOT NULL,
        CONSTRAINT UQ_chat_sessions_token UNIQUE (session_token)
    );
END;

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_chat_sessions_status_updated'
      AND object_id = OBJECT_ID(N'dbo.chat_sessions')
)
    CREATE INDEX IX_chat_sessions_status_updated ON dbo.chat_sessions (status, updated_at DESC);

IF OBJECT_ID(N'dbo.chat_messages', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.chat_messages (
        id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        session_id BIGINT NOT NULL,
        sender_type NVARCHAR(20) NOT NULL,
        sender_admin_id BIGINT NULL,
        body NVARCHAR(MAX) NOT NULL,
        read_at DATETIME2 NULL,
        created_at DATETIME2 NOT NULL,
        CONSTRAINT FK_chat_messages_session FOREIGN KEY (session_id) REFERENCES dbo.chat_sessions(id) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_chat_messages_session_created'
      AND object_id = OBJECT_ID(N'dbo.chat_messages')
)
    CREATE INDEX IX_chat_messages_session_created ON dbo.chat_messages (session_id, created_at ASC);
