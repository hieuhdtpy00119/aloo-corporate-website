IF DB_ID(N'ALOO_Franchise_CMS') IS NULL
BEGIN
    CREATE DATABASE ALOO_Franchise_CMS;
END
GO

USE ALOO_Franchise_CMS;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

DROP TABLE IF EXISTS dbo.post_related_posts;
DROP TABLE IF EXISTS dbo.post_images;
DROP TABLE IF EXISTS dbo.testimonials;
DROP TABLE IF EXISTS dbo.store_gallery;
DROP TABLE IF EXISTS dbo.store_business_hours;
DROP TABLE IF EXISTS dbo.store_menu_posters;
DROP TABLE IF EXISTS dbo.products;
DROP TABLE IF EXISTS dbo.posts;
DROP TABLE IF EXISTS dbo.franchise_contents;
DROP TABLE IF EXISTS dbo.franchise_registrations;
DROP TABLE IF EXISTS dbo.contact_messages;
DROP TABLE IF EXISTS dbo.stores;
DROP TABLE IF EXISTS dbo.locations;
DROP TABLE IF EXISTS dbo.menu_posters;
DROP TABLE IF EXISTS dbo.home_sections;
DROP TABLE IF EXISTS dbo.hero_banners;
DROP TABLE IF EXISTS dbo.brand_timelines;
DROP TABLE IF EXISTS dbo.categories;
DROP TABLE IF EXISTS dbo.users;
GO

CREATE TABLE dbo.users (
    id BIGINT IDENTITY(1,1) NOT NULL,
    email NVARCHAR(180) NOT NULL,
    password_hash NVARCHAR(255) NOT NULL,
    full_name NVARCHAR(180) NOT NULL,
    phone NVARCHAR(40) NULL,
    avatar_url NVARCHAR(600) NULL,
    role NVARCHAR(30) NOT NULL CONSTRAINT df_users_role DEFAULT N'USER',
    status NVARCHAR(30) NOT NULL CONSTRAINT df_users_status DEFAULT N'ACTIVE',
    last_login_at DATETIME2(0) NULL,
    created_at DATETIME2(0) NOT NULL CONSTRAINT df_users_created_at DEFAULT GETDATE(),
    updated_at DATETIME2(0) NOT NULL CONSTRAINT df_users_updated_at DEFAULT GETDATE(),
    CONSTRAINT pk_users PRIMARY KEY (id),
    CONSTRAINT uq_users_email UNIQUE (email),
    CONSTRAINT ck_users_role CHECK (role IN (N'ADMIN', N'USER')),
    CONSTRAINT ck_users_status CHECK (status IN (N'ACTIVE', N'INACTIVE', N'LOCKED'))
);
GO

CREATE TABLE dbo.categories (
    id BIGINT IDENTITY(1,1) NOT NULL,
    name NVARCHAR(180) NOT NULL,
    slug NVARCHAR(220) NOT NULL,
    type NVARCHAR(30) NOT NULL CONSTRAINT df_categories_type DEFAULT N'ARTICLE',
    description NVARCHAR(1000) NULL,
    parent_id BIGINT NULL,
    sort_order INT NOT NULL CONSTRAINT df_categories_sort_order DEFAULT 0,
    status NVARCHAR(40) NOT NULL CONSTRAINT df_categories_status DEFAULT N'ACTIVE',
    language_code NVARCHAR(10) NOT NULL CONSTRAINT df_categories_language_code DEFAULT N'vi',
    created_at DATETIME2(0) NOT NULL CONSTRAINT df_categories_created_at DEFAULT GETDATE(),
    updated_at DATETIME2(0) NOT NULL CONSTRAINT df_categories_updated_at DEFAULT GETDATE(),
    CONSTRAINT pk_categories PRIMARY KEY (id),
    CONSTRAINT uq_categories_type_slug UNIQUE (type, slug),
    CONSTRAINT fk_categories_parent FOREIGN KEY (parent_id) REFERENCES dbo.categories(id),
    CONSTRAINT ck_categories_type CHECK (type IN (N'ARTICLE', N'PRODUCT', N'GENERAL')),
    CONSTRAINT ck_categories_status CHECK (status IN (N'ACTIVE', N'INACTIVE'))
);
GO

CREATE TABLE dbo.products (
    id BIGINT IDENTITY(1,1) NOT NULL,
    category_id BIGINT NULL,
    name NVARCHAR(220) NOT NULL,
    slug NVARCHAR(240) NOT NULL,
    description NVARCHAR(MAX) NULL,
    short_description NVARCHAR(MAX) NULL,
    detail_content NVARCHAR(MAX) NULL,
    ingredients NVARCHAR(MAX) NULL,
    taste_profile NVARCHAR(MAX) NULL,
    serving_suggestion NVARCHAR(MAX) NULL,
    gallery NVARCHAR(MAX) NULL,
    faqs NVARCHAR(MAX) NULL,
    price DECIMAL(18,2) NULL,
    image_url NVARCHAR(600) NULL,
    category NVARCHAR(180) NULL,
    sort_order INT NOT NULL CONSTRAINT df_products_sort_order DEFAULT 0,
    featured BIT NOT NULL CONSTRAINT df_products_featured DEFAULT 0,
    seo_title NVARCHAR(260) NULL,
    seo_description NVARCHAR(500) NULL,
    status NVARCHAR(40) NOT NULL CONSTRAINT df_products_status DEFAULT N'ACTIVE',
    created_at DATETIME2(0) NOT NULL CONSTRAINT df_products_created_at DEFAULT GETDATE(),
    updated_at DATETIME2(0) NOT NULL CONSTRAINT df_products_updated_at DEFAULT GETDATE(),
    CONSTRAINT pk_products PRIMARY KEY (id),
    CONSTRAINT uq_products_slug UNIQUE (slug),
    CONSTRAINT fk_products_category FOREIGN KEY (category_id) REFERENCES dbo.categories(id),
    CONSTRAINT ck_products_status CHECK (status IN (N'ACTIVE', N'INACTIVE'))
);
GO

CREATE TABLE dbo.posts (
    id BIGINT IDENTITY(1,1) NOT NULL,
    category_id BIGINT NULL,
    title NVARCHAR(260) NOT NULL,
    slug NVARCHAR(280) NOT NULL,
    excerpt NVARCHAR(1000) NULL,
    content NVARCHAR(MAX) NULL,
    thumbnail_url NVARCHAR(600) NULL,
    author NVARCHAR(180) NULL,
    source NVARCHAR(180) NULL,
    source_link NVARCHAR(600) NULL,
    article_type NVARCHAR(120) NULL,
    status NVARCHAR(40) NOT NULL CONSTRAINT df_posts_status DEFAULT N'DRAFT',
    published_at DATETIME2(0) NULL,
    seo_title NVARCHAR(260) NULL,
    seo_description NVARCHAR(500) NULL,
    meta_description NVARCHAR(500) NULL,
    meta_keywords NVARCHAR(500) NULL,
    canonical_url NVARCHAR(600) NULL,
    tags NVARCHAR(500) NULL,
    created_at DATETIME2(0) NOT NULL CONSTRAINT df_posts_created_at DEFAULT GETDATE(),
    updated_at DATETIME2(0) NOT NULL CONSTRAINT df_posts_updated_at DEFAULT GETDATE(),
    CONSTRAINT pk_posts PRIMARY KEY (id),
    CONSTRAINT uq_posts_slug UNIQUE (slug),
    CONSTRAINT fk_posts_category FOREIGN KEY (category_id) REFERENCES dbo.categories(id),
    CONSTRAINT ck_posts_status CHECK (status IN (N'DRAFT', N'PENDING', N'REVIEWING', N'APPROVED', N'PUBLISHED', N'ARCHIVED'))
);
GO

CREATE TABLE dbo.post_images (
    id BIGINT IDENTITY(1,1) NOT NULL,
    post_id BIGINT NOT NULL,
    image_url NVARCHAR(600) NOT NULL,
    alt_text NVARCHAR(260) NULL,
    image_type NVARCHAR(30) NOT NULL CONSTRAINT df_post_images_image_type DEFAULT N'GALLERY',
    sort_order INT NOT NULL CONSTRAINT df_post_images_sort_order DEFAULT 0,
    created_at DATETIME2(0) NOT NULL CONSTRAINT df_post_images_created_at DEFAULT GETDATE(),
    CONSTRAINT pk_post_images PRIMARY KEY (id),
    CONSTRAINT fk_post_images_post FOREIGN KEY (post_id) REFERENCES dbo.posts(id) ON DELETE CASCADE,
    CONSTRAINT ck_post_images_type CHECK (image_type IN (N'THUMBNAIL', N'GALLERY', N'CONTENT'))
);
GO

CREATE TABLE dbo.post_related_posts (
    post_id BIGINT NOT NULL,
    related_post_id BIGINT NOT NULL,
    CONSTRAINT pk_post_related_posts PRIMARY KEY (post_id, related_post_id),
    CONSTRAINT fk_post_related_posts_post FOREIGN KEY (post_id) REFERENCES dbo.posts(id) ON DELETE CASCADE,
    CONSTRAINT fk_post_related_posts_related FOREIGN KEY (related_post_id) REFERENCES dbo.posts(id)
);
GO

CREATE TABLE dbo.franchise_registrations (
    id BIGINT IDENTITY(1,1) NOT NULL,
    full_name NVARCHAR(180) NOT NULL,
    phone NVARCHAR(40) NOT NULL,
    email NVARCHAR(180) NULL,
    province NVARCHAR(120) NOT NULL,
    expected_budget DECIMAL(18,2) NULL,
    note NVARCHAR(MAX) NULL,
    status NVARCHAR(40) NOT NULL CONSTRAINT df_franchise_registrations_status DEFAULT N'NEW',
    created_at DATETIME2(0) NOT NULL CONSTRAINT df_franchise_registrations_created_at DEFAULT GETDATE(),
    updated_at DATETIME2(0) NOT NULL CONSTRAINT df_franchise_registrations_updated_at DEFAULT GETDATE(),
    last_contacted_at DATETIME2(0) NULL,
    assigned_to NVARCHAR(180) NULL,
    CONSTRAINT pk_franchise_registrations PRIMARY KEY (id),
    CONSTRAINT ck_franchise_registrations_status CHECK (status IN (N'NEW', N'CONTACTED', N'CONSULTING', N'POTENTIAL', N'SIGNED', N'REJECTED'))
);
GO

CREATE TABLE dbo.contact_messages (
    id BIGINT IDENTITY(1,1) NOT NULL,
    full_name NVARCHAR(180) NOT NULL,
    email NVARCHAR(180) NULL,
    phone NVARCHAR(40) NOT NULL,
    subject NVARCHAR(220) NULL,
    message NVARCHAR(MAX) NOT NULL,
    status NVARCHAR(40) NOT NULL CONSTRAINT df_contact_messages_status DEFAULT N'NEW',
    created_at DATETIME2(0) NOT NULL CONSTRAINT df_contact_messages_created_at DEFAULT GETDATE(),
    updated_at DATETIME2(0) NOT NULL CONSTRAINT df_contact_messages_updated_at DEFAULT GETDATE(),
    CONSTRAINT pk_contact_messages PRIMARY KEY (id),
    CONSTRAINT ck_contact_messages_status CHECK (status IN (N'NEW', N'READ', N'REPLIED', N'ARCHIVED'))
);
GO

CREATE TABLE dbo.stores (
    id BIGINT IDENTITY(1,1) NOT NULL,
    store_code NVARCHAR(50) NOT NULL,
    name NVARCHAR(180) NOT NULL,
    slug NVARCHAR(220) NOT NULL,
    address NVARCHAR(500) NOT NULL,
    province NVARCHAR(120) NOT NULL,
    district NVARCHAR(120) NULL,
    ward NVARCHAR(120) NULL,
    latitude DECIMAL(10,7) NULL,
    longitude DECIMAL(10,7) NULL,
    phone NVARCHAR(80) NULL,
    email NVARCHAR(180) NULL,
    google_map_url NVARCHAR(600) NULL,
    store_type NVARCHAR(40) NOT NULL CONSTRAINT df_stores_store_type DEFAULT N'STANDARD',
    description NVARCHAR(MAX) NULL,
    cover_image_url NVARCHAR(600) NULL,
    featured BIT NOT NULL CONSTRAINT df_stores_featured DEFAULT 0,
    display_order INT NOT NULL CONSTRAINT df_stores_display_order DEFAULT 0,
    status NVARCHAR(40) NOT NULL CONSTRAINT df_stores_status DEFAULT N'ACTIVE',
    created_at DATETIME2(0) NOT NULL CONSTRAINT df_stores_created_at DEFAULT GETDATE(),
    updated_at DATETIME2(0) NOT NULL CONSTRAINT df_stores_updated_at DEFAULT GETDATE(),
    CONSTRAINT pk_stores PRIMARY KEY (id),
    CONSTRAINT uq_stores_store_code UNIQUE (store_code),
    CONSTRAINT uq_stores_slug UNIQUE (slug),
    CONSTRAINT ck_stores_store_type CHECK (store_type IN (N'FLAGSHIP', N'STANDARD', N'KIOSK', N'FRANCHISE', N'POPUP')),
    CONSTRAINT ck_stores_status CHECK (status IN (N'ACTIVE', N'COMING_SOON', N'TEMPORARILY_CLOSED', N'MAINTENANCE', N'INACTIVE'))
);
GO

CREATE TABLE dbo.store_gallery (
    id BIGINT IDENTITY(1,1) NOT NULL,
    store_id BIGINT NOT NULL,
    image_url NVARCHAR(600) NOT NULL,
    alt_text NVARCHAR(260) NULL,
    sort_order INT NOT NULL CONSTRAINT df_store_gallery_sort_order DEFAULT 0,
    CONSTRAINT pk_store_gallery PRIMARY KEY (id),
    CONSTRAINT fk_store_gallery_store FOREIGN KEY (store_id) REFERENCES dbo.stores(id) ON DELETE CASCADE
);
GO

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
GO

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
GO

CREATE TABLE dbo.testimonials (
    id BIGINT IDENTITY(1,1) NOT NULL,
    customer_name NVARCHAR(100) NOT NULL,
    avatar_url NVARCHAR(500) NULL,
    rating INT NOT NULL,
    content NVARCHAR(MAX) NOT NULL,
    store_name NVARCHAR(180) NULL,
    is_visible BIT NOT NULL CONSTRAINT df_testimonials_is_visible DEFAULT 1,
    sort_order INT NOT NULL CONSTRAINT df_testimonials_sort_order DEFAULT 0,
    created_at DATETIME2(0) NOT NULL CONSTRAINT df_testimonials_created_at DEFAULT GETDATE(),
    updated_at DATETIME2(0) NOT NULL CONSTRAINT df_testimonials_updated_at DEFAULT GETDATE(),
    CONSTRAINT pk_testimonials PRIMARY KEY (id),
    CONSTRAINT ck_testimonials_rating CHECK (rating BETWEEN 1 AND 5)
);
GO

CREATE TABLE dbo.franchise_contents (
    id BIGINT IDENTITY(1,1) NOT NULL,
    section_key NVARCHAR(120) NOT NULL,
    title NVARCHAR(220) NOT NULL,
    content NVARCHAR(MAX) NULL,
    amount NVARCHAR(120) NULL,
    note NVARCHAR(MAX) NULL,
    sort_order INT NOT NULL CONSTRAINT df_franchise_contents_sort_order DEFAULT 0,
    status NVARCHAR(40) NOT NULL CONSTRAINT df_franchise_contents_status DEFAULT N'ACTIVE',
    created_at DATETIME2(0) NOT NULL CONSTRAINT df_franchise_contents_created_at DEFAULT GETDATE(),
    updated_at DATETIME2(0) NOT NULL CONSTRAINT df_franchise_contents_updated_at DEFAULT GETDATE(),
    CONSTRAINT pk_franchise_contents PRIMARY KEY (id),
    CONSTRAINT ck_franchise_contents_status CHECK (status IN (N'ACTIVE', N'INACTIVE', N'HIDDEN'))
);
GO

CREATE TABLE dbo.hero_banners (
    id BIGINT IDENTITY(1,1) NOT NULL,
    title NVARCHAR(220) NOT NULL,
    subtitle NVARCHAR(180) NULL,
    description NVARCHAR(1000) NULL,
    background_image_url NVARCHAR(600) NULL,
    product_image_url NVARCHAR(600) NULL,
    thumbnail_image_url NVARCHAR(600) NULL,
    tone NVARCHAR(20) NOT NULL CONSTRAINT df_hero_banners_tone DEFAULT N'light',
    sort_order INT NOT NULL CONSTRAINT df_hero_banners_sort_order DEFAULT 0,
    status NVARCHAR(40) NOT NULL CONSTRAINT df_hero_banners_status DEFAULT N'ACTIVE',
    created_at DATETIME2(0) NOT NULL CONSTRAINT df_hero_banners_created_at DEFAULT GETDATE(),
    updated_at DATETIME2(0) NOT NULL CONSTRAINT df_hero_banners_updated_at DEFAULT GETDATE(),
    CONSTRAINT pk_hero_banners PRIMARY KEY (id),
    CONSTRAINT ck_hero_banners_tone CHECK (tone IN (N'light', N'dark')),
    CONSTRAINT ck_hero_banners_status CHECK (status IN (N'ACTIVE', N'INACTIVE'))
);
GO


CREATE TABLE dbo.home_sections (
    id BIGINT IDENTITY(1,1) NOT NULL,
    section_key NVARCHAR(120) NOT NULL,
    type NVARCHAR(60) NOT NULL CONSTRAINT df_home_sections_type DEFAULT N'FEATURED_CARD',
    title NVARCHAR(220) NOT NULL,
    subtitle NVARCHAR(180) NULL,
    description NVARCHAR(MAX) NULL,
    image_url NVARCHAR(600) NULL,
    button_text NVARCHAR(120) NULL,
    button_link NVARCHAR(600) NULL,
    badge NVARCHAR(160) NULL,
    sort_order INT NOT NULL CONSTRAINT df_home_sections_sort_order DEFAULT 0,
    status NVARCHAR(40) NOT NULL CONSTRAINT df_home_sections_status DEFAULT N'ACTIVE',
    created_at DATETIME2(0) NOT NULL CONSTRAINT df_home_sections_created_at DEFAULT GETDATE(),
    updated_at DATETIME2(0) NOT NULL CONSTRAINT df_home_sections_updated_at DEFAULT GETDATE(),
    CONSTRAINT pk_home_sections PRIMARY KEY (id),
    CONSTRAINT ck_home_sections_status CHECK (status IN (N'ACTIVE', N'INACTIVE')),
    CONSTRAINT ck_home_sections_type CHECK (type IN (N'FEATURED_CARD', N'CTA_CARD', N'PRODUCT_CARD', N'LOCATION_CARD'))
);
GO
CREATE TABLE dbo.menu_posters (
    id BIGINT IDENTITY(1,1) NOT NULL,
    branch_key NVARCHAR(120) NOT NULL,
    title NVARCHAR(220) NOT NULL,
    subtitle NVARCHAR(180) NULL,
    image_url NVARCHAR(600) NULL,
    alt_text NVARCHAR(260) NULL,
    sort_order INT NOT NULL CONSTRAINT df_menu_posters_sort_order DEFAULT 0,
    status NVARCHAR(40) NOT NULL CONSTRAINT df_menu_posters_status DEFAULT N'ACTIVE',
    created_at DATETIME2(0) NOT NULL CONSTRAINT df_menu_posters_created_at DEFAULT GETDATE(),
    updated_at DATETIME2(0) NOT NULL CONSTRAINT df_menu_posters_updated_at DEFAULT GETDATE(),
    CONSTRAINT pk_menu_posters PRIMARY KEY (id),
    CONSTRAINT uq_menu_posters_branch_key UNIQUE (branch_key),
    CONSTRAINT ck_menu_posters_status CHECK (status IN (N'ACTIVE', N'INACTIVE'))
);
GO

CREATE TABLE dbo.brand_timelines (
    id BIGINT IDENTITY(1,1) NOT NULL,
    timeline_year NVARCHAR(80) NOT NULL,
    title NVARCHAR(220) NOT NULL,
    description NVARCHAR(MAX) NULL,
    image_url NVARCHAR(600) NULL,
    sort_order INT NOT NULL CONSTRAINT df_brand_timelines_sort_order DEFAULT 0,
    status NVARCHAR(40) NOT NULL CONSTRAINT df_brand_timelines_status DEFAULT N'ACTIVE',
    created_at DATETIME2(0) NOT NULL CONSTRAINT df_brand_timelines_created_at DEFAULT GETDATE(),
    updated_at DATETIME2(0) NOT NULL CONSTRAINT df_brand_timelines_updated_at DEFAULT GETDATE(),
    CONSTRAINT pk_brand_timelines PRIMARY KEY (id),
    CONSTRAINT ck_brand_timelines_status CHECK (status IN (N'ACTIVE', N'INACTIVE'))
);
GO

CREATE INDEX ix_users_role_status ON dbo.users(role, status, created_at DESC);
CREATE INDEX ix_categories_type_status ON dbo.categories(type, status, sort_order);
CREATE INDEX ix_products_status_category ON dbo.products(status, category_id, sort_order);
CREATE INDEX ix_testimonials_visible_sort ON dbo.testimonials(is_visible, sort_order, created_at DESC);
CREATE INDEX ix_posts_status_published_at ON dbo.posts(status, published_at DESC);
CREATE INDEX ix_posts_category ON dbo.posts(category_id);
CREATE INDEX ix_registrations_status_created_at ON dbo.franchise_registrations(status, created_at DESC);
CREATE INDEX ix_contact_messages_status_created_at ON dbo.contact_messages(status, created_at DESC);
CREATE INDEX ix_stores_status_province ON dbo.stores(status, province, display_order);
CREATE INDEX ix_stores_featured_status ON dbo.stores(featured, status, display_order);
CREATE INDEX ix_store_gallery_store_sort ON dbo.store_gallery(store_id, sort_order);
CREATE INDEX ix_store_business_hours_store_day ON dbo.store_business_hours(store_id, day_of_week);
CREATE INDEX ix_store_menu_posters_store_sort ON dbo.store_menu_posters(store_id, is_active, sort_order);
CREATE INDEX ix_franchise_contents_section ON dbo.franchise_contents(section_key, status, sort_order);
CREATE INDEX ix_hero_banners_status_sort ON dbo.hero_banners(status, sort_order);
CREATE INDEX ix_home_sections_status_sort ON dbo.home_sections(status, sort_order);
CREATE INDEX ix_menu_posters_status_sort ON dbo.menu_posters(status, sort_order);
CREATE INDEX ix_brand_timelines_status_sort ON dbo.brand_timelines(status, sort_order);
GO

-- Schema only. No mock/demo/sample business data is inserted here.
-- Create the first ADMIN account manually with a BCrypt password hash in dbo.users,
-- or run backend/database/aloo_franchise_cms_sample_data.sql only in local development.

