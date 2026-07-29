-- Preserve full access for legacy administrators that predate profiles.
UPDATE users
SET admin_profile = 'FULL'
WHERE role = 'ADMIN'
  AND (admin_profile IS NULL OR BTRIM(admin_profile) = '');
