USE ALOO_Franchise_CMS;
GO

IF COL_LENGTH('dbo.users', 'password_set_at') IS NULL
BEGIN
    ALTER TABLE dbo.users
    ADD password_set_at DATETIME2(0) NULL;
END
GO

UPDATE dbo.users
SET password_set_at = COALESCE(updated_at, created_at, SYSUTCDATETIME())
WHERE password_set_at IS NULL
  AND auth_provider = N'LOCAL';
GO
