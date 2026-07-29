-- Keep former franchise locations visible without presenting them as active stores.
ALTER TABLE stores DROP CONSTRAINT IF EXISTS ck_stores_status;
ALTER TABLE stores ADD CONSTRAINT ck_stores_status
    CHECK (status IN (
        'ACTIVE',
        'COMING_SOON',
        'TEMPORARILY_CLOSED',
        'MAINTENANCE',
        'FORMERLY_ACTIVE',
        'INACTIVE'
    ));
