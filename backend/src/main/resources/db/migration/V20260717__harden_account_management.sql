-- Account lifecycle, session revocation and role history. Additive migration;
-- existing accounts remain ACTIVE and keep security version 0.

IF COL_LENGTH('dbo.users', 'record_version') IS NULL
    ALTER TABLE dbo.users ADD record_version BIGINT NOT NULL CONSTRAINT df_users_record_version DEFAULT 0;

IF COL_LENGTH('dbo.users', 'security_version') IS NULL
    ALTER TABLE dbo.users ADD security_version BIGINT NOT NULL CONSTRAINT df_users_security_version DEFAULT 0;

IF COL_LENGTH('dbo.users', 'status_reason') IS NULL
    ALTER TABLE dbo.users ADD status_reason NVARCHAR(500) NULL;

IF COL_LENGTH('dbo.users', 'invited_at') IS NULL
    ALTER TABLE dbo.users ADD invited_at DATETIME2(0) NULL;

IF COL_LENGTH('dbo.users', 'invitation_accepted_at') IS NULL
    ALTER TABLE dbo.users ADD invitation_accepted_at DATETIME2(0) NULL;

IF COL_LENGTH('dbo.users', 'deactivated_at') IS NULL
    ALTER TABLE dbo.users ADD deactivated_at DATETIME2(0) NULL;

IF COL_LENGTH('dbo.users', 'deactivated_by') IS NULL
    ALTER TABLE dbo.users ADD deactivated_by NVARCHAR(180) NULL;

IF COL_LENGTH('dbo.users', 'role_changed_at') IS NULL
    ALTER TABLE dbo.users ADD role_changed_at DATETIME2(0) NULL;

IF COL_LENGTH('dbo.users', 'role_changed_by') IS NULL
    ALTER TABLE dbo.users ADD role_changed_by NVARCHAR(180) NULL;

IF EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = N'ck_users_status' AND parent_object_id = OBJECT_ID(N'dbo.users')
)
    ALTER TABLE dbo.users DROP CONSTRAINT ck_users_status;

UPDATE dbo.users SET status = N'SUSPENDED' WHERE status = N'INACTIVE';

IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = N'ck_users_status' AND parent_object_id = OBJECT_ID(N'dbo.users')
)
    ALTER TABLE dbo.users ADD CONSTRAINT ck_users_status
        CHECK (status IN (N'INVITED', N'ACTIVE', N'SUSPENDED', N'LOCKED', N'DEACTIVATED'));

IF OBJECT_ID(N'dbo.account_role_history', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.account_role_history (
        id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        user_id BIGINT NOT NULL,
        from_role NVARCHAR(30) NOT NULL,
        to_role NVARCHAR(30) NOT NULL,
        from_admin_profile NVARCHAR(30) NULL,
        to_admin_profile NVARCHAR(30) NULL,
        reason NVARCHAR(500) NOT NULL,
        changed_by NVARCHAR(180) NOT NULL,
        changed_at DATETIME2(0) NOT NULL CONSTRAINT df_account_role_history_changed_at DEFAULT GETDATE(),
        CONSTRAINT fk_account_role_history_user FOREIGN KEY (user_id) REFERENCES dbo.users(id)
    );
END;

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'ix_account_role_history_user_changed'
      AND object_id = OBJECT_ID(N'dbo.account_role_history')
)
    CREATE INDEX ix_account_role_history_user_changed
        ON dbo.account_role_history(user_id, changed_at DESC);
