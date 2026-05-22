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

IF OBJECT_ID(N'dbo.users', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.users (
        id BIGINT IDENTITY(1,1) NOT NULL,
        email NVARCHAR(180) NOT NULL,
        password_hash NVARCHAR(255) NOT NULL,
        full_name NVARCHAR(180) NOT NULL,
        phone NVARCHAR(40) NULL,
        avatar_url NVARCHAR(600) NULL,
        role NVARCHAR(30) NOT NULL CONSTRAINT df_users_role DEFAULT N'ADMIN',
        status NVARCHAR(30) NOT NULL CONSTRAINT df_users_status DEFAULT N'ACTIVE',
        last_login_at DATETIME2(0) NULL,
        created_at DATETIME2(0) NOT NULL CONSTRAINT df_users_created_at DEFAULT SYSUTCDATETIME(),
        updated_at DATETIME2(0) NOT NULL CONSTRAINT df_users_updated_at DEFAULT SYSUTCDATETIME(),
        CONSTRAINT pk_users PRIMARY KEY (id),
        CONSTRAINT uq_users_email UNIQUE (email),
        CONSTRAINT ck_users_role CHECK (role IN (N'ADMIN')),
        CONSTRAINT ck_users_status CHECK (status IN (N'ACTIVE', N'INACTIVE', N'LOCKED'))
    );
END
GO

IF OBJECT_ID(N'dbo.customer_users', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.customer_users (
        id BIGINT IDENTITY(1,1) NOT NULL,
        email NVARCHAR(180) NOT NULL,
        password_hash NVARCHAR(255) NOT NULL,
        full_name NVARCHAR(180) NOT NULL,
        phone NVARCHAR(40) NULL,
        avatar_url NVARCHAR(600) NULL,
        role NVARCHAR(30) NOT NULL CONSTRAINT df_customer_users_role DEFAULT N'USER',
        status NVARCHAR(30) NOT NULL CONSTRAINT df_customer_users_status DEFAULT N'ACTIVE',
        last_login_at DATETIME2(0) NULL,
        created_at DATETIME2(0) NOT NULL CONSTRAINT df_customer_users_created_at DEFAULT SYSUTCDATETIME(),
        updated_at DATETIME2(0) NOT NULL CONSTRAINT df_customer_users_updated_at DEFAULT SYSUTCDATETIME(),
        CONSTRAINT pk_customer_users PRIMARY KEY (id),
        CONSTRAINT uq_customer_users_email UNIQUE (email),
        CONSTRAINT ck_customer_users_role CHECK (role IN (N'USER')),
        CONSTRAINT ck_customer_users_status CHECK (status IN (N'ACTIVE', N'INACTIVE', N'LOCKED'))
    );
END
GO

IF OBJECT_ID(N'dbo.categories', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.categories (
        id BIGINT IDENTITY(1,1) NOT NULL,
        name NVARCHAR(180) NOT NULL,
        slug NVARCHAR(220) NOT NULL,
        type NVARCHAR(30) NOT NULL CONSTRAINT df_categories_type DEFAULT N'ARTICLE',
        description NVARCHAR(1000) NULL,
        parent_id BIGINT NULL,
        sort_order INT NOT NULL CONSTRAINT df_categories_sort_order DEFAULT 0,
        status NVARCHAR(30) NOT NULL CONSTRAINT df_categories_status DEFAULT N'ACTIVE',
        language_code NVARCHAR(10) NOT NULL CONSTRAINT df_categories_language_code DEFAULT N'vi',
        created_at DATETIME2(0) NOT NULL CONSTRAINT df_categories_created_at DEFAULT SYSUTCDATETIME(),
        updated_at DATETIME2(0) NOT NULL CONSTRAINT df_categories_updated_at DEFAULT SYSUTCDATETIME(),
        CONSTRAINT pk_categories PRIMARY KEY (id),
        CONSTRAINT uq_categories_type_slug UNIQUE (type, slug),
        CONSTRAINT fk_categories_parent FOREIGN KEY (parent_id) REFERENCES dbo.categories(id),
        CONSTRAINT ck_categories_type CHECK (type IN (N'ARTICLE', N'PRODUCT', N'GENERAL')),
        CONSTRAINT ck_categories_status CHECK (status IN (N'ACTIVE', N'INACTIVE'))
    );
END
GO

IF OBJECT_ID(N'dbo.products', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.products (
        id BIGINT IDENTITY(1,1) NOT NULL,
        category_id BIGINT NULL,
        name NVARCHAR(220) NOT NULL,
        slug NVARCHAR(240) NOT NULL,
        description NVARCHAR(MAX) NULL,
        price DECIMAL(18,2) NULL,
        image_url NVARCHAR(600) NULL,
        sort_order INT NOT NULL CONSTRAINT df_products_sort_order DEFAULT 0,
        status NVARCHAR(30) NOT NULL CONSTRAINT df_products_status DEFAULT N'ACTIVE',
        created_at DATETIME2(0) NOT NULL CONSTRAINT df_products_created_at DEFAULT SYSUTCDATETIME(),
        updated_at DATETIME2(0) NOT NULL CONSTRAINT df_products_updated_at DEFAULT SYSUTCDATETIME(),
        CONSTRAINT pk_products PRIMARY KEY (id),
        CONSTRAINT uq_products_slug UNIQUE (slug),
        CONSTRAINT fk_products_category FOREIGN KEY (category_id) REFERENCES dbo.categories(id),
        CONSTRAINT ck_products_price CHECK (price IS NULL OR price >= 0),
        CONSTRAINT ck_products_status CHECK (status IN (N'ACTIVE', N'INACTIVE'))
    );
END
GO

IF OBJECT_ID(N'dbo.posts', N'U') IS NULL
BEGIN
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
        status NVARCHAR(30) NOT NULL CONSTRAINT df_posts_status DEFAULT N'DRAFT',
        published_at DATETIME2(0) NULL,
        seo_title NVARCHAR(260) NULL,
        seo_description NVARCHAR(500) NULL,
        meta_keywords NVARCHAR(500) NULL,
        canonical_url NVARCHAR(600) NULL,
        tags NVARCHAR(500) NULL,
        created_by BIGINT NULL,
        updated_by BIGINT NULL,
        created_at DATETIME2(0) NOT NULL CONSTRAINT df_posts_created_at DEFAULT SYSUTCDATETIME(),
        updated_at DATETIME2(0) NOT NULL CONSTRAINT df_posts_updated_at DEFAULT SYSUTCDATETIME(),
        CONSTRAINT pk_posts PRIMARY KEY (id),
        CONSTRAINT uq_posts_slug UNIQUE (slug),
        CONSTRAINT fk_posts_category FOREIGN KEY (category_id) REFERENCES dbo.categories(id),
        CONSTRAINT fk_posts_created_by FOREIGN KEY (created_by) REFERENCES dbo.users(id),
        CONSTRAINT fk_posts_updated_by FOREIGN KEY (updated_by) REFERENCES dbo.users(id),
        CONSTRAINT ck_posts_status CHECK (status IN (N'DRAFT', N'PENDING', N'REVIEWING', N'APPROVED', N'PUBLISHED', N'ARCHIVED'))
    );
END
GO

IF OBJECT_ID(N'dbo.post_images', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.post_images (
        id BIGINT IDENTITY(1,1) NOT NULL,
        post_id BIGINT NOT NULL,
        image_url NVARCHAR(600) NOT NULL,
        alt_text NVARCHAR(260) NULL,
        image_type NVARCHAR(30) NOT NULL CONSTRAINT df_post_images_type DEFAULT N'GALLERY',
        sort_order INT NOT NULL CONSTRAINT df_post_images_sort_order DEFAULT 0,
        created_at DATETIME2(0) NOT NULL CONSTRAINT df_post_images_created_at DEFAULT SYSUTCDATETIME(),
        CONSTRAINT pk_post_images PRIMARY KEY (id),
        CONSTRAINT fk_post_images_post FOREIGN KEY (post_id) REFERENCES dbo.posts(id) ON DELETE CASCADE,
        CONSTRAINT ck_post_images_type CHECK (image_type IN (N'GALLERY', N'INLINE'))
    );
END
GO

IF OBJECT_ID(N'dbo.post_related_posts', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.post_related_posts (
        post_id BIGINT NOT NULL,
        related_post_id BIGINT NOT NULL,
        sort_order INT NOT NULL CONSTRAINT df_post_related_posts_sort_order DEFAULT 0,
        CONSTRAINT pk_post_related_posts PRIMARY KEY (post_id, related_post_id),
        CONSTRAINT fk_post_related_posts_post FOREIGN KEY (post_id) REFERENCES dbo.posts(id),
        CONSTRAINT fk_post_related_posts_related FOREIGN KEY (related_post_id) REFERENCES dbo.posts(id),
        CONSTRAINT ck_post_related_posts_not_self CHECK (post_id <> related_post_id)
    );
END
GO

IF OBJECT_ID(N'dbo.franchise_registrations', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.franchise_registrations (
        id BIGINT IDENTITY(1,1) NOT NULL,
        full_name NVARCHAR(180) NOT NULL,
        phone NVARCHAR(40) NOT NULL,
        email NVARCHAR(180) NULL,
        province NVARCHAR(120) NOT NULL,
        expected_budget DECIMAL(18,2) NULL,
        note NVARCHAR(MAX) NULL,
        status NVARCHAR(30) NOT NULL CONSTRAINT df_franchise_registrations_status DEFAULT N'NEW',
        created_at DATETIME2(0) NOT NULL CONSTRAINT df_franchise_registrations_created_at DEFAULT SYSUTCDATETIME(),
        updated_at DATETIME2(0) NOT NULL CONSTRAINT df_franchise_registrations_updated_at DEFAULT SYSUTCDATETIME(),
        CONSTRAINT pk_franchise_registrations PRIMARY KEY (id),
        CONSTRAINT ck_franchise_registrations_budget CHECK (expected_budget IS NULL OR expected_budget >= 0),
        CONSTRAINT ck_franchise_registrations_status CHECK (status IN (N'NEW', N'CONTACTED', N'CONSULTING', N'DONE', N'CANCELED'))
    );
END
GO

IF OBJECT_ID(N'dbo.locations', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.locations (
        id BIGINT IDENTITY(1,1) NOT NULL,
        name NVARCHAR(180) NOT NULL,
        address NVARCHAR(500) NOT NULL,
        province NVARCHAR(120) NOT NULL,
        district NVARCHAR(120) NULL,
        phone NVARCHAR(40) NULL,
        opening_hours NVARCHAR(180) NULL,
        map_url NVARCHAR(1000) NULL,
        image_url NVARCHAR(600) NULL,
        amenities_json NVARCHAR(MAX) NULL,
        display_order INT NOT NULL CONSTRAINT df_locations_display_order DEFAULT 0,
        featured BIT NOT NULL CONSTRAINT df_locations_featured DEFAULT 0,
        status NVARCHAR(30) NOT NULL CONSTRAINT df_locations_status DEFAULT N'ACTIVE',
        created_at DATETIME2(0) NOT NULL CONSTRAINT df_locations_created_at DEFAULT SYSUTCDATETIME(),
        updated_at DATETIME2(0) NOT NULL CONSTRAINT df_locations_updated_at DEFAULT SYSUTCDATETIME(),
        CONSTRAINT pk_locations PRIMARY KEY (id),
        CONSTRAINT ck_locations_status CHECK (status IN (N'ACTIVE', N'COMING_SOON', N'TEMPORARILY_CLOSED', N'MAINTENANCE', N'INACTIVE'))
    );
END
GO

IF OBJECT_ID(N'dbo.franchise_contents', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.franchise_contents (
        id BIGINT IDENTITY(1,1) NOT NULL,
        section_key NVARCHAR(120) NOT NULL,
        title NVARCHAR(220) NOT NULL,
        content NVARCHAR(MAX) NULL,
        amount NVARCHAR(120) NULL,
        note NVARCHAR(MAX) NULL,
        sort_order INT NOT NULL CONSTRAINT df_franchise_contents_sort_order DEFAULT 0,
        status NVARCHAR(30) NOT NULL CONSTRAINT df_franchise_contents_status DEFAULT N'ACTIVE',
        created_at DATETIME2(0) NOT NULL CONSTRAINT df_franchise_contents_created_at DEFAULT SYSUTCDATETIME(),
        updated_at DATETIME2(0) NOT NULL CONSTRAINT df_franchise_contents_updated_at DEFAULT SYSUTCDATETIME(),
        CONSTRAINT pk_franchise_contents PRIMARY KEY (id),
        CONSTRAINT ck_franchise_contents_section CHECK (section_key IN (N'benefits', N'conditions', N'process', N'costs')),
        CONSTRAINT ck_franchise_contents_status CHECK (status IN (N'ACTIVE', N'INACTIVE', N'HIDDEN'))
    );
END
GO

IF OBJECT_ID(N'dbo.hero_banners', N'U') IS NULL
BEGIN
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
        status NVARCHAR(30) NOT NULL CONSTRAINT df_hero_banners_status DEFAULT N'ACTIVE',
        created_at DATETIME2(0) NOT NULL CONSTRAINT df_hero_banners_created_at DEFAULT SYSUTCDATETIME(),
        updated_at DATETIME2(0) NOT NULL CONSTRAINT df_hero_banners_updated_at DEFAULT SYSUTCDATETIME(),
        CONSTRAINT pk_hero_banners PRIMARY KEY (id),
        CONSTRAINT ck_hero_banners_tone CHECK (tone IN (N'light', N'dark')),
        CONSTRAINT ck_hero_banners_status CHECK (status IN (N'ACTIVE', N'INACTIVE'))
    );
END
GO

IF OBJECT_ID(N'dbo.menu_posters', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.menu_posters (
        id BIGINT IDENTITY(1,1) NOT NULL,
        branch_key NVARCHAR(120) NOT NULL,
        title NVARCHAR(220) NOT NULL,
        subtitle NVARCHAR(180) NULL,
        image_url NVARCHAR(600) NULL,
        alt_text NVARCHAR(260) NULL,
        sort_order INT NOT NULL CONSTRAINT df_menu_posters_sort_order DEFAULT 0,
        status NVARCHAR(30) NOT NULL CONSTRAINT df_menu_posters_status DEFAULT N'ACTIVE',
        created_at DATETIME2(0) NOT NULL CONSTRAINT df_menu_posters_created_at DEFAULT SYSUTCDATETIME(),
        updated_at DATETIME2(0) NOT NULL CONSTRAINT df_menu_posters_updated_at DEFAULT SYSUTCDATETIME(),
        CONSTRAINT pk_menu_posters PRIMARY KEY (id),
        CONSTRAINT uq_menu_posters_branch_key UNIQUE (branch_key),
        CONSTRAINT ck_menu_posters_status CHECK (status IN (N'ACTIVE', N'INACTIVE'))
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_categories_type_status' AND object_id = OBJECT_ID(N'dbo.categories'))
    CREATE INDEX ix_categories_type_status ON dbo.categories(type, status, sort_order);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_customer_users_status' AND object_id = OBJECT_ID(N'dbo.customer_users'))
    CREATE INDEX ix_customer_users_status ON dbo.customer_users(status, created_at DESC);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_products_status_category' AND object_id = OBJECT_ID(N'dbo.products'))
    CREATE INDEX ix_products_status_category ON dbo.products(status, category_id, sort_order);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_posts_status_published_at' AND object_id = OBJECT_ID(N'dbo.posts'))
    CREATE INDEX ix_posts_status_published_at ON dbo.posts(status, published_at DESC);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_posts_category' AND object_id = OBJECT_ID(N'dbo.posts'))
    CREATE INDEX ix_posts_category ON dbo.posts(category_id);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_registrations_status_created_at' AND object_id = OBJECT_ID(N'dbo.franchise_registrations'))
    CREATE INDEX ix_registrations_status_created_at ON dbo.franchise_registrations(status, created_at DESC);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_locations_status_province' AND object_id = OBJECT_ID(N'dbo.locations'))
    CREATE INDEX ix_locations_status_province ON dbo.locations(status, province, display_order);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_franchise_contents_section' AND object_id = OBJECT_ID(N'dbo.franchise_contents'))
    CREATE INDEX ix_franchise_contents_section ON dbo.franchise_contents(section_key, status, sort_order);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_hero_banners_status_sort' AND object_id = OBJECT_ID(N'dbo.hero_banners'))
    CREATE INDEX ix_hero_banners_status_sort ON dbo.hero_banners(status, sort_order);
GO

-- Default admin password: 123456. Change it immediately after first login.
IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE email = N'admin@aloo.vn')
BEGIN
    INSERT INTO dbo.users (email, password_hash, full_name, phone, role, status)
    VALUES (N'admin@aloo.vn', N'$2a$10$.Qt3cc3WDZaSUrprSayKsePkQ/LoBW8z8dzFoSpmNkbLmqwCmuPAu', N'ALOO Admin', N'0900 888 168', N'ADMIN', N'ACTIVE');
END
ELSE
BEGIN
    UPDATE dbo.users
    SET password_hash = N'$2a$10$.Qt3cc3WDZaSUrprSayKsePkQ/LoBW8z8dzFoSpmNkbLmqwCmuPAu',
        role = N'ADMIN',
        status = N'ACTIVE',
        updated_at = SYSUTCDATETIME()
    WHERE email = N'admin@aloo.vn';
END
GO

-- Default user password: 123456. Change it immediately after first login.
IF NOT EXISTS (SELECT 1 FROM dbo.customer_users WHERE email = N'user@aloo.vn')
BEGIN
    INSERT INTO dbo.customer_users (email, password_hash, full_name, phone, role, status)
    VALUES (N'user@aloo.vn', N'$2a$10$.Qt3cc3WDZaSUrprSayKsePkQ/LoBW8z8dzFoSpmNkbLmqwCmuPAu', N'ALOO User', N'0901 234 567', N'USER', N'ACTIVE');
END
ELSE
BEGIN
    UPDATE dbo.customer_users
    SET password_hash = N'$2a$10$.Qt3cc3WDZaSUrprSayKsePkQ/LoBW8z8dzFoSpmNkbLmqwCmuPAu',
        role = N'USER',
        status = N'ACTIVE',
        updated_at = SYSUTCDATETIME()
    WHERE email = N'user@aloo.vn';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.categories)
BEGIN
    INSERT INTO dbo.categories (name, slug, type, description, sort_order, status) VALUES
    (N'Giới thiệu thương hiệu', N'gioi-thieu-thuong-hieu', N'ARTICLE', N'Bài viết về câu chuyện, sứ mệnh và giá trị thương hiệu ALOO.', 1, N'ACTIVE'),
    (N'Review', N'review', N'ARTICLE', N'Bài review trải nghiệm cửa hàng, món ăn và địa điểm.', 2, N'ACTIVE'),
    (N'Địa điểm ăn uống', N'dia-diem-an-uong', N'ARTICLE', N'Nội dung SEO địa điểm ăn uống và kem bơ ngon.', 3, N'ACTIVE'),
    (N'Nhượng quyền', N'nhuong-quyen', N'ARTICLE', N'Tin tức và kiến thức về mô hình nhượng quyền ALOO.', 4, N'ACTIVE'),
    (N'Tin tức', N'tin-tuc', N'ARTICLE', N'Tin mới về thương hiệu, sản phẩm và hoạt động ALOO.', 5, N'ACTIVE'),
    (N'Kem bơ', N'kem-bo', N'PRODUCT', N'Nhóm sản phẩm kem bơ chủ lực.', 1, N'ACTIVE'),
    (N'Đồ uống', N'do-uong', N'PRODUCT', N'Sinh tố, đồ uống và thức uống theo mùa.', 2, N'ACTIVE'),
    (N'Combo', N'combo', N'PRODUCT', N'Combo sản phẩm cho nhóm khách hàng.', 3, N'ACTIVE'),
    (N'Topping', N'topping', N'PRODUCT', N'Topping dùng kèm kem bơ và đồ uống.', 4, N'ACTIVE');
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.products)
BEGIN
    INSERT INTO dbo.products (category_id, name, slug, description, price, image_url, sort_order, status) VALUES
    ((SELECT id FROM dbo.categories WHERE type = N'PRODUCT' AND slug = N'kem-bo'), N'Kem bơ truyền thống', N'kem-bo-truyen-thong', N'Bơ xay mịn, kem sữa vàng kem và topping dừa sấy giòn.', 39000, N'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=900&q=80', 1, N'ACTIVE'),
    ((SELECT id FROM dbo.categories WHERE type = N'PRODUCT' AND slug = N'kem-bo'), N'Kem bơ sầu riêng', N'kem-bo-sau-rieng', N'Vị bơ béo thanh kết hợp sầu riêng thơm đậm, hợp khẩu vị Việt.', 49000, N'https://images.unsplash.com/photo-1497034825429-c343d7c6a68f?auto=format&fit=crop&w=900&q=80', 2, N'ACTIVE'),
    ((SELECT id FROM dbo.categories WHERE type = N'PRODUCT' AND slug = N'do-uong'), N'Sinh tố bơ kem', N'sinh-to-bo-kem', N'Sinh tố bơ sánh mịn, thêm viên kem vàng kem mát lạnh.', 35000, N'https://images.unsplash.com/photo-1505252585461-04db1eb84625?auto=format&fit=crop&w=900&q=80', 3, N'INACTIVE'),
    ((SELECT id FROM dbo.categories WHERE type = N'PRODUCT' AND slug = N'kem-bo'), N'Kem bơ cacao', N'kem-bo-cacao', N'Nền bơ mềm béo, cacao đắng nhẹ và hạt rang thơm.', 45000, N'https://images.unsplash.com/photo-1551024601-bec78aea704b?auto=format&fit=crop&w=900&q=80', 4, N'ACTIVE');
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.posts)
BEGIN
    INSERT INTO dbo.posts (category_id, title, slug, excerpt, content, thumbnail_url, author, article_type, status, published_at, seo_title, seo_description, tags) VALUES
    ((SELECT id FROM dbo.categories WHERE type = N'ARTICLE' AND slug = N'gioi-thieu-thuong-hieu'), N'Câu chuyện kem bơ thuần Việt của ALOO', N'cau-chuyen-kem-bo-thuan-viet-cua-aloo', N'Hành trình xây dựng hương vị kem bơ gần gũi với người Việt.', N'<h2>Giới thiệu</h2><p>ALOO phát triển từ ý tưởng đưa món kem bơ quen thuộc vào mô hình cửa hàng hiện đại, dễ nhân rộng.</p>', N'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=900&q=80', N'ALOO Editorial', N'Câu chuyện thương hiệu', N'PUBLISHED', SYSUTCDATETIME(), N'Câu chuyện kem bơ thuần Việt của ALOO', N'Hành trình xây dựng hương vị kem bơ gần gũi với người Việt.', N'kem bơ,ALOO,thương hiệu'),
    ((SELECT id FROM dbo.categories WHERE type = N'ARTICLE' AND slug = N'nhuong-quyen'), N'Vì sao kiosk kem bơ phù hợp khu dân cư', N'vi-sao-kiosk-kem-bo-phu-hop-khu-dan-cu', N'Mô hình kiosk giúp tối ưu chi phí và tiếp cận khách hàng thường xuyên.', N'<h2>Kiosk F&B</h2><p>Kiosk kem bơ phù hợp khu dân cư nhờ menu gọn, tốc độ phục vụ nhanh và chi phí vận hành dễ kiểm soát.</p>', N'https://images.unsplash.com/photo-1551024601-bec78aea704b?auto=format&fit=crop&w=900&q=80', N'ALOO Editorial', N'Bài SEO', N'DRAFT', NULL, N'Vì sao kiosk kem bơ phù hợp khu dân cư', N'Mô hình kiosk giúp tối ưu chi phí và tiếp cận khách hàng thường xuyên.', N'kiosk,nhượng quyền'),
    ((SELECT id FROM dbo.categories WHERE type = N'ARTICLE' AND slug = N'tin-tuc'), N'Checklist khai trương cửa hàng kem bơ', N'checklist-khai-truong-cua-hang-kem-bo', N'Các hạng mục cần chuẩn bị trước ngày khai trương điểm bán ALOO.', N'<h2>Checklist</h2><p>Checklist gồm mặt bằng, thiết bị, nguyên liệu, đào tạo nhân sự, truyền thông và vận hành thử.</p>', N'https://images.unsplash.com/photo-1521305916504-4a1121188589?auto=format&fit=crop&w=900&q=80', N'ALOO Editorial', N'Hướng dẫn nhượng quyền', N'PENDING', NULL, N'Checklist khai trương cửa hàng kem bơ', N'Các hạng mục cần chuẩn bị trước ngày khai trương điểm bán ALOO.', N'khai trương,checklist');
END
GO

DECLARE @blogSeedNow DATETIME2(0) = SYSUTCDATETIME();

IF NOT EXISTS (SELECT 1 FROM dbo.posts WHERE slug = N'5-ly-do-khach-hang-yeu-kem-bo-aloo')
BEGIN
    INSERT INTO dbo.posts (category_id, title, slug, excerpt, content, thumbnail_url, author, article_type, status, published_at, seo_title, seo_description, tags)
    VALUES ((SELECT id FROM dbo.categories WHERE type = N'ARTICLE' AND slug = N'gioi-thieu-thuong-hieu'), N'5 lý do khách hàng yêu kem bơ ALOO', N'5-ly-do-khach-hang-yeu-kem-bo-aloo', N'Từ vị bơ sáp mịn đến cách phục vụ nhanh, ALOO tạo trải nghiệm dễ nhớ cho khách hàng.', N'<h2>Hương vị dễ nhớ</h2><p>Kem bơ ALOO tập trung vào độ mịn, vị béo thanh và topping vừa đủ để khách quay lại thường xuyên.</p><h2>Trải nghiệm cửa hàng</h2><p>Không gian gọn, nhận diện rõ và quy trình phục vụ ổn định giúp thương hiệu dễ nhân rộng.</p>', N'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=1200&q=85', N'ALOO Editorial', N'Câu chuyện thương hiệu', N'PUBLISHED', DATEADD(day, -1, @blogSeedNow), N'5 lý do khách hàng yêu kem bơ ALOO', N'Những yếu tố giúp kem bơ ALOO tạo trải nghiệm dễ nhớ.', N'kem bơ,ALOO,thương hiệu');
END
GO

DECLARE @blogSeedNow DATETIME2(0) = SYSUTCDATETIME();

IF NOT EXISTS (SELECT 1 FROM dbo.posts WHERE slug = N'mo-hinh-nhuong-quyen-kiosk-kem-bo-can-gi')
BEGIN
    INSERT INTO dbo.posts (category_id, title, slug, excerpt, content, thumbnail_url, author, article_type, status, published_at, seo_title, seo_description, tags)
    VALUES ((SELECT id FROM dbo.categories WHERE type = N'ARTICLE' AND slug = N'nhuong-quyen'), N'Mô hình nhượng quyền kiosk kem bơ cần chuẩn bị gì?', N'mo-hinh-nhuong-quyen-kiosk-kem-bo-can-gi', N'Các hạng mục cần chuẩn bị trước khi mở kiosk kem bơ ở khu dân cư hoặc tuyến phố đông khách.', N'<h2>Mặt bằng</h2><p>Kiosk cần vị trí dễ nhìn, lưu lượng ổn định và đủ không gian bảo quản nguyên liệu.</p><h2>Vận hành</h2><p>Điểm quan trọng là quy trình định lượng, đào tạo nhân sự và kiểm soát chất lượng mỗi ngày.</p>', N'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=1200&q=85', N'ALOO Franchise Team', N'Hướng dẫn nhượng quyền', N'PUBLISHED', DATEADD(day, -2, @blogSeedNow), N'Mô hình nhượng quyền kiosk kem bơ cần chuẩn bị gì?', N'Checklist chuẩn bị mô hình kiosk kem bơ.', N'nhượng quyền,kiosk,vận hành');
END
GO

DECLARE @blogSeedNow DATETIME2(0) = SYSUTCDATETIME();

IF NOT EXISTS (SELECT 1 FROM dbo.posts WHERE slug = N'review-kem-bo-truyen-thong-aloo')
BEGIN
    INSERT INTO dbo.posts (category_id, title, slug, excerpt, content, thumbnail_url, author, article_type, status, published_at, seo_title, seo_description, tags)
    VALUES ((SELECT id FROM dbo.categories WHERE type = N'ARTICLE' AND slug = N'review'), N'Review kem bơ truyền thống ALOO', N'review-kem-bo-truyen-thong-aloo', N'Món signature giữ vị bơ sáp tự nhiên, kem mát và phần topping cân bằng.', N'<h2>Vị bơ</h2><p>Phần bơ được xay mịn, giữ độ béo tự nhiên nhưng không quá ngọt.</p><h2>Topping</h2><p>Topping dừa, kem và sốt được dùng vừa đủ để món ăn có nhiều tầng vị.</p>', N'https://images.unsplash.com/photo-1497034825429-c343d7c6a68f?auto=format&fit=crop&w=1200&q=85', N'ALOO Editorial', N'Review địa điểm', N'PUBLISHED', DATEADD(day, -3, @blogSeedNow), N'Review kem bơ truyền thống ALOO', N'Đánh giá món kem bơ truyền thống ALOO.', N'review,kem bơ,sản phẩm');
END
GO

DECLARE @blogSeedNow DATETIME2(0) = SYSUTCDATETIME();

IF NOT EXISTS (SELECT 1 FROM dbo.posts WHERE slug = N'dia-diem-an-kem-bo-o-tphcm')
BEGIN
    INSERT INTO dbo.posts (category_id, title, slug, excerpt, content, thumbnail_url, author, article_type, status, published_at, seo_title, seo_description, tags)
    VALUES ((SELECT id FROM dbo.categories WHERE type = N'ARTICLE' AND slug = N'dia-diem-an-uong'), N'Địa điểm ăn kem bơ ở TP.HCM cho cuối tuần', N'dia-diem-an-kem-bo-o-tphcm', N'Gợi ý cách chọn điểm ăn kem bơ thuận tiện cho nhóm bạn, gia đình và khách văn phòng.', N'<h2>Vị trí thuận tiện</h2><p>Điểm bán tốt nên dễ tìm, có chỗ dừng xe và phù hợp nhiều khung giờ trong ngày.</p><h2>Trải nghiệm nhóm</h2><p>Menu gọn, món ra nhanh và không gian sạch giúp buổi hẹn cuối tuần nhẹ nhàng hơn.</p>', N'https://images.unsplash.com/photo-1514933651103-005eec06c04b?auto=format&fit=crop&w=1200&q=85', N'ALOO Editorial', N'Bài SEO', N'PUBLISHED', DATEADD(day, -4, @blogSeedNow), N'Địa điểm ăn kem bơ ở TP.HCM cho cuối tuần', N'Gợi ý địa điểm ăn kem bơ ở TP.HCM.', N'TP.HCM,địa điểm,kem bơ');
END
GO

DECLARE @blogSeedNow DATETIME2(0) = SYSUTCDATETIME();

IF NOT EXISTS (SELECT 1 FROM dbo.posts WHERE slug = N'quy-trinh-dao-tao-nhan-su-cua-hang-aloo')
BEGIN
    INSERT INTO dbo.posts (category_id, title, slug, excerpt, content, thumbnail_url, author, article_type, status, published_at, seo_title, seo_description, tags)
    VALUES ((SELECT id FROM dbo.categories WHERE type = N'ARTICLE' AND slug = N'nhuong-quyen'), N'Quy trình đào tạo nhân sự cửa hàng ALOO', N'quy-trinh-dao-tao-nhan-su-cua-hang-aloo', N'Đào tạo nhân sự tập trung vào định lượng, thao tác nhanh và thái độ phục vụ nhất quán.', N'<h2>Định lượng</h2><p>Công thức rõ giúp nhân sự mới nhanh chóng tạo sản phẩm ổn định.</p><h2>Dịch vụ</h2><p>Quy trình phục vụ ngắn, dễ nhớ và phù hợp mô hình cửa hàng đông khách.</p>', N'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=1200&q=85', N'ALOO Franchise Team', N'Hướng dẫn nhượng quyền', N'PUBLISHED', DATEADD(day, -5, @blogSeedNow), N'Quy trình đào tạo nhân sự cửa hàng ALOO', N'Cách ALOO đào tạo nhân sự vận hành cửa hàng.', N'đào tạo,vận hành,nhượng quyền');
END
GO

DECLARE @blogSeedNow DATETIME2(0) = SYSUTCDATETIME();

IF NOT EXISTS (SELECT 1 FROM dbo.posts WHERE slug = N'kem-bo-sau-rieng-co-gi-khac-biet')
BEGIN
    INSERT INTO dbo.posts (category_id, title, slug, excerpt, content, thumbnail_url, author, article_type, status, published_at, seo_title, seo_description, tags)
    VALUES ((SELECT id FROM dbo.categories WHERE type = N'ARTICLE' AND slug = N'review'), N'Kem bơ sầu riêng có gì khác biệt?', N'kem-bo-sau-rieng-co-gi-khac-biet', N'Phiên bản đậm vị hơn cho khách thích hương sầu riêng nhưng vẫn giữ nền bơ mềm mịn.', N'<h2>Hương vị</h2><p>Sầu riêng tạo điểm nhấn rõ, trong khi nền bơ giúp món ăn không bị gắt.</p><h2>Khách hàng phù hợp</h2><p>Món này hợp với khách thích vị nhiệt đới, béo và có mùi thơm đặc trưng.</p>', N'https://images.unsplash.com/photo-1505252585461-04db1eb84625?auto=format&fit=crop&w=1200&q=85', N'ALOO Editorial', N'Review địa điểm', N'PUBLISHED', DATEADD(day, -6, @blogSeedNow), N'Kem bơ sầu riêng có gì khác biệt?', N'Đánh giá vị kem bơ sầu riêng ALOO.', N'sầu riêng,kem bơ,review');
END
GO

DECLARE @blogSeedNow DATETIME2(0) = SYSUTCDATETIME();

IF NOT EXISTS (SELECT 1 FROM dbo.posts WHERE slug = N'cach-chon-mat-bang-ban-kem-bo')
BEGIN
    INSERT INTO dbo.posts (category_id, title, slug, excerpt, content, thumbnail_url, author, article_type, status, published_at, seo_title, seo_description, tags)
    VALUES ((SELECT id FROM dbo.categories WHERE type = N'ARTICLE' AND slug = N'nhuong-quyen'), N'Cách chọn mặt bằng bán kem bơ hiệu quả', N'cach-chon-mat-bang-ban-kem-bo', N'Mặt bằng tốt không chỉ đông người qua lại mà còn cần phù hợp thói quen mua đồ ăn vặt.', N'<h2>Lưu lượng khách</h2><p>Khu dân cư, trường học, văn phòng và tuyến phố ăn uống là nhóm vị trí đáng cân nhắc.</p><h2>Chi phí</h2><p>Chi phí thuê cần cân bằng với biên lợi nhuận và năng lực vận hành của cửa hàng.</p>', N'https://images.unsplash.com/photo-1521305916504-4a1121188589?auto=format&fit=crop&w=1200&q=85', N'ALOO Franchise Team', N'Bài SEO', N'PUBLISHED', DATEADD(day, -7, @blogSeedNow), N'Cách chọn mặt bằng bán kem bơ hiệu quả', N'Kinh nghiệm chọn mặt bằng bán kem bơ.', N'mặt bằng,kinh doanh,nhượng quyền');
END
GO

DECLARE @blogSeedNow DATETIME2(0) = SYSUTCDATETIME();

IF NOT EXISTS (SELECT 1 FROM dbo.posts WHERE slug = N'aloo-cap-nhat-menu-mua-he')
BEGIN
    INSERT INTO dbo.posts (category_id, title, slug, excerpt, content, thumbnail_url, author, article_type, status, published_at, seo_title, seo_description, tags)
    VALUES ((SELECT id FROM dbo.categories WHERE type = N'ARTICLE' AND slug = N'tin-tuc'), N'ALOO cập nhật menu mùa hè', N'aloo-cap-nhat-menu-mua-he', N'Một số món lạnh và topping mới được bổ sung để phù hợp nhu cầu giải nhiệt mùa hè.', N'<h2>Menu mùa hè</h2><p>Các món ưu tiên vị mát, thao tác nhanh và nguyên liệu dễ kiểm soát tại cửa hàng.</p><h2>Trải nghiệm khách hàng</h2><p>Menu mới giúp khách có thêm lựa chọn nhưng vẫn giữ nhóm sản phẩm chủ lực.</p>', N'https://images.unsplash.com/photo-1551024601-bec78aea704b?auto=format&fit=crop&w=1200&q=85', N'ALOO Editorial', N'Tin tức', N'PUBLISHED', DATEADD(day, -8, @blogSeedNow), N'ALOO cập nhật menu mùa hè', N'Cập nhật menu mùa hè của ALOO.', N'menu,tin tức,mùa hè');
END
GO

DECLARE @blogSeedNow DATETIME2(0) = SYSUTCDATETIME();

IF NOT EXISTS (SELECT 1 FROM dbo.posts WHERE slug = N'van-hanh-cua-hang-kem-bo-gio-cao-diem')
BEGIN
    INSERT INTO dbo.posts (category_id, title, slug, excerpt, content, thumbnail_url, author, article_type, status, published_at, seo_title, seo_description, tags)
    VALUES ((SELECT id FROM dbo.categories WHERE type = N'ARTICLE' AND slug = N'nhuong-quyen'), N'Vận hành cửa hàng kem bơ trong giờ cao điểm', N'van-hanh-cua-hang-kem-bo-gio-cao-diem', N'Chuẩn bị nguyên liệu, phân vai nhân sự và tối ưu luồng order giúp cửa hàng xử lý đơn nhanh hơn.', N'<h2>Chuẩn bị trước ca</h2><p>Nguyên liệu cần được chia sẵn theo định lượng để giảm thời gian thao tác.</p><h2>Phân vai</h2><p>Một người nhận order, một người chuẩn bị món và một người giao món giúp luồng phục vụ rõ ràng.</p>', N'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=1200&q=85', N'ALOO Franchise Team', N'Hướng dẫn nhượng quyền', N'PUBLISHED', DATEADD(day, -9, @blogSeedNow), N'Vận hành cửa hàng kem bơ trong giờ cao điểm', N'Kinh nghiệm vận hành cửa hàng kem bơ khi đông khách.', N'vận hành,cửa hàng,giờ cao điểm');
END
GO

DECLARE @blogSeedNow DATETIME2(0) = SYSUTCDATETIME();

IF NOT EXISTS (SELECT 1 FROM dbo.posts WHERE slug = N'nhan-dien-thuong-hieu-aloo-tai-diem-ban')
BEGIN
    INSERT INTO dbo.posts (category_id, title, slug, excerpt, content, thumbnail_url, author, article_type, status, published_at, seo_title, seo_description, tags)
    VALUES ((SELECT id FROM dbo.categories WHERE type = N'ARTICLE' AND slug = N'gioi-thieu-thuong-hieu'), N'Nhận diện thương hiệu ALOO tại điểm bán', N'nhan-dien-thuong-hieu-aloo-tai-diem-ban', N'Màu sắc, menu, bảng hiệu và cách trưng bày giúp khách nhận ra ALOO nhanh hơn.', N'<h2>Nhận diện</h2><p>Bộ nhận diện cần rõ ràng từ xa, dễ nhớ và đồng bộ giữa các điểm bán.</p><h2>Trưng bày</h2><p>Menu, hình ảnh sản phẩm và khu vực order nên được sắp xếp để khách ra quyết định nhanh.</p>', N'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=1200&q=85', N'ALOO Editorial', N'Câu chuyện thương hiệu', N'PUBLISHED', DATEADD(day, -10, @blogSeedNow), N'Nhận diện thương hiệu ALOO tại điểm bán', N'Cách ALOO xây dựng nhận diện tại cửa hàng.', N'nhận diện,thương hiệu,cửa hàng');
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.locations)
BEGIN
    INSERT INTO dbo.locations (name, address, province, district, phone, opening_hours, map_url, image_url, amenities_json, display_order, featured, status) VALUES
    (N'ALOO Nguyễn Trãi', N'128 Nguyễn Trãi, Phường Bến Thành', N'TP.HCM', N'Quận 1', N'0900 888 168', N'09:00 - 22:00', N'https://maps.google.com/?q=128+Nguyen+Trai+TPHCM', N'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=900&q=80', N'["Wifi","Máy lạnh","Thanh toán thẻ","Mang đi"]', 1, 1, N'ACTIVE'),
    (N'ALOO Phú Mỹ Hưng', N'45 Nguyễn Đức Cảnh, Khu Phú Mỹ Hưng', N'TP.HCM', N'Quận 7', N'0901 222 168', N'10:00 - 22:30', N'https://maps.google.com/?q=45+Nguyen+Duc+Canh+Quan+7', N'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=900&q=80', N'["Wifi","Chỗ đậu xe","Thanh toán thẻ","Mang đi"]', 2, 1, N'ACTIVE'),
    (N'ALOO Hải Châu', N'82 Bạch Đằng, Quận Hải Châu', N'Đà Nẵng', N'Hải Châu', N'0902 333 168', N'09:30 - 22:00', N'https://maps.google.com/?q=82+Bach+Dang+Da+Nang', N'https://images.unsplash.com/photo-1514933651103-005eec06c04b?auto=format&fit=crop&w=900&q=80', N'["Wifi","Máy lạnh","Mang đi"]', 3, 0, N'COMING_SOON');
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.franchise_contents)
BEGIN
    INSERT INTO dbo.franchise_contents (section_key, title, content, amount, note, sort_order, status) VALUES
    (N'benefits', N'Công thức đồng bộ', N'Định lượng, topping và quy trình pha chế để đào tạo nhanh.', NULL, NULL, 1, N'ACTIVE'),
    (N'benefits', N'Nhận diện sẵn sàng', N'Bộ màu, menu, bảng hiệu và vật phẩm bán hàng thống nhất.', NULL, NULL, 2, N'ACTIVE'),
    (N'benefits', N'Hỗ trợ khai trương', N'Checklist vận hành, truyền thông tại điểm bán và theo dõi sau mở bán.', NULL, NULL, 3, N'ACTIVE'),
    (N'conditions', N'Mặt bằng', N'Diện tích từ 12m2, mặt tiền dễ nhận diện và có khu vực bảo quản nguyên liệu.', NULL, NULL, 1, N'ACTIVE'),
    (N'conditions', N'Vốn đầu tư', N'Nguồn vốn phù hợp với gói kiosk, cửa hàng tiêu chuẩn hoặc flagship mini.', NULL, NULL, 2, N'ACTIVE'),
    (N'process', N'Tiếp nhận thông tin', N'Đội ngũ ALOO liên hệ và xác nhận nhu cầu đầu tư.', NULL, NULL, 1, N'ACTIVE'),
    (N'process', N'Khảo sát khu vực', N'Đánh giá lưu lượng khách, đối thủ và mức chi phí mặt bằng.', NULL, NULL, 2, N'ACTIVE'),
    (N'process', N'Triển khai cửa hàng', N'Thiết kế, lắp đặt, đào tạo và chuẩn bị khai trương.', NULL, NULL, 3, N'ACTIVE'),
    (N'costs', N'Gói xe đẩy / kiosk', NULL, N'120 - 180 triệu', N'Phù hợp điểm bán nhỏ, chi phí gọn.', 1, N'ACTIVE'),
    (N'costs', N'Gói cửa hàng tiêu chuẩn', NULL, N'280 - 450 triệu', N'Dành cho mặt bằng phố hoặc trung tâm khu dân cư.', 2, N'ACTIVE'),
    (N'costs', N'Gói flagship mini', NULL, N'500 - 750 triệu', N'Không gian trải nghiệm đầy đủ và nhận diện nổi bật.', 3, N'ACTIVE');
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.hero_banners)
BEGIN
    INSERT INTO dbo.hero_banners (title, subtitle, description, background_image_url, product_image_url, thumbnail_image_url, tone, sort_order, status) VALUES
    (N'Kem bơ truyền thống', N'Signature ALOO', N'Bơ sáp chín tự nhiên hòa cùng kem tươi mát lạnh, tạo vị béo mịn và thơm nhẹ.', N'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=1800&q=80', N'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=1200&q=85', N'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=300&q=80', N'light', 1, N'ACTIVE'),
    (N'Kem bơ sầu riêng', N'Tropical Bold', N'Lớp bơ mịn kết hợp sầu riêng đậm vị, dành cho khách thích hương nhiệt đới rõ nét.', N'https://images.unsplash.com/photo-1497034825429-c343d7c6a68f?auto=format&fit=crop&w=1800&q=80', N'https://images.unsplash.com/photo-1497034825429-c343d7c6a68f?auto=format&fit=crop&w=1200&q=85', N'https://images.unsplash.com/photo-1497034825429-c343d7c6a68f?auto=format&fit=crop&w=300&q=80', N'dark', 2, N'ACTIVE');
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.menu_posters)
BEGIN
    INSERT INTO dbo.menu_posters (branch_key, title, subtitle, image_url, alt_text, sort_order, status) VALUES
    (N'quy-nhon', N'ALOO Menu Quy Nhơn', N'Menu Poster', N'/menu-poster.png', N'Poster menu ALOO Quy Nhơn', 1, N'ACTIVE'),
    (N'nha-trang', N'ALOO Menu Nha Trang', N'Menu Poster', N'https://images.unsplash.com/photo-1551024601-bec78aea704b?auto=format&fit=crop&w=1600&q=85', N'Poster menu ALOO Nha Trang', 2, N'ACTIVE');
END
GO
