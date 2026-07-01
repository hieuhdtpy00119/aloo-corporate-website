-- Persist store amenities selected in admin locations modal
IF COL_LENGTH('stores', 'amenities_json') IS NULL
BEGIN
    ALTER TABLE stores ADD amenities_json NVARCHAR(MAX) NOT NULL CONSTRAINT DF_stores_amenities_json DEFAULT ('[]');
END
GO
