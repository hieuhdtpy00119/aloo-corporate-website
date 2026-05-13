/*
  ALOO Franchise CMS - SQL Server database schema
  Scope: corporate website + admin CMS, no ecommerce/cart/payment tables.
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

/* Re-runnable table cleanup, ordered by foreign key dependencies. */
DROP TABLE IF EXISTS dbo.contacts;
DROP TABLE IF EXISTS dbo.franchise_contents;
DROP TABLE IF EXISTS dbo.locations;
DROP TABLE IF EXISTS dbo.franchise_registrations;
DROP TABLE IF EXISTS dbo.posts;
DROP TABLE IF EXISTS dbo.banners;
DROP TABLE IF EXISTS dbo.products;
DROP TABLE IF EXISTS dbo.users;
GO

/* users: admin accounts for CMS authentication and authorization. */
CREATE TABLE dbo.users (
  id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT pk_users PRIMARY KEY,
  full_name NVARCHAR(150) NOT NULL,
  email NVARCHAR(255) NOT NULL,
  password_hash NVARCHAR(255) NOT NULL,
  role NVARCHAR(50) NOT NULL CONSTRAINT df_users_role DEFAULT N'ADMIN',
  status NVARCHAR(30) NOT NULL CONSTRAINT df_users_status DEFAULT N'ACTIVE',
  created_at DATETIME2(0) NOT NULL CONSTRAINT df_users_created_at DEFAULT SYSUTCDATETIME(),
  updated_at DATETIME2(0) NOT NULL CONSTRAINT df_users_updated_at DEFAULT SYSUTCDATETIME(),
  CONSTRAINT uq_users_email UNIQUE (email),
  CONSTRAINT ck_users_role CHECK (role IN (N'SUPER_ADMIN', N'ADMIN', N'EDITOR')),
  CONSTRAINT ck_users_status CHECK (status IN (N'ACTIVE', N'INACTIVE', N'LOCKED'))
);
GO

/* products: public menu items managed by CMS. */
CREATE TABLE dbo.products (
  id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT pk_products PRIMARY KEY,
  name NVARCHAR(180) NOT NULL,
  slug NVARCHAR(220) NOT NULL,
  description NVARCHAR(MAX) NULL,
  price DECIMAL(18,2) NOT NULL CONSTRAINT df_products_price DEFAULT 0,
  image_url NVARCHAR(1000) NULL,
  category NVARCHAR(100) NOT NULL,
  status NVARCHAR(30) NOT NULL CONSTRAINT df_products_status DEFAULT N'ACTIVE',
  sort_order INT NOT NULL CONSTRAINT df_products_sort_order DEFAULT 0,
  created_by_user_id BIGINT NULL,
  created_at DATETIME2(0) NOT NULL CONSTRAINT df_products_created_at DEFAULT SYSUTCDATETIME(),
  updated_at DATETIME2(0) NOT NULL CONSTRAINT df_products_updated_at DEFAULT SYSUTCDATETIME(),
  CONSTRAINT uq_products_slug UNIQUE (slug),
  CONSTRAINT ck_products_status CHECK (status IN (N'ACTIVE', N'HIDDEN', N'OUT_OF_STOCK')),
  CONSTRAINT fk_products_created_by_user FOREIGN KEY (created_by_user_id) REFERENCES dbo.users(id)
);
GO

/* banners: hero and marketing banners for website sections. */
CREATE TABLE dbo.banners (
  id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT pk_banners PRIMARY KEY,
  title NVARCHAR(220) NOT NULL,
  subtitle NVARCHAR(500) NULL,
  image_url NVARCHAR(1000) NOT NULL,
  button_text NVARCHAR(100) NULL,
  button_link NVARCHAR(500) NULL,
  position NVARCHAR(100) NOT NULL CONSTRAINT df_banners_position DEFAULT N'home',
  status NVARCHAR(30) NOT NULL CONSTRAINT df_banners_status DEFAULT N'ACTIVE',
  sort_order INT NOT NULL CONSTRAINT df_banners_sort_order DEFAULT 0,
  created_by_user_id BIGINT NULL,
  created_at DATETIME2(0) NOT NULL CONSTRAINT df_banners_created_at DEFAULT SYSUTCDATETIME(),
  updated_at DATETIME2(0) NOT NULL CONSTRAINT df_banners_updated_at DEFAULT SYSUTCDATETIME(),
  CONSTRAINT ck_banners_status CHECK (status IN (N'ACTIVE', N'HIDDEN', N'EXPIRED')),
  CONSTRAINT fk_banners_created_by_user FOREIGN KEY (created_by_user_id) REFERENCES dbo.users(id)
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
  category NVARCHAR(100) NOT NULL,
  status NVARCHAR(30) NOT NULL CONSTRAINT df_posts_status DEFAULT N'DRAFT',
  published_at DATETIME2(0) NULL,
  created_by_user_id BIGINT NULL,
  created_at DATETIME2(0) NOT NULL CONSTRAINT df_posts_created_at DEFAULT SYSUTCDATETIME(),
  updated_at DATETIME2(0) NOT NULL CONSTRAINT df_posts_updated_at DEFAULT SYSUTCDATETIME(),
  CONSTRAINT uq_posts_slug UNIQUE (slug),
  CONSTRAINT ck_posts_status CHECK (status IN (N'PUBLISHED', N'DRAFT', N'SCHEDULED', N'HIDDEN')),
  CONSTRAINT fk_posts_created_by_user FOREIGN KEY (created_by_user_id) REFERENCES dbo.users(id)
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
  status NVARCHAR(30) NOT NULL CONSTRAINT df_franchise_registrations_status DEFAULT N'Mới',
  assigned_to_user_id BIGINT NULL,
  created_at DATETIME2(0) NOT NULL CONSTRAINT df_franchise_registrations_created_at DEFAULT SYSUTCDATETIME(),
  updated_at DATETIME2(0) NOT NULL CONSTRAINT df_franchise_registrations_updated_at DEFAULT SYSUTCDATETIME(),
  CONSTRAINT ck_franchise_registrations_status CHECK (status IN (N'Mới', N'Đã liên hệ', N'Đang tư vấn', N'Hoàn tất', N'Hủy')),
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
  status NVARCHAR(30) NOT NULL CONSTRAINT df_locations_status DEFAULT N'Đang hoạt động',
  created_by_user_id BIGINT NULL,
  created_at DATETIME2(0) NOT NULL CONSTRAINT df_locations_created_at DEFAULT SYSUTCDATETIME(),
  updated_at DATETIME2(0) NOT NULL CONSTRAINT df_locations_updated_at DEFAULT SYSUTCDATETIME(),
  CONSTRAINT ck_locations_status CHECK (status IN (N'Đang hoạt động', N'Sắp khai trương', N'Tạm đóng')),
  CONSTRAINT fk_locations_created_by_user FOREIGN KEY (created_by_user_id) REFERENCES dbo.users(id)
);
GO

/* franchise_contents: reusable content blocks for franchise pages. */
CREATE TABLE dbo.franchise_contents (
  id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT pk_franchise_contents PRIMARY KEY,
  section_key NVARCHAR(50) NOT NULL,
  title NVARCHAR(220) NOT NULL,
  content NVARCHAR(MAX) NOT NULL,
  sort_order INT NOT NULL CONSTRAINT df_franchise_contents_sort_order DEFAULT 0,
  status NVARCHAR(30) NOT NULL CONSTRAINT df_franchise_contents_status DEFAULT N'ACTIVE',
  created_by_user_id BIGINT NULL,
  created_at DATETIME2(0) NOT NULL CONSTRAINT df_franchise_contents_created_at DEFAULT SYSUTCDATETIME(),
  updated_at DATETIME2(0) NOT NULL CONSTRAINT df_franchise_contents_updated_at DEFAULT SYSUTCDATETIME(),
  CONSTRAINT ck_franchise_contents_section_key CHECK (section_key IN (N'benefits', N'conditions', N'process', N'costs')),
  CONSTRAINT ck_franchise_contents_status CHECK (status IN (N'ACTIVE', N'HIDDEN')),
  CONSTRAINT fk_franchise_contents_created_by_user FOREIGN KEY (created_by_user_id) REFERENCES dbo.users(id)
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
  CONSTRAINT ck_contacts_status CHECK (status IN (N'NEW', N'READ', N'REPLIED', N'ARCHIVED')),
  CONSTRAINT fk_contacts_assigned_to_user FOREIGN KEY (assigned_to_user_id) REFERENCES dbo.users(id)
);
GO

/* Indexes for common CMS/public queries. */
CREATE INDEX ix_users_status ON dbo.users(status);
CREATE INDEX ix_products_status ON dbo.products(status);
CREATE INDEX ix_products_category ON dbo.products(category);
CREATE INDEX ix_products_sort_order ON dbo.products(sort_order);
CREATE INDEX ix_banners_status ON dbo.banners(status);
CREATE INDEX ix_banners_position ON dbo.banners(position);
CREATE INDEX ix_posts_status ON dbo.posts(status);
CREATE INDEX ix_posts_category ON dbo.posts(category);
CREATE INDEX ix_posts_published_at ON dbo.posts(published_at);
CREATE INDEX ix_franchise_registrations_status ON dbo.franchise_registrations(status);
CREATE INDEX ix_franchise_registrations_email ON dbo.franchise_registrations(email);
CREATE INDEX ix_locations_status ON dbo.locations(status);
CREATE INDEX ix_locations_province ON dbo.locations(province);
CREATE INDEX ix_franchise_contents_section_key ON dbo.franchise_contents(section_key);
CREATE INDEX ix_franchise_contents_status ON dbo.franchise_contents(status);
CREATE INDEX ix_contacts_status ON dbo.contacts(status);
CREATE INDEX ix_contacts_email ON dbo.contacts(email);
GO

/* Seed data for frontend/backend testing. */
INSERT INTO dbo.users (full_name, email, password_hash, role, status)
VALUES
(N'ALOO Administrator', N'admin@aloo.vn', N'$2a$10$demo.hash.for.local.development.only', N'SUPER_ADMIN', N'ACTIVE');
GO

INSERT INTO dbo.products (name, slug, description, price, image_url, category, status, sort_order, created_by_user_id)
VALUES
(N'Kem bơ truyền thống', N'kem-bo-truyen-thong', N'Bơ xay mịn, kem sữa vàng kem và topping dừa sấy giòn.', 39000, N'https://images.unsplash.com/photo-1563805042-7684c019e1cb', N'Best seller', N'ACTIVE', 1, 1),
(N'Kem bơ sầu riêng', N'kem-bo-sau-rieng', N'Vị bơ béo thanh kết hợp sầu riêng thơm đậm.', 49000, N'https://images.unsplash.com/photo-1497034825429-c343d7c6a68f', N'Đặc biệt', N'ACTIVE', 2, 1),
(N'Sinh tố bơ kem', N'sinh-to-bo-kem', N'Sinh tố bơ sánh mịn, thêm viên kem vàng kem mát lạnh.', 35000, N'https://images.unsplash.com/photo-1505252585461-04db1eb84625', N'Đồ uống', N'ACTIVE', 3, 1),
(N'Kem bơ cacao', N'kem-bo-cacao', N'Nền bơ mềm béo, cacao đắng nhẹ và hạt rang thơm.', 45000, N'https://images.unsplash.com/photo-1551024601-bec78aea704b', N'Mới', N'ACTIVE', 4, 1),
(N'Combo kem bơ gia đình', N'combo-kem-bo-gia-dinh', N'Combo nhiều phần phù hợp nhóm bạn và gia đình.', 159000, N'https://images.unsplash.com/photo-1488900128323-21503983a07e', N'Combo', N'ACTIVE', 5, 1);
GO

INSERT INTO dbo.banners (title, subtitle, image_url, button_text, button_link, position, status, sort_order, created_by_user_id)
VALUES
(N'ALOO - Kem Bơ Thuần Việt', N'Hương vị bơ mềm mịn, kem vàng béo nhẹ và mô hình nhượng quyền hiện đại.', N'https://images.unsplash.com/photo-1563805042-7684c019e1cb', N'Đăng ký tư vấn', N'/consultation', N'home', N'ACTIVE', 1, 1),
(N'Mô hình kiosk ALOO', N'Khởi đầu gọn với quy trình sản phẩm tập trung.', N'https://images.unsplash.com/photo-1551024601-bec78aea704b', N'Xem chi phí', N'/franchise', N'franchise', N'ACTIVE', 2, 1),
(N'Menu kem bơ mới', N'Thêm lựa chọn kem bơ cacao và sầu riêng.', N'https://images.unsplash.com/photo-1488900128323-21503983a07e', N'Xem menu', N'/products', N'products', N'HIDDEN', 3, 1);
GO

INSERT INTO dbo.posts (title, slug, excerpt, content, thumbnail_url, category, status, published_at, created_by_user_id)
VALUES
(N'Câu chuyện kem bơ thuần Việt của ALOO', N'cau-chuyen-kem-bo-thuan-viet-cua-aloo', N'Hành trình xây dựng hương vị kem bơ gần gũi với người Việt.', N'ALOO phát triển từ ý tưởng đưa món kem bơ quen thuộc vào mô hình cửa hàng hiện đại, dễ nhân rộng.', N'https://images.unsplash.com/photo-1563805042-7684c019e1cb', N'Câu chuyện thương hiệu', N'PUBLISHED', '2026-05-12', 1),
(N'Vì sao kiosk kem bơ phù hợp khu dân cư', N'vi-sao-kiosk-kem-bo-phu-hop-khu-dan-cu', N'Mô hình kiosk giúp tối ưu chi phí và tiếp cận khách hàng thường xuyên.', N'Kiosk kem bơ phù hợp khu dân cư nhờ menu gọn, tốc độ phục vụ nhanh và chi phí vận hành dễ kiểm soát.', N'https://images.unsplash.com/photo-1551024601-bec78aea704b', N'Nhượng quyền', N'PUBLISHED', '2026-05-08', 1),
(N'Checklist khai trương cửa hàng kem bơ', N'checklist-khai-truong-cua-hang-kem-bo', N'Các hạng mục cần chuẩn bị trước ngày khai trương điểm bán ALOO.', N'Checklist gồm mặt bằng, thiết bị, nguyên liệu, đào tạo nhân sự, truyền thông và vận hành thử.', N'https://images.unsplash.com/photo-1521305916504-4a1121188589', N'Vận hành', N'PUBLISHED', '2026-05-03', 1),
(N'Menu theo mùa giúp điểm bán tăng doanh thu', N'menu-theo-mua-giup-diem-ban-tang-doanh-thu', N'Menu theo mùa giúp cửa hàng có thêm lý do để khách quay lại.', N'Các món theo mùa tạo sự mới mẻ nhưng vẫn giữ nền sản phẩm kem bơ chủ lực của thương hiệu.', N'https://images.unsplash.com/photo-1488900128323-21503983a07e', N'Sản phẩm', N'DRAFT', NULL, 1),
(N'Quản lý nguyên liệu cho cửa hàng kem bơ', N'quan-ly-nguyen-lieu-cho-cua-hang-kem-bo', N'Cách kiểm soát tồn kho, định lượng và chất lượng nguyên liệu.', N'Quản lý nguyên liệu tốt giúp giảm hao hụt và giữ chất lượng sản phẩm ổn định giữa các điểm bán.', N'https://images.unsplash.com/photo-1505252585461-04db1eb84625', N'Vận hành', N'SCHEDULED', '2026-05-20', 1);
GO

INSERT INTO dbo.franchise_registrations (full_name, phone, email, province, expected_budget, note, status, assigned_to_user_id)
VALUES
(N'Nguyễn Minh Anh', N'0918 246 579', N'minhanh@gmail.com', N'TP.HCM', 350000000, N'Muốn mở kiosk gần khu chung cư, cần tư vấn mặt bằng.', N'Mới', NULL),
(N'Trần Quang Huy', N'0936 728 145', N'quanghuy@gmail.com', N'Đà Nẵng', 500000000, N'Đã có mặt bằng mặt tiền, muốn tìm hiểu gói cửa hàng tiêu chuẩn.', N'Đã liên hệ', 1),
(N'Lê Thu Hà', N'0974 512 386', N'thuha.aloo@gmail.com', N'Cần Thơ', 250000000, N'Quan tâm mô hình xe đẩy/kiosk, cần bảng dự toán chi phí.', N'Đang tư vấn', 1),
(N'Phạm Gia Huy', N'0907 638 219', N'giahuy.fnb@gmail.com', N'Hà Nội', 700000000, N'Muốn mở flagship mini tại khu văn phòng.', N'Hoàn tất', 1),
(N'Đỗ Mai Linh', N'0928 415 763', N'mailinh.store@gmail.com', N'Bình Dương', 180000000, N'Tạm dừng kế hoạch do chưa tìm được mặt bằng phù hợp.', N'Hủy', NULL);
GO

INSERT INTO dbo.locations (name, address, province, phone, opening_hours, map_url, status, created_by_user_id)
VALUES
(N'ALOO Nguyễn Trãi', N'128 Nguyễn Trãi, Phường Bến Thành', N'TP.HCM', N'0900 888 168', N'09:00 - 22:00', N'https://maps.google.com/?q=128+Nguyen+Trai+TPHCM', N'Đang hoạt động', 1),
(N'ALOO Phú Mỹ Hưng', N'45 Nguyễn Đức Cảnh, Quận 7', N'TP.HCM', N'0901 222 168', N'10:00 - 22:30', N'https://maps.google.com/?q=45+Nguyen+Duc+Canh+Quan+7', N'Đang hoạt động', 1),
(N'ALOO Hải Châu', N'82 Bạch Đằng, Quận Hải Châu', N'Đà Nẵng', N'0902 333 168', N'09:30 - 22:00', N'https://maps.google.com/?q=82+Bach+Dang+Da+Nang', N'Sắp khai trương', 1),
(N'ALOO Ninh Kiều', N'19 Mậu Thân, Quận Ninh Kiều', N'Cần Thơ', N'0903 444 168', N'09:00 - 21:30', N'https://maps.google.com/?q=19+Mau+Than+Can+Tho', N'Đang hoạt động', 1);
GO

INSERT INTO dbo.franchise_contents (section_key, title, content, sort_order, status, created_by_user_id)
VALUES
(N'benefits', N'Công thức đồng bộ', N'Định lượng, topping và quy trình pha chế giúp đào tạo nhanh.', 1, N'ACTIVE', 1),
(N'benefits', N'Nhận diện sẵn sàng', N'Bộ màu, menu, bảng hiệu và vật phẩm bán hàng thống nhất.', 2, N'ACTIVE', 1),
(N'conditions', N'Mặt bằng', N'Diện tích từ 12m2, mặt tiền dễ nhận diện và có khu vực bảo quản nguyên liệu.', 1, N'ACTIVE', 1),
(N'conditions', N'Vốn đầu tư', N'Nguồn vốn phù hợp với gói kiosk, cửa hàng tiêu chuẩn hoặc flagship mini.', 2, N'ACTIVE', 1),
(N'process', N'Tiếp nhận thông tin', N'Đội ngũ ALOO liên hệ và xác nhận nhu cầu đầu tư.', 1, N'ACTIVE', 1),
(N'process', N'Triển khai cửa hàng', N'Thiết kế, lắp đặt, đào tạo và chuẩn bị khai trương.', 2, N'ACTIVE', 1),
(N'costs', N'Gói kiosk', N'120 - 180 triệu. Phù hợp điểm bán nhỏ, chi phí gọn.', 1, N'ACTIVE', 1),
(N'costs', N'Gói cửa hàng tiêu chuẩn', N'280 - 450 triệu. Dành cho mặt bằng phố hoặc khu dân cư.', 2, N'ACTIVE', 1);
GO

INSERT INTO dbo.contacts (full_name, phone, email, subject, message, status, assigned_to_user_id)
VALUES
(N'Nguyễn Hoàng Nam', N'0988 456 123', N'hoangnam@gmail.com', N'Hỏi thông tin nhượng quyền', N'Tôi muốn nhận thêm tài liệu về mô hình nhượng quyền ALOO.', N'NEW', NULL),
(N'Trần Mai Phương', N'0912 789 456', N'maiphuong@gmail.com', N'Liên hệ hợp tác', N'Tôi có mặt bằng tại Bình Thạnh và muốn trao đổi thêm.', N'READ', 1);
GO

