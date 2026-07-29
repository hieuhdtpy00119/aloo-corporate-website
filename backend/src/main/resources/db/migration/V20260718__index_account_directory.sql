-- Covering indexes for PostgreSQL account-management queries.
CREATE INDEX IF NOT EXISTS ix_users_account_directory
    ON users(role, status, created_at DESC)
    INCLUDE (email, full_name, phone, admin_profile, auth_provider, last_login_at,
             record_version, security_version);

CREATE INDEX IF NOT EXISTS ix_users_active_admin_lookup
    ON users(role, status, full_name, email)
    INCLUDE (admin_profile, auth_provider, record_version);
