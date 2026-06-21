-- Phase 3: admin profiles + audit logs
IF COL_LENGTH('dbo.users', 'admin_profile') IS NULL
BEGIN
    ALTER TABLE dbo.users
    ADD admin_profile NVARCHAR(30) NULL;
END
GO

UPDATE dbo.users
SET admin_profile = N'FULL'
WHERE role = N'ADMIN' AND admin_profile IS NULL;
GO

IF OBJECT_ID(N'dbo.audit_logs', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.audit_logs (
        id BIGINT IDENTITY(1,1) NOT NULL,
        actor_email NVARCHAR(180) NOT NULL,
        action NVARCHAR(80) NOT NULL,
        entity_type NVARCHAR(80) NOT NULL,
        entity_id NVARCHAR(80) NULL,
        details NVARCHAR(1000) NULL,
        created_at DATETIME2(0) NOT NULL CONSTRAINT df_audit_logs_created_at DEFAULT GETDATE(),
        CONSTRAINT pk_audit_logs PRIMARY KEY (id)
    );

    CREATE INDEX ix_audit_logs_created_at ON dbo.audit_logs(created_at DESC, id DESC);
END
GO
