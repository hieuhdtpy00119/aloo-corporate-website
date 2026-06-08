USE ALOO_Franchise_CMS;
GO

IF OBJECT_ID(N'dbo.feedbacks', N'U') IS NOT NULL AND OBJECT_ID(N'dbo.testimonials', N'U') IS NULL
BEGIN
    EXEC sp_rename N'dbo.feedbacks', N'testimonials';
END
GO

IF OBJECT_ID(N'dbo.testimonials', N'U') IS NOT NULL
BEGIN
    IF COL_LENGTH(N'dbo.testimonials', N'avatar_url') IS NULL
        ALTER TABLE dbo.testimonials ADD avatar_url NVARCHAR(500) NULL;
    IF COL_LENGTH(N'dbo.testimonials', N'store_name') IS NULL
        ALTER TABLE dbo.testimonials ADD store_name NVARCHAR(180) NULL;
    IF COL_LENGTH(N'dbo.testimonials', N'is_visible') IS NULL
        ALTER TABLE dbo.testimonials ADD is_visible BIT NOT NULL CONSTRAINT df_testimonials_is_visible DEFAULT 1;
    IF COL_LENGTH(N'dbo.testimonials', N'sort_order') IS NULL
        ALTER TABLE dbo.testimonials ADD sort_order INT NOT NULL CONSTRAINT df_testimonials_sort_order DEFAULT 0;

    IF COL_LENGTH(N'dbo.testimonials', N'phone') IS NOT NULL ALTER TABLE dbo.testimonials DROP COLUMN phone;
    IF COL_LENGTH(N'dbo.testimonials', N'email') IS NOT NULL ALTER TABLE dbo.testimonials DROP COLUMN email;
    IF COL_LENGTH(N'dbo.testimonials', N'user_id') IS NOT NULL ALTER TABLE dbo.testimonials DROP COLUMN user_id;
    IF COL_LENGTH(N'dbo.testimonials', N'store_id') IS NOT NULL ALTER TABLE dbo.testimonials DROP COLUMN store_id;
    IF COL_LENGTH(N'dbo.testimonials', N'product_id') IS NOT NULL ALTER TABLE dbo.testimonials DROP COLUMN product_id;
    IF COL_LENGTH(N'dbo.testimonials', N'image_url') IS NOT NULL ALTER TABLE dbo.testimonials DROP COLUMN image_url;
    IF COL_LENGTH(N'dbo.testimonials', N'is_featured') IS NOT NULL ALTER TABLE dbo.testimonials DROP COLUMN is_featured;
    IF COL_LENGTH(N'dbo.testimonials', N'status') IS NOT NULL ALTER TABLE dbo.testimonials DROP COLUMN status;
END
GO

IF COL_LENGTH(N'dbo.franchise_registrations', N'last_contacted_at') IS NULL
    ALTER TABLE dbo.franchise_registrations ADD last_contacted_at DATETIME2(0) NULL;
IF COL_LENGTH(N'dbo.franchise_registrations', N'assigned_to') IS NULL
    ALTER TABLE dbo.franchise_registrations ADD assigned_to NVARCHAR(180) NULL;

UPDATE dbo.franchise_registrations SET status = N'SIGNED' WHERE status IN (N'DONE', N'COMPLETED');
UPDATE dbo.franchise_registrations SET status = N'REJECTED' WHERE status IN (N'CANCELED', N'CANCELLED');
GO

IF COL_LENGTH(N'dbo.stores', N'google_map_url') IS NULL
    ALTER TABLE dbo.stores ADD google_map_url NVARCHAR(600) NULL;

IF OBJECT_ID(N'dbo.store_gallery', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.store_gallery (
        id BIGINT IDENTITY(1,1) NOT NULL,
        store_id BIGINT NOT NULL,
        image_url NVARCHAR(600) NOT NULL,
        alt_text NVARCHAR(260) NULL,
        sort_order INT NOT NULL CONSTRAINT df_store_gallery_sort_order DEFAULT 0,
        CONSTRAINT pk_store_gallery PRIMARY KEY (id),
        CONSTRAINT fk_store_gallery_store FOREIGN KEY (store_id) REFERENCES dbo.stores(id) ON DELETE CASCADE
    );
END
GO

IF OBJECT_ID(N'dbo.store_business_hours', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.store_business_hours (
        id BIGINT IDENTITY(1,1) NOT NULL,
        store_id BIGINT NOT NULL,
        day_of_week INT NOT NULL,
        open_time TIME NULL,
        close_time TIME NULL,
        is_closed BIT NOT NULL CONSTRAINT df_store_business_hours_is_closed DEFAULT 0,
        CONSTRAINT pk_store_business_hours PRIMARY KEY (id),
        CONSTRAINT fk_store_business_hours_store FOREIGN KEY (store_id) REFERENCES dbo.stores(id) ON DELETE CASCADE
    );
END
GO

IF OBJECT_ID(N'dbo.store_menu_posters', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.store_menu_posters (
        id BIGINT IDENTITY(1,1) NOT NULL,
        store_id BIGINT NOT NULL,
        title NVARCHAR(220) NOT NULL,
        image_url NVARCHAR(600) NOT NULL,
        sort_order INT NOT NULL CONSTRAINT df_store_menu_posters_sort_order DEFAULT 0,
        is_active BIT NOT NULL CONSTRAINT df_store_menu_posters_is_active DEFAULT 1,
        CONSTRAINT pk_store_menu_posters PRIMARY KEY (id),
        CONSTRAINT fk_store_menu_posters_store FOREIGN KEY (store_id) REFERENCES dbo.stores(id) ON DELETE CASCADE
    );
END
GO
