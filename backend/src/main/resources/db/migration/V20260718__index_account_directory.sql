-- Indexes for paged account management and active-admin reassignment lookups.

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'ix_users_account_directory'
      AND object_id = OBJECT_ID(N'dbo.users')
)
    CREATE INDEX ix_users_account_directory
        ON dbo.users(role, status, created_at DESC)
        INCLUDE (email, full_name, phone, admin_profile, auth_provider, last_login_at,
                 record_version, security_version);

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'ix_users_active_admin_lookup'
      AND object_id = OBJECT_ID(N'dbo.users')
)
    CREATE INDEX ix_users_active_admin_lookup
        ON dbo.users(role, status, full_name, email)
        INCLUDE (admin_profile, auth_provider, record_version);
