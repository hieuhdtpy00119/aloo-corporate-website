-- Enforce unique homepage block keys
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'ux_home_sections_section_key'
      AND object_id = OBJECT_ID('dbo.home_sections')
)
BEGIN
    CREATE UNIQUE INDEX ux_home_sections_section_key ON dbo.home_sections(section_key);
END
