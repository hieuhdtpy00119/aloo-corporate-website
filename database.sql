/*
  ALOO Franchise CMS - SQL Server production-ready schema
  Scope: corporate website + admin CMS + franchise lead management.
  Excludes ecommerce/cart/payment modules by design.

  Status/category values are stored as English enum-like codes.
  The frontend/backend should map these codes to Vietnamese display labels.
  Public APIs should filter translated content by language_code, for example:
  GET /api/products?lang=vi or GET /api/products?lang=en.
*/

USE master;
GO

IF DB_ID(N'ALOO_Franchise_CMS') IS NOT NULL
BEGIN
  ALTER DATABASE ALOO_Franchise_CMS SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  DROP DATABASE ALOO_Franchise_CMS;
END
GO

CREATE DATABASE ALOO_Franchise_CMS;
GO

USE ALOO_Franchise_CMS;
GO

/* Re-runnable cleanup, ordered by foreign key dependencies. */
DROP TABLE IF EXISTS dbo.contacts;
DROP TABLE IF EXISTS dbo.site_settings;
DROP TABLE IF EXISTS dbo.franchise_contents;
DROP TABLE IF EXISTS dbo.locations;
DROP TABLE IF EXISTS dbo.franchise_registrations;
DROP TABLE IF EXISTS dbo.posts;
DROP TABLE IF EXISTS dbo.banners;
DROP TABLE IF EXISTS dbo.products;
DROP TABLE IF EXISTS dbo.users;
GO

/* users: CMS admin accounts. Store normalized lowercase emails and BCrypt hashes. */
CREATE TABLE dbo.users (
  id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT pk_users PRIMARY KEY,
  full_name NVARCHAR(150) NOT NULL,
  email NVARCHAR(255) NOT NULL,
  password_hash NVARCHAR(255) NOT NULL,
  role NVARCHAR(50) NOT NULL CONSTRAINT df_users_role DEFAULT N'ADMIN',
  status NVARCHAR(30) NOT NULL CONSTRAINT df_users_status DEFAULT N'ACTIVE',
  last_login_at DATETIME2(0) NULL,
  created_at DATETIME2(0) NOT NULL CONSTRAINT df_users_created_at DEFAULT SYSUTCDATETIME(),
  updated_at DATETIME2(0) NOT NULL CONSTRAINT df_users_updated_at DEFAULT SYSUTCDATETIME(),
  CONSTRAINT uq_users_email UNIQUE (email),
  CONSTRAINT ck_users_role CHECK (role IN (N'SUPER_ADMIN', N'ADMIN', N'EDITOR')),
  CONSTRAINT ck_users_status CHECK (status IN (N'ACTIVE', N'INACTIVE', N'LOCKED'))
);
GO

/* products: public product/menu items managed by CMS. */
CREATE TABLE dbo.products (
  id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT pk_products PRIMARY KEY,
  name NVARCHAR(180) NOT NULL,
  slug NVARCHAR(220) NOT NULL,
  description NVARCHAR(MAX) NULL,
  price DECIMAL(18,2) NOT NULL CONSTRAINT df_products_price DEFAULT 0,
  image_url NVARCHAR(1000) NULL,
  category NVARCHAR(80) NOT NULL,
  language_code NVARCHAR(10) NOT NULL CONSTRAINT df_products_language_code DEFAULT N'vi',
  status NVARCHAR(30) NOT NULL CONSTRAINT df_products_status DEFAULT N'ACTIVE',
  sort_order INT NOT NULL CONSTRAINT df_products_sort_order DEFAULT 0,
  created_by_user_id BIGINT NULL,
  updated_by_user_id BIGINT NULL,
  created_at DATETIME2(0) NOT NULL CONSTRAINT df_products_created_at DEFAULT SYSUTCDATETIME(),
  updated_at DATETIME2(0) NOT NULL CONSTRAINT df_products_updated_at DEFAULT SYSUTCDATETIME(),
  CONSTRAINT uq_products_slug_language UNIQUE (slug, language_code),
  CONSTRAINT ck_products_price CHECK (price >= 0),
  CONSTRAINT ck_products_language_code CHECK (language_code IN (N'vi', N'en')),
  CONSTRAINT ck_products_category CHECK (category IN (N'AVOCADO_ICE_CREAM', N'COMBO', N'DRINK', N'SEASONAL', N'OTHER')),
  CONSTRAINT ck_products_status CHECK (status IN (N'ACTIVE', N'INACTIVE', N'HIDDEN')),
  CONSTRAINT fk_products_created_by_user FOREIGN KEY (created_by_user_id) REFERENCES dbo.users(id),
  CONSTRAINT fk_products_updated_by_user FOREIGN KEY (updated_by_user_id) REFERENCES dbo.users(id)
);
GO

/* banners: hero and marketing banners for public website sections. */
CREATE TABLE dbo.banners (
  id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT pk_banners PRIMARY KEY,
  title NVARCHAR(220) NOT NULL,
  subtitle NVARCHAR(500) NULL,
  image_url NVARCHAR(1000) NOT NULL,
  button_text NVARCHAR(100) NULL,
  button_link NVARCHAR(500) NULL,
  position NVARCHAR(100) NOT NULL CONSTRAINT df_banners_position DEFAULT N'HOME',
  language_code NVARCHAR(10) NOT NULL CONSTRAINT df_banners_language_code DEFAULT N'vi',
  status NVARCHAR(30) NOT NULL CONSTRAINT df_banners_status DEFAULT N'ACTIVE',
  sort_order INT NOT NULL CONSTRAINT df_banners_sort_order DEFAULT 0,
  created_by_user_id BIGINT NULL,
  updated_by_user_id BIGINT NULL,
  created_at DATETIME2(0) NOT NULL CONSTRAINT df_banners_created_at DEFAULT SYSUTCDATETIME(),
  updated_at DATETIME2(0) NOT NULL CONSTRAINT df_banners_updated_at DEFAULT SYSUTCDATETIME(),
  CONSTRAINT ck_banners_position CHECK (position IN (N'HOME', N'PRODUCTS', N'FRANCHISE', N'BLOG')),
  CONSTRAINT ck_banners_language_code CHECK (language_code IN (N'vi', N'en')),
  CONSTRAINT ck_banners_status CHECK (status IN (N'ACTIVE', N'INACTIVE', N'HIDDEN')),
  CONSTRAINT fk_banners_created_by_user FOREIGN KEY (created_by_user_id) REFERENCES dbo.users(id),
  CONSTRAINT fk_banners_updated_by_user FOREIGN KEY (updated_by_user_id) REFERENCES dbo.users(id)
);
GO

/* posts: blog/news/brand story content. */
CREATE TABLE dbo.posts (
  id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT pk_posts PRIMARY KEY,
  title NVARCHAR(250) NOT NULL,
  slug NVARCHAR(280) NOT NULL,
  excerpt NVARCHAR(600) NULL,
  content NVARCHAR(MAX) NOT NULL,
  thumbnail_url NVARCHAR(1000) NULL,
  category NVARCHAR(50) NOT NULL,
  language_code NVARCHAR(10) NOT NULL CONSTRAINT df_posts_language_code DEFAULT N'vi',
  status NVARCHAR(30) NOT NULL CONSTRAINT df_posts_status DEFAULT N'DRAFT',
  published_at DATETIME2(0) NULL,
  created_by_user_id BIGINT NULL,
  updated_by_user_id BIGINT NULL,
  created_at DATETIME2(0) NOT NULL CONSTRAINT df_posts_created_at DEFAULT SYSUTCDATETIME(),
  updated_at DATETIME2(0) NOT NULL CONSTRAINT df_posts_updated_at DEFAULT SYSUTCDATETIME(),
  CONSTRAINT uq_posts_slug_language UNIQUE (slug, language_code),
  CONSTRAINT ck_posts_language_code CHECK (language_code IN (N'vi', N'en')),
  CONSTRAINT ck_posts_category CHECK (category IN (N'BRAND', N'PRODUCT', N'FRANCHISE', N'OPERATION', N'NEWS')),
  CONSTRAINT ck_posts_status CHECK (status IN (N'DRAFT', N'PUBLISHED', N'SCHEDULED', N'ARCHIVED')),
  CONSTRAINT fk_posts_created_by_user FOREIGN KEY (created_by_user_id) REFERENCES dbo.users(id),
  CONSTRAINT fk_posts_updated_by_user FOREIGN KEY (updated_by_user_id) REFERENCES dbo.users(id)
);
GO

/* franchise_registrations: franchise consultation leads from public form. */
CREATE TABLE dbo.franchise_registrations (
  id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT pk_franchise_registrations PRIMARY KEY,
  full_name NVARCHAR(150) NOT NULL,
  phone NVARCHAR(30) NOT NULL,
  email NVARCHAR(255) NULL,
  province NVARCHAR(120) NOT NULL,
  expected_budget DECIMAL(18,2) NULL,
  note NVARCHAR(MAX) NULL,
  status NVARCHAR(30) NOT NULL CONSTRAINT df_franchise_registrations_status DEFAULT N'NEW',
  assigned_to_user_id BIGINT NULL,
  created_at DATETIME2(0) NOT NULL CONSTRAINT df_franchise_registrations_created_at DEFAULT SYSUTCDATETIME(),
  updated_at DATETIME2(0) NOT NULL CONSTRAINT df_franchise_registrations_updated_at DEFAULT SYSUTCDATETIME(),
  CONSTRAINT ck_franchise_registrations_budget CHECK (expected_budget IS NULL OR expected_budget >= 0),
  CONSTRAINT ck_franchise_registrations_status CHECK (status IN (N'NEW', N'CONTACTED', N'CONSULTING', N'COMPLETED', N'CANCELLED')),
  CONSTRAINT fk_franchise_registrations_assigned_to_user FOREIGN KEY (assigned_to_user_id) REFERENCES dbo.users(id)
);
GO

/* locations: store locations shown on public website. */
CREATE TABLE dbo.locations (
  id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT pk_locations PRIMARY KEY,
  name NVARCHAR(180) NOT NULL,
  address NVARCHAR(500) NOT NULL,
  province NVARCHAR(120) NOT NULL,
  phone NVARCHAR(30) NULL,
  opening_hours NVARCHAR(120) NULL,
  map_url NVARCHAR(1000) NULL,
  language_code NVARCHAR(10) NOT NULL CONSTRAINT df_locations_language_code DEFAULT N'vi',
  status NVARCHAR(30) NOT NULL CONSTRAINT df_locations_status DEFAULT N'ACTIVE',
  sort_order INT NOT NULL CONSTRAINT df_locations_sort_order DEFAULT 0,
  created_by_user_id BIGINT NULL,
  updated_by_user_id BIGINT NULL,
  created_at DATETIME2(0) NOT NULL CONSTRAINT df_locations_created_at DEFAULT SYSUTCDATETIME(),
  updated_at DATETIME2(0) NOT NULL CONSTRAINT df_locations_updated_at DEFAULT SYSUTCDATETIME(),
  CONSTRAINT ck_locations_language_code CHECK (language_code IN (N'vi', N'en')),
  CONSTRAINT ck_locations_status CHECK (status IN (N'ACTIVE', N'COMING_SOON', N'CLOSED')),
  CONSTRAINT fk_locations_created_by_user FOREIGN KEY (created_by_user_id) REFERENCES dbo.users(id),
  CONSTRAINT fk_locations_updated_by_user FOREIGN KEY (updated_by_user_id) REFERENCES dbo.users(id)
);
GO

/* franchise_contents: reusable content blocks for franchise pages. */
CREATE TABLE dbo.franchise_contents (
  id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT pk_franchise_contents PRIMARY KEY,
  section_key NVARCHAR(50) NOT NULL,
  title NVARCHAR(220) NOT NULL,
  content NVARCHAR(MAX) NOT NULL,
  language_code NVARCHAR(10) NOT NULL CONSTRAINT df_franchise_contents_language_code DEFAULT N'vi',
  sort_order INT NOT NULL CONSTRAINT df_franchise_contents_sort_order DEFAULT 0,
  status NVARCHAR(30) NOT NULL CONSTRAINT df_franchise_contents_status DEFAULT N'ACTIVE',
  created_by_user_id BIGINT NULL,
  updated_by_user_id BIGINT NULL,
  created_at DATETIME2(0) NOT NULL CONSTRAINT df_franchise_contents_created_at DEFAULT SYSUTCDATETIME(),
  updated_at DATETIME2(0) NOT NULL CONSTRAINT df_franchise_contents_updated_at DEFAULT SYSUTCDATETIME(),
  CONSTRAINT ck_franchise_contents_section_key CHECK (section_key IN (N'BENEFITS', N'CONDITIONS', N'PROCESS', N'COSTS')),
  CONSTRAINT ck_franchise_contents_language_code CHECK (language_code IN (N'vi', N'en')),
  CONSTRAINT ck_franchise_contents_status CHECK (status IN (N'ACTIVE', N'INACTIVE', N'HIDDEN')),
  CONSTRAINT fk_franchise_contents_created_by_user FOREIGN KEY (created_by_user_id) REFERENCES dbo.users(id),
  CONSTRAINT fk_franchise_contents_updated_by_user FOREIGN KEY (updated_by_user_id) REFERENCES dbo.users(id)
);
GO

/* site_settings: editable global settings for contact info, SEO and assets. */
CREATE TABLE dbo.site_settings (
  id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT pk_site_settings PRIMARY KEY,
  setting_key NVARCHAR(120) NOT NULL,
  setting_value NVARCHAR(MAX) NULL,
  group_name NVARCHAR(80) NOT NULL CONSTRAINT df_site_settings_group_name DEFAULT N'GENERAL',
  language_code NVARCHAR(10) NOT NULL CONSTRAINT df_site_settings_language_code DEFAULT N'vi',
  created_at DATETIME2(0) NOT NULL CONSTRAINT df_site_settings_created_at DEFAULT SYSUTCDATETIME(),
  updated_at DATETIME2(0) NOT NULL CONSTRAINT df_site_settings_updated_at DEFAULT SYSUTCDATETIME(),
  CONSTRAINT uq_site_settings_key_language UNIQUE (setting_key, language_code),
  CONSTRAINT ck_site_settings_language_code CHECK (language_code IN (N'vi', N'en')),
  CONSTRAINT ck_site_settings_group_name CHECK (group_name IN (N'GENERAL', N'CONTACT', N'SOCIAL', N'SEO', N'BRAND'))
);
GO

/* contacts: optional contact messages from public website. */
CREATE TABLE dbo.contacts (
  id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT pk_contacts PRIMARY KEY,
  full_name NVARCHAR(150) NOT NULL,
  phone NVARCHAR(30) NULL,
  email NVARCHAR(255) NULL,
  subject NVARCHAR(220) NOT NULL,
  message NVARCHAR(MAX) NOT NULL,
  status NVARCHAR(30) NOT NULL CONSTRAINT df_contacts_status DEFAULT N'NEW',
  assigned_to_user_id BIGINT NULL,
  created_at DATETIME2(0) NOT NULL CONSTRAINT df_contacts_created_at DEFAULT SYSUTCDATETIME(),
  updated_at DATETIME2(0) NOT NULL CONSTRAINT df_contacts_updated_at DEFAULT SYSUTCDATETIME(),
  CONSTRAINT ck_contacts_status CHECK (status IN (N'NEW', N'READ', N'REPLIED', N'ARCHIVED')),
  CONSTRAINT fk_contacts_assigned_to_user FOREIGN KEY (assigned_to_user_id) REFERENCES dbo.users(id)
);
GO

/* Indexes for public reads, admin filters, search and dashboard counts. */
CREATE INDEX ix_users_status_role ON dbo.users(status, role);

CREATE INDEX ix_products_language ON dbo.products(language_code);
CREATE INDEX ix_products_status_language_sort ON dbo.products(status, language_code, sort_order);
CREATE INDEX ix_products_category_language_status ON dbo.products(category, language_code, status);

CREATE INDEX ix_banners_language ON dbo.banners(language_code);
CREATE INDEX ix_banners_position_status_language_sort ON dbo.banners(position, status, language_code, sort_order);

CREATE INDEX ix_posts_language ON dbo.posts(language_code);
CREATE INDEX ix_posts_status_language_published_at ON dbo.posts(status, language_code, published_at DESC);
CREATE INDEX ix_posts_category_language_status_published_at ON dbo.posts(category, language_code, status, published_at DESC);

CREATE INDEX ix_franchise_registrations_status_created_at ON dbo.franchise_registrations(status, created_at DESC);
CREATE INDEX ix_franchise_registrations_email ON dbo.franchise_registrations(email) WHERE email IS NOT NULL;
CREATE INDEX ix_franchise_registrations_phone ON dbo.franchise_registrations(phone);

CREATE INDEX ix_locations_language ON dbo.locations(language_code);
CREATE INDEX ix_locations_province_status_language_sort ON dbo.locations(province, status, language_code, sort_order);
CREATE INDEX ix_locations_status_language_sort ON dbo.locations(status, language_code, sort_order);

CREATE INDEX ix_franchise_contents_language ON dbo.franchise_contents(language_code);
CREATE INDEX ix_franchise_contents_section_status_language_sort ON dbo.franchise_contents(section_key, status, language_code, sort_order);

CREATE INDEX ix_site_settings_language ON dbo.site_settings(language_code);
CREATE INDEX ix_site_settings_group_language ON dbo.site_settings(group_name, language_code);

CREATE INDEX ix_contacts_status_created_at ON dbo.contacts(status, created_at DESC);
CREATE INDEX ix_contacts_email ON dbo.contacts(email) WHERE email IS NOT NULL;
GO

/* Auto-maintain updated_at for SQL-side updates.
   In Spring Boot, @PreUpdate should also set updatedAt for entity consistency. */
CREATE TRIGGER trg_users_set_updated_at
ON dbo.users
AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;
  UPDATE t SET updated_at = SYSUTCDATETIME()
  FROM dbo.users t
  INNER JOIN inserted i ON t.id = i.id;
END;
GO

CREATE TRIGGER trg_products_set_updated_at
ON dbo.products
AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;
  UPDATE t SET updated_at = SYSUTCDATETIME()
  FROM dbo.products t
  INNER JOIN inserted i ON t.id = i.id;
END;
GO

CREATE TRIGGER trg_banners_set_updated_at
ON dbo.banners
AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;
  UPDATE t SET updated_at = SYSUTCDATETIME()
  FROM dbo.banners t
  INNER JOIN inserted i ON t.id = i.id;
END;
GO

CREATE TRIGGER trg_posts_set_updated_at
ON dbo.posts
AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;
  UPDATE t SET updated_at = SYSUTCDATETIME()
  FROM dbo.posts t
  INNER JOIN inserted i ON t.id = i.id;
END;
GO

CREATE TRIGGER trg_franchise_registrations_set_updated_at
ON dbo.franchise_registrations
AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;
  UPDATE t SET updated_at = SYSUTCDATETIME()
  FROM dbo.franchise_registrations t
  INNER JOIN inserted i ON t.id = i.id;
END;
GO

CREATE TRIGGER trg_locations_set_updated_at
ON dbo.locations
AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;
  UPDATE t SET updated_at = SYSUTCDATETIME()
  FROM dbo.locations t
  INNER JOIN inserted i ON t.id = i.id;
END;
GO

CREATE TRIGGER trg_franchise_contents_set_updated_at
ON dbo.franchise_contents
AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;
  UPDATE t SET updated_at = SYSUTCDATETIME()
  FROM dbo.franchise_contents t
  INNER JOIN inserted i ON t.id = i.id;
END;
GO

CREATE TRIGGER trg_site_settings_set_updated_at
ON dbo.site_settings
AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;
  UPDATE t SET updated_at = SYSUTCDATETIME()
  FROM dbo.site_settings t
  INNER JOIN inserted i ON t.id = i.id;
END;
GO

CREATE TRIGGER trg_contacts_set_updated_at
ON dbo.contacts
AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;
  UPDATE t SET updated_at = SYSUTCDATETIME()
  FROM dbo.contacts t
  INNER JOIN inserted i ON t.id = i.id;
END;
GO

/* Seed data for local development and backend integration testing. */
INSERT INTO dbo.users (full_name, email, password_hash, role, status)
VALUES
(N'ALOO Administrator', N'admin@aloo.vn', N'$2a$10$replace.with.real.bcrypt.hash.before.production', N'SUPER_ADMIN', N'ACTIVE');
GO

INSERT INTO dbo.products (name, slug, description, price, image_url, category, language_code, status, sort_order, created_by_user_id, updated_by_user_id)
VALUES
(N'Kem bơ truyền thống', N'kem-bo-truyen-thong', N'Bơ xay mịn, kem sữa vàng kem và topping dừa sấy giòn.', 39000, N'https://images.unsplash.com/photo-1563805042-7684c019e1cb', N'AVOCADO_ICE_CREAM', N'vi', N'ACTIVE', 1, 1, 1),
(N'Kem bơ sầu riêng', N'kem-bo-sau-rieng', N'Vị bơ béo thanh kết hợp sầu riêng thơm đậm.', 49000, N'https://images.unsplash.com/photo-1497034825429-c343d7c6a68f', N'AVOCADO_ICE_CREAM', N'vi', N'ACTIVE', 2, 1, 1),
(N'Sinh tố bơ kem', N'sinh-to-bo-kem', N'Sinh tố bơ sánh mịn, thêm viên kem vàng kem mát lạnh.', 35000, N'https://images.unsplash.com/photo-1505252585461-04db1eb84625', N'DRINK', N'vi', N'ACTIVE', 3, 1, 1),
(N'Kem bơ cacao', N'kem-bo-cacao', N'Nền bơ mềm béo, cacao đắng nhẹ và hạt rang thơm.', 45000, N'https://images.unsplash.com/photo-1551024601-bec78aea704b', N'SEASONAL', N'vi', N'ACTIVE', 4, 1, 1),
(N'Combo kem bơ gia đình', N'combo-kem-bo-gia-dinh', N'Combo nhiều phần phù hợp nhóm bạn và gia đình.', 159000, N'https://images.unsplash.com/photo-1488900128323-21503983a07e', N'COMBO', N'vi', N'ACTIVE', 5, 1, 1),
(N'Classic avocado ice cream', N'classic-avocado-ice-cream', N'Smooth blended avocado, creamy golden ice cream and crispy coconut topping.', 39000, N'https://images.unsplash.com/photo-1563805042-7684c019e1cb', N'AVOCADO_ICE_CREAM', N'en', N'ACTIVE', 1, 1, 1),
(N'Durian avocado ice cream', N'durian-avocado-ice-cream', N'Rich avocado flavor combined with aromatic durian for Vietnamese taste.', 49000, N'https://images.unsplash.com/photo-1497034825429-c343d7c6a68f', N'AVOCADO_ICE_CREAM', N'en', N'ACTIVE', 2, 1, 1),
(N'Avocado ice cream smoothie', N'avocado-ice-cream-smoothie', N'Thick avocado smoothie topped with cool creamy ice cream.', 35000, N'https://images.unsplash.com/photo-1505252585461-04db1eb84625', N'DRINK', N'en', N'ACTIVE', 3, 1, 1);
GO

INSERT INTO dbo.banners (title, subtitle, image_url, button_text, button_link, position, language_code, status, sort_order, created_by_user_id, updated_by_user_id)
VALUES
(N'ALOO - Kem Bơ Thuần Việt', N'Hương vị bơ mềm mịn, kem vàng béo nhẹ và mô hình nhượng quyền hiện đại.', N'https://images.unsplash.com/photo-1563805042-7684c019e1cb', N'Đăng ký tư vấn', N'/consultation', N'HOME', N'vi', N'ACTIVE', 1, 1, 1),
(N'Mô hình kiosk ALOO', N'Khởi đầu gọn với quy trình sản phẩm tập trung.', N'https://images.unsplash.com/photo-1551024601-bec78aea704b', N'Xem nhượng quyền', N'/franchise', N'FRANCHISE', N'vi', N'ACTIVE', 2, 1, 1),
(N'Menu kem bơ mới', N'Thêm lựa chọn kem bơ cacao và sầu riêng.', N'https://images.unsplash.com/photo-1488900128323-21503983a07e', N'Xem menu', N'/products', N'PRODUCTS', N'vi', N'HIDDEN', 3, 1, 1),
(N'ALOO - Vietnamese Avocado Ice Cream', N'Smooth avocado flavor, creamy golden ice cream and a modern franchise-ready model.', N'https://images.unsplash.com/photo-1563805042-7684c019e1cb', N'Get consultation', N'/consultation', N'HOME', N'en', N'ACTIVE', 1, 1, 1),
(N'ALOO kiosk model', N'Start lean with a focused product workflow.', N'https://images.unsplash.com/photo-1551024601-bec78aea704b', N'View franchise', N'/franchise', N'FRANCHISE', N'en', N'ACTIVE', 2, 1, 1);
GO

INSERT INTO dbo.posts (title, slug, excerpt, content, thumbnail_url, category, language_code, status, published_at, created_by_user_id, updated_by_user_id)
VALUES
(N'Câu chuyện kem bơ thuần Việt của ALOO', N'cau-chuyen-kem-bo-thuan-viet-cua-aloo', N'Hành trình xây dựng hương vị kem bơ gần gũi với người Việt.', N'ALOO phát triển từ ý tưởng đưa món kem bơ quen thuộc vào mô hình cửa hàng hiện đại, dễ nhân rộng.', N'https://images.unsplash.com/photo-1563805042-7684c019e1cb', N'BRAND', N'vi', N'PUBLISHED', '2026-05-12', 1, 1),
(N'Vì sao kiosk kem bơ phù hợp khu dân cư', N'vi-sao-kiosk-kem-bo-phu-hop-khu-dan-cu', N'Mô hình kiosk giúp tối ưu chi phí và tiếp cận khách hàng thường xuyên.', N'Kiosk kem bơ phù hợp khu dân cư nhờ menu gọn, tốc độ phục vụ nhanh và chi phí vận hành dễ kiểm soát.', N'https://images.unsplash.com/photo-1551024601-bec78aea704b', N'FRANCHISE', N'vi', N'PUBLISHED', '2026-05-08', 1, 1),
(N'Checklist khai trương cửa hàng kem bơ', N'checklist-khai-truong-cua-hang-kem-bo', N'Các hạng mục cần chuẩn bị trước ngày khai trương điểm bán ALOO.', N'Checklist gồm mặt bằng, thiết bị, nguyên liệu, đào tạo nhân sự, truyền thông và vận hành thử.', N'https://images.unsplash.com/photo-1521305916504-4a1121188589', N'OPERATION', N'vi', N'PUBLISHED', '2026-05-03', 1, 1),
(N'Menu theo mùa giúp điểm bán tăng doanh thu', N'menu-theo-mua-giup-diem-ban-tang-doanh-thu', N'Menu theo mùa giúp cửa hàng có thêm lý do để khách quay lại.', N'Các món theo mùa tạo sự mới mẻ nhưng vẫn giữ nền sản phẩm kem bơ chủ lực của thương hiệu.', N'https://images.unsplash.com/photo-1488900128323-21503983a07e', N'PRODUCT', N'vi', N'DRAFT', NULL, 1, 1),
(N'Quản lý nguyên liệu cho cửa hàng kem bơ', N'quan-ly-nguyen-lieu-cho-cua-hang-kem-bo', N'Cách kiểm soát tồn kho, định lượng và chất lượng nguyên liệu.', N'Quản lý nguyên liệu tốt giúp giảm hao hụt và giữ chất lượng sản phẩm ổn định giữa các điểm bán.', N'https://images.unsplash.com/photo-1505252585461-04db1eb84625', N'OPERATION', N'vi', N'SCHEDULED', '2026-05-20', 1, 1),
(N'The story of ALOO Vietnamese avocado ice cream', N'the-story-of-aloo-vietnamese-avocado-ice-cream', N'The journey of building an avocado ice cream flavor close to Vietnamese customers.', N'ALOO was developed from the idea of bringing a familiar avocado ice cream into a modern and scalable store model.', N'https://images.unsplash.com/photo-1563805042-7684c019e1cb', N'BRAND', N'en', N'PUBLISHED', '2026-05-12', 1, 1),
(N'Why avocado ice cream kiosks fit residential areas', N'why-avocado-ice-cream-kiosks-fit-residential-areas', N'Kiosks help optimize costs and reach frequent local customers.', N'An avocado ice cream kiosk fits residential areas thanks to a focused menu, fast service and controllable operating costs.', N'https://images.unsplash.com/photo-1551024601-bec78aea704b', N'FRANCHISE', N'en', N'PUBLISHED', '2026-05-08', 1, 1);
GO

INSERT INTO dbo.franchise_registrations (full_name, phone, email, province, expected_budget, note, status, assigned_to_user_id)
VALUES
(N'Nguyễn Minh Anh', N'0918 246 579', N'minhanh@gmail.com', N'TP.HCM', 350000000, N'Muốn mở kiosk gần khu chung cư, cần tư vấn mặt bằng.', N'NEW', NULL),
(N'Trần Quang Huy', N'0936 728 145', N'quanghuy@gmail.com', N'Đà Nẵng', 500000000, N'Đã có mặt bằng mặt tiền, muốn tìm hiểu gói cửa hàng tiêu chuẩn.', N'CONTACTED', 1),
(N'Lê Thu Hà', N'0974 512 386', N'thuha.aloo@gmail.com', N'Cần Thơ', 250000000, N'Quan tâm mô hình xe đẩy/kiosk, cần bảng dự toán chi phí.', N'CONSULTING', 1),
(N'Phạm Gia Huy', N'0907 638 219', N'giahuy.fnb@gmail.com', N'Hà Nội', 700000000, N'Muốn mở flagship mini tại khu văn phòng.', N'COMPLETED', 1),
(N'Đỗ Mai Linh', N'0928 415 763', N'mailinh.store@gmail.com', N'Bình Dương', 180000000, N'Tạm dừng kế hoạch do chưa tìm được mặt bằng phù hợp.', N'CANCELLED', NULL);
GO

INSERT INTO dbo.locations (name, address, province, phone, opening_hours, map_url, language_code, status, sort_order, created_by_user_id, updated_by_user_id)
VALUES
(N'ALOO Nguyễn Trãi', N'128 Nguyễn Trãi, Phường Bến Thành', N'TP.HCM', N'0900 888 168', N'09:00 - 22:00', N'https://maps.google.com/?q=128+Nguyen+Trai+TPHCM', N'vi', N'ACTIVE', 1, 1, 1),
(N'ALOO Phú Mỹ Hưng', N'45 Nguyễn Đức Cảnh, Quận 7', N'TP.HCM', N'0901 222 168', N'10:00 - 22:30', N'https://maps.google.com/?q=45+Nguyen+Duc+Canh+Quan+7', N'vi', N'ACTIVE', 2, 1, 1),
(N'ALOO Hải Châu', N'82 Bạch Đằng, Quận Hải Châu', N'Đà Nẵng', N'0902 333 168', N'09:30 - 22:00', N'https://maps.google.com/?q=82+Bach+Dang+Da+Nang', N'vi', N'COMING_SOON', 3, 1, 1),
(N'ALOO Ninh Kiều', N'19 Mậu Thân, Quận Ninh Kiều', N'Cần Thơ', N'0903 444 168', N'09:00 - 21:30', N'https://maps.google.com/?q=19+Mau+Than+Can+Tho', N'vi', N'ACTIVE', 4, 1, 1),
(N'ALOO Nguyen Trai', N'128 Nguyen Trai, Ben Thanh Ward', N'Ho Chi Minh City', N'0900 888 168', N'09:00 - 22:00', N'https://maps.google.com/?q=128+Nguyen+Trai+TPHCM', N'en', N'ACTIVE', 1, 1, 1),
(N'ALOO Phu My Hung', N'45 Nguyen Duc Canh, District 7', N'Ho Chi Minh City', N'0901 222 168', N'10:00 - 22:30', N'https://maps.google.com/?q=45+Nguyen+Duc+Canh+Quan+7', N'en', N'ACTIVE', 2, 1, 1),
(N'ALOO Hai Chau', N'82 Bach Dang, Hai Chau District', N'Da Nang', N'0902 333 168', N'09:30 - 22:00', N'https://maps.google.com/?q=82+Bach+Dang+Da+Nang', N'en', N'COMING_SOON', 3, 1, 1);
GO

INSERT INTO dbo.franchise_contents (section_key, title, content, language_code, sort_order, status, created_by_user_id, updated_by_user_id)
VALUES
(N'BENEFITS', N'Công thức đồng bộ', N'Định lượng, topping và quy trình pha chế giúp đào tạo nhanh.', N'vi', 1, N'ACTIVE', 1, 1),
(N'BENEFITS', N'Nhận diện sẵn sàng', N'Bộ màu, menu, bảng hiệu và vật phẩm bán hàng thống nhất.', N'vi', 2, N'ACTIVE', 1, 1),
(N'CONDITIONS', N'Mặt bằng', N'Diện tích từ 12m2, mặt tiền dễ nhận diện và có khu vực bảo quản nguyên liệu.', N'vi', 1, N'ACTIVE', 1, 1),
(N'CONDITIONS', N'Vốn đầu tư', N'Nguồn vốn phù hợp với gói kiosk, cửa hàng tiêu chuẩn hoặc flagship mini.', N'vi', 2, N'ACTIVE', 1, 1),
(N'PROCESS', N'Tiếp nhận thông tin', N'Đội ngũ ALOO liên hệ và xác nhận nhu cầu đầu tư.', N'vi', 1, N'ACTIVE', 1, 1),
(N'PROCESS', N'Triển khai cửa hàng', N'Thiết kế, lắp đặt, đào tạo và chuẩn bị khai trương.', N'vi', 2, N'ACTIVE', 1, 1),
(N'COSTS', N'Gói kiosk', N'120 - 180 triệu. Phù hợp điểm bán nhỏ, chi phí gọn.', N'vi', 1, N'ACTIVE', 1, 1),
(N'COSTS', N'Gói cửa hàng tiêu chuẩn', N'280 - 450 triệu. Dành cho mặt bằng phố hoặc khu dân cư.', N'vi', 2, N'ACTIVE', 1, 1),
(N'BENEFITS', N'Standardized recipe', N'Portioning, toppings and preparation workflow help partners train quickly.', N'en', 1, N'ACTIVE', 1, 1),
(N'BENEFITS', N'Ready brand identity', N'Colors, menu, signage and sales materials are kept consistent.', N'en', 2, N'ACTIVE', 1, 1),
(N'CONDITIONS', N'Location', N'From 12 square meters, visible frontage and an area for ingredient storage.', N'en', 1, N'ACTIVE', 1, 1),
(N'PROCESS', N'Information intake', N'The ALOO team contacts and confirms investment needs.', N'en', 1, N'ACTIVE', 1, 1),
(N'COSTS', N'Kiosk package', N'120 - 180 million VND. Suitable for small points of sale with lean cost.', N'en', 1, N'ACTIVE', 1, 1);
GO

INSERT INTO dbo.site_settings (setting_key, setting_value, group_name, language_code)
VALUES
(N'hotline', N'0900 888 168', N'CONTACT', N'vi'),
(N'email', N'hello@aloo.vn', N'CONTACT', N'vi'),
(N'address', N'128 Nguyễn Trãi, Phường Bến Thành, TP.HCM', N'CONTACT', N'vi'),
(N'facebook', N'https://facebook.com/aloo.vn', N'SOCIAL', N'vi'),
(N'zalo', N'https://zalo.me/0900888168', N'SOCIAL', N'vi'),
(N'seo_title', N'ALOO - Kem Bơ Thuần Việt | Nhượng quyền kem bơ', N'SEO', N'vi'),
(N'seo_description', N'Website thương hiệu và nhượng quyền ALOO - Kem Bơ Thuần Việt.', N'SEO', N'vi'),
(N'logo', N'/images/logo.svg', N'BRAND', N'vi'),
(N'favicon', N'/favicon.ico', N'BRAND', N'vi'),
(N'hotline', N'0900 888 168', N'CONTACT', N'en'),
(N'email', N'hello@aloo.vn', N'CONTACT', N'en'),
(N'address', N'128 Nguyen Trai, Ben Thanh Ward, Ho Chi Minh City', N'CONTACT', N'en'),
(N'facebook', N'https://facebook.com/aloo.vn', N'SOCIAL', N'en'),
(N'zalo', N'https://zalo.me/0900888168', N'SOCIAL', N'en'),
(N'seo_title', N'ALOO - Vietnamese Avocado Ice Cream Franchise', N'SEO', N'en'),
(N'seo_description', N'Brand website and franchise CMS for ALOO Vietnamese avocado ice cream.', N'SEO', N'en'),
(N'logo', N'/images/logo.svg', N'BRAND', N'en'),
(N'favicon', N'/favicon.ico', N'BRAND', N'en');
GO

INSERT INTO dbo.contacts (full_name, phone, email, subject, message, status, assigned_to_user_id)
VALUES
(N'Nguyễn Hoàng Nam', N'0988 456 123', N'hoangnam@gmail.com', N'Hỏi thông tin nhượng quyền', N'Tôi muốn nhận thêm tài liệu về mô hình nhượng quyền ALOO.', N'NEW', NULL),
(N'Trần Mai Phương', N'0912 789 456', N'maiphuong@gmail.com', N'Liên hệ hợp tác', N'Tôi có mặt bằng tại Bình Thạnh và muốn trao đổi thêm.', N'READ', 1);
GO
