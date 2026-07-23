-- Backfill null admin profiles so least-privilege default (CONTENT) does not
-- silently strip system/CRM access from legacy ADMIN rows that predate profiles.
-- Explicit FULL is required for unrestricted CMS operators.

IF COL_LENGTH('dbo.users', 'admin_profile') IS NOT NULL
BEGIN
    UPDATE dbo.users
    SET admin_profile = N'FULL'
    WHERE role = N'ADMIN'
      AND (admin_profile IS NULL OR LTRIM(RTRIM(admin_profile)) = N'');
END
GO
