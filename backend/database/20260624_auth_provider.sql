USE ALOO_Franchise_CMS;
GO

IF COL_LENGTH('dbo.users', 'auth_provider') IS NULL
BEGIN
    ALTER TABLE dbo.users
    ADD auth_provider NVARCHAR(20) NOT NULL CONSTRAINT df_users_auth_provider DEFAULT N'LOCAL';
END
GO

UPDATE dbo.users
SET auth_provider = N'GOOGLE'
WHERE auth_provider = N'LOCAL'
  AND avatar_url LIKE N'%googleusercontent.com%';
GO

UPDATE u
SET u.auth_provider = N'GOOGLE'
FROM dbo.users u
WHERE u.auth_provider = N'LOCAL'
  AND EXISTS (
    SELECT 1
    FROM dbo.audit_logs a
    WHERE a.action = N'PROMOTE_CUSTOMER'
      AND a.details LIKE N'%' + u.email + N'%'
  );
GO
