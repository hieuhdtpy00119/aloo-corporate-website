USE ALOO_Franchise_CMS;
GO

-- Sample/demo data for local development and UI testing only.
-- Run after backend/database/aloo_franchise_cms.sql.
-- Do not run this script on production unless the data is intentionally needed.

DECLARE @passwordHash NVARCHAR(255) = N'$2a$10$.Qt3cc3WDZaSUrprSayKsePkQ/LoBW8z8dzFoSpmNkbLmqwCmuPAu'; 

IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE email = N'admin@aloo.vn')
BEGIN
    INSERT INTO dbo.users (email, password_hash, full_name, phone, avatar_url, role, status)
    VALUES (N'admin@aloo.vn', @passwordHash, N'ALOO Admin', N'0900 888 168', NULL, N'ADMIN', N'ACTIVE');
END

IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE email = N'content@aloo.vn')
BEGIN
    INSERT INTO dbo.users (email, password_hash, full_name, phone, avatar_url, role, status)
    VALUES (N'content@aloo.vn', @passwordHash, N'ALOO Content Manager', N'0900 888 169', NULL, N'ADMIN', N'ACTIVE');
END

IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE email = N'user@aloo.vn')
BEGIN
    INSERT INTO dbo.users (email, password_hash, full_name, phone, avatar_url, role, status)
    VALUES (N'user@aloo.vn', @passwordHash, N'ALOO User', N'0901 234 567', NULL, N'USER', N'ACTIVE');
END

IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE email = N'khachhang@aloo.vn')
BEGIN
    INSERT INTO dbo.users (email, password_hash, full_name, phone, avatar_url, role, status)
    VALUES (N'khachhang@aloo.vn', @passwordHash, N'Khách hàng ALOO', N'0902 345 678', NULL, N'USER', N'ACTIVE');
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.categories WHERE slug = N'kem-bo')
BEGIN
    INSERT INTO dbo.categories (name, slug, type, description, sort_order, status, language_code) VALUES
    (N'Kem bơ', N'kem-bo', N'PRODUCT', N'Nhóm sản phẩm kem bơ chủ lực.', 1, N'ACTIVE', N'vi'),
    (N'Đồ uống', N'do-uong', N'PRODUCT', N'Sinh tố, trà và đồ uống theo mùa.', 2, N'ACTIVE', N'vi'),
    (N'Combo', N'combo', N'PRODUCT', N'Combo sản phẩm cho nhóm khách hàng.', 3, N'ACTIVE', N'vi'),
    (N'Topping', N'topping', N'PRODUCT', N'Topping dùng kèm kem bơ và đồ uống.', 4, N'ACTIVE', N'vi'),
    (N'Mùa vụ', N'mua-vu', N'PRODUCT', N'Sản phẩm theo mùa và phiên bản giới hạn.', 5, N'INACTIVE', N'vi');
END

IF NOT EXISTS (SELECT 1 FROM dbo.categories WHERE slug = N'tin-tuc')
BEGIN
    INSERT INTO dbo.categories (name, slug, type, description, sort_order, status, language_code) VALUES
    (N'Tin tức', N'tin-tuc', N'ARTICLE', N'Tin mới về thương hiệu, sản phẩm và hoạt động ALOO.', 1, N'ACTIVE', N'vi'),
    (N'Câu chuyện thương hiệu', N'cau-chuyen-thuong-hieu', N'ARTICLE', N'Câu chuyện, định vị và hành trình phát triển ALOO.', 2, N'ACTIVE', N'vi'),
    (N'Nhượng quyền', N'nhuong-quyen', N'ARTICLE', N'Kiến thức và cập nhật về mô hình nhượng quyền.', 3, N'ACTIVE', N'vi'),
    (N'Review', N'review', N'ARTICLE', N'Bài review sản phẩm, cửa hàng và trải nghiệm khách hàng.', 4, N'ACTIVE', N'vi'),
    (N'Vận hành', N'van-hanh', N'ARTICLE', N'Kinh nghiệm quản lý cửa hàng và tối ưu vận hành.', 5, N'ACTIVE', N'vi'),
    (N'Tuyển dụng', N'tuyen-dung', N'ARTICLE', N'Thông tin tuyển dụng và văn hóa đội ngũ.', 6, N'INACTIVE', N'vi');
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.products)
BEGIN
    INSERT INTO dbo.products (category_id, name, slug, description, price, image_url, sort_order, status) VALUES
    ((SELECT TOP 1 id FROM dbo.categories WHERE slug = N'kem-bo'), N'Kem bơ truyền thống', N'kem-bo-truyen-thong', N'Bơ sáp xay mịn, kem tươi mát và topping dừa sấy.', 39000, N'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=900&q=85', 1, N'ACTIVE'),
    ((SELECT TOP 1 id FROM dbo.categories WHERE slug = N'kem-bo'), N'Kem bơ sầu riêng', N'kem-bo-sau-rieng', N'Nền bơ mềm mịn kết hợp sầu riêng đậm vị.', 49000, N'https://images.unsplash.com/photo-1497034825429-c343d7c6a68f?auto=format&fit=crop&w=900&q=85', 2, N'ACTIVE'),
    ((SELECT TOP 1 id FROM dbo.categories WHERE slug = N'kem-bo'), N'Kem bơ cacao', N'kem-bo-cacao', N'Vị bơ béo nhẹ, cacao thơm dịu và hạt giòn.', 45000, N'https://images.unsplash.com/photo-1551024601-bec78aea704b?auto=format&fit=crop&w=900&q=85', 3, N'ACTIVE'),
    ((SELECT TOP 1 id FROM dbo.categories WHERE slug = N'kem-bo'), N'Kem bơ dừa non', N'kem-bo-dua-non', N'Bơ sáp phối dừa non, vị béo thanh và mát.', 47000, N'https://images.unsplash.com/photo-1505252585461-04db1eb84625?auto=format&fit=crop&w=900&q=85', 4, N'ACTIVE'),
    ((SELECT TOP 1 id FROM dbo.categories WHERE slug = N'kem-bo'), N'Kem bơ matcha', N'kem-bo-matcha', N'Kem bơ phối matcha nhẹ, hậu vị thanh và thơm.', 46000, N'https://images.unsplash.com/photo-1570197788417-0e82375c9371?auto=format&fit=crop&w=900&q=85', 5, N'ACTIVE'),
    ((SELECT TOP 1 id FROM dbo.categories WHERE slug = N'kem-bo'), N'Kem bơ phô mai', N'kem-bo-pho-mai', N'Lớp phô mai béo mặn nhẹ cân bằng vị bơ.', 52000, N'https://images.unsplash.com/photo-1488900128323-21503983a07e?auto=format&fit=crop&w=900&q=85', 6, N'ACTIVE'),
    ((SELECT TOP 1 id FROM dbo.categories WHERE slug = N'do-uong'), N'Sinh tố bơ kem', N'sinh-to-bo-kem', N'Sinh tố bơ sánh mịn thêm viên kem tươi.', 35000, N'https://images.unsplash.com/photo-1577805947697-89e18249d767?auto=format&fit=crop&w=900&q=85', 7, N'ACTIVE'),
    ((SELECT TOP 1 id FROM dbo.categories WHERE slug = N'do-uong'), N'Trà bơ nhiệt đới', N'tra-bo-nhiet-doi', N'Trà trái cây nhẹ kết hợp hương bơ tươi.', 42000, N'https://images.unsplash.com/photo-1544145945-f90425340c7e?auto=format&fit=crop&w=900&q=85', 8, N'ACTIVE'),
    ((SELECT TOP 1 id FROM dbo.categories WHERE slug = N'do-uong'), N'Cà phê kem bơ', N'ca-phe-kem-bo', N'Cà phê đậm vị phủ lớp kem bơ mềm.', 44000, N'https://images.unsplash.com/photo-1517701604599-bb29b565090c?auto=format&fit=crop&w=900&q=85', 9, N'ACTIVE'),
    ((SELECT TOP 1 id FROM dbo.categories WHERE slug = N'do-uong'), N'Soda bơ chanh', N'soda-bo-chanh', N'Soda chanh nhẹ, hương bơ tươi lạ miệng.', 39000, N'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=900&q=85', 10, N'ACTIVE'),
    ((SELECT TOP 1 id FROM dbo.categories WHERE slug = N'combo'), N'Combo Signature', N'combo-signature', N'Kem bơ truyền thống, topping và thức uống nhỏ.', 89000, N'https://images.unsplash.com/photo-1551024506-0bccd828d307?auto=format&fit=crop&w=900&q=85', 11, N'ACTIVE'),
    ((SELECT TOP 1 id FROM dbo.categories WHERE slug = N'combo'), N'Combo Gia đình', N'combo-gia-dinh', N'Gói 4 phần kem bơ cho nhóm bạn hoặc gia đình.', 159000, N'https://images.unsplash.com/photo-1488900128323-21503983a07e?auto=format&fit=crop&w=900&q=85', 12, N'ACTIVE'),
    ((SELECT TOP 1 id FROM dbo.categories WHERE slug = N'combo'), N'Combo Nhượng quyền dùng thử', N'combo-nhuong-quyen-dung-thu', N'Bộ sản phẩm mẫu dành cho đối tác khảo sát menu.', 129000, N'https://images.unsplash.com/photo-1534432182912-63863115e106?auto=format&fit=crop&w=900&q=85', 13, N'ACTIVE'),
    ((SELECT TOP 1 id FROM dbo.categories WHERE slug = N'topping'), N'Topping dừa sấy', N'topping-dua-say', N'Dừa sấy giòn, thơm nhẹ dùng kèm kem bơ.', 9000, N'https://images.unsplash.com/photo-1587314168485-3236d6710814?auto=format&fit=crop&w=900&q=85', 14, N'ACTIVE'),
    ((SELECT TOP 1 id FROM dbo.categories WHERE slug = N'topping'), N'Topping cacao', N'topping-cacao', N'Cacao đắng nhẹ cân bằng vị ngọt.', 9000, N'https://images.unsplash.com/photo-1606312619070-d48b4c652a52?auto=format&fit=crop&w=900&q=85', 15, N'ACTIVE'),
    ((SELECT TOP 1 id FROM dbo.categories WHERE slug = N'topping'), N'Topping sầu riêng', N'topping-sau-rieng', N'Topping sầu riêng đậm hương nhiệt đới.', 15000, N'https://images.unsplash.com/photo-1627308595229-7830a5c91f9f?auto=format&fit=crop&w=900&q=85', 16, N'INACTIVE');
END
GO
UPDATE dbo.products
SET
    short_description = COALESCE(short_description, N'Ly kem bơ signature với nền bơ sáp chín tự nhiên, kem tươi mát lạnh và topping giòn thơm.'),
    detail_content = COALESCE(detail_content, N'ALOO thiết kế sản phẩm này như món chủ lực dễ nhớ, dễ bán lặp lại và dễ chuẩn hóa tại nhiều điểm bán. Công thức tập trung vào độ mịn của bơ, độ mát của kem và cảm giác giòn nhẹ từ topping để tạo trải nghiệm rõ ràng ngay từ muỗng đầu tiên.'),
    ingredients = COALESCE(ingredients, N'Bơ sáp chín tự nhiên
Kem tươi mát lạnh
Sữa tươi
Dừa sấy giòn
Topping theo mùa'),
    taste_profile = COALESCE(taste_profile, N'Béo mịn
Ngọt thanh
Mát lạnh
Hậu vị bơ tự nhiên'),
    serving_suggestion = COALESCE(serving_suggestion, N'Dùng ngon nhất khi vừa hoàn thiện
Phù hợp buổi chiều hoặc sau bữa ăn
Có thể thêm topping giòn để tăng kết cấu'),
    gallery = COALESCE(gallery, N'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=1200&q=85
https://images.unsplash.com/photo-1551024601-bec78aea704b?auto=format&fit=crop&w=1200&q=85
https://images.unsplash.com/photo-1488900128323-21503983a07e?auto=format&fit=crop&w=1200&q=85'),
    faqs = COALESCE(faqs, N'Sản phẩm này có phù hợp trẻ em không? | Có, vị ngọt nhẹ và nguyên liệu dễ dùng cho nhiều nhóm khách.
Có thể bán trong mô hình nhượng quyền không? | Có, đây là nhóm sản phẩm dễ chuẩn hóa quy trình và đào tạo.
Có thể thay đổi topping không? | Có thể tùy điểm bán và mùa nguyên liệu.'),
    featured = CASE WHEN sort_order <= 4 THEN 1 ELSE featured END,
    seo_title = COALESCE(seo_title, name + N' | ALOO Kem Bơ'),
    seo_description = COALESCE(seo_description, description)
WHERE short_description IS NULL;
GO
UPDATE dbo.products
SET
    category_id = (SELECT TOP 1 id FROM dbo.categories WHERE slug = N'kem-bo'),
    name = N'Kem bơ truyền thống',
    slug = N'kem-bo-truyen-thong',
    description = N'Bơ sáp xay mịn kết hợp kem tươi mát, thêm dừa sấy giòn thơm.',
    price = 0,
    image_url = N'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=900&q=85',
    sort_order = 1,
    status = N'ACTIVE',
    short_description = N'Kem bơ truyền thống là món đặc trưng của ALOO, nổi bật với vị bơ sáp béo mịn, kem sữa mát lạnh và topping dừa sấy giòn nhẹ. Sản phẩm phù hợp cho khách hàng yêu thích hương vị tự nhiên, thanh mát và dễ thưởng thức.',
    taste_profile = N'Béo mịn, thơm bơ, ngọt nhẹ, mát lạnh, topping giòn.',
    ingredients = CONCAT(N'Bơ sáp', CHAR(13)+CHAR(10), N'Kem sữa', CHAR(13)+CHAR(10), N'Sữa đặc', CHAR(13)+CHAR(10), N'Dừa sấy', CHAR(13)+CHAR(10), N'Đá xay'),
    serving_suggestion = CONCAT(N'Dùng ngay khi còn lạnh.', CHAR(13)+CHAR(10), N'Phù hợp thưởng thức vào buổi chiều hoặc sau bữa ăn.', CHAR(13)+CHAR(10), N'Có thể thêm dừa sấy, trân châu hoặc sốt bơ để tăng hương vị.'),
    detail_content = N'Kem bơ truyền thống được làm từ bơ sáp chọn lọc, xay mịn cùng kem sữa để tạo nên kết cấu béo mượt và hương vị thanh mát. Mỗi ly kem bơ mang đến cảm giác tự nhiên, dễ ăn và phù hợp với nhiều độ tuổi. Đây là sản phẩm chủ lực giúp khách hàng nhận diện hương vị đặc trưng của ALOO.',
    gallery = CONCAT(N'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=900&q=85', CHAR(13)+CHAR(10), N'https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=900&q=85', CHAR(13)+CHAR(10), N'https://images.unsplash.com/photo-1505253213348-ce2e2ff1f1ec?auto=format&fit=crop&w=900&q=85'),
    faqs = CONCAT(N'Kem bơ truyền thống có ngọt nhiều không? | Sản phẩm có vị ngọt nhẹ, béo mịn và dễ ăn.', CHAR(13)+CHAR(10), N'Sản phẩm có topping gì? | Mặc định có dừa sấy giòn, có thể thêm topping tùy chọn.', CHAR(13)+CHAR(10), N'Kem bơ nên dùng khi nào ngon nhất? | Ngon nhất khi dùng ngay sau khi nhận món, lúc còn lạnh.', CHAR(13)+CHAR(10), N'Sản phẩm phù hợp với ai? | Phù hợp với khách hàng yêu thích món tráng miệng mát lạnh, vị bơ tự nhiên.'),
    featured = 1,
    seo_title = N'Kem bơ truyền thống ALOO - Béo mịn, thơm bơ, mát lạnh',
    seo_description = N'Thưởng thức kem bơ truyền thống ALOO với bơ sáp xay mịn, kem sữa mát lạnh và topping dừa sấy giòn thơm.',
    updated_at = GETDATE()
WHERE slug = N'kem-bo-truyen-thong';
GO
IF NOT EXISTS (SELECT 1 FROM dbo.home_sections)
BEGIN
    INSERT INTO dbo.home_sections (section_key, type, title, subtitle, description, image_url, button_text, button_link, badge, sort_order, status) VALUES
    (N'featured-product', N'FEATURED_CARD', N'Kem bơ truyền thống', N'Tuyển chọn', N'Bơ sáp chín tự nhiên hòa cùng kem sữa mát lạnh và topping dừa sấy giòn thơm.', N'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=1400&q=85', N'Xem sản phẩm', N'/products/kem-bo-truyen-thong', N'Bán chạy nhất', 1, N'ACTIVE'),
    (N'franchise-model', N'CTA_CARD', N'Mô hình nhượng quyền ALOO', N'Tuyển chọn', N'Cửa hàng tinh gọn, nhận diện trẻ trung, quy trình dễ vận hành cho đối tác mới.', N'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=1400&q=85', N'Tìm hiểu ngay', N'/franchise', N'Cơ hội hợp tác', 2, N'ACTIVE'),
    (N'new-store', N'LOCATION_CARD', N'Cửa hàng ALOO mới', N'Trải nghiệm trực tiếp', N'Không gian phục vụ nhanh, menu kem bơ signature và nhiều topping dễ chọn.', N'https://images.unsplash.com/photo-1514933651103-005eec06c04b?auto=format&fit=crop&w=1400&q=85', N'Xem hệ thống', N'/locations', N'Điểm đến mới', 3, N'INACTIVE');
END
GO
IF NOT EXISTS (SELECT 1 FROM dbo.hero_banners)
BEGIN
    INSERT INTO dbo.hero_banners (title, subtitle, description, background_image_url, product_image_url, thumbnail_image_url, tone, sort_order, status) VALUES
    (N'Kem bơ truyền thống', N'Signature ALOO', N'Bơ sáp chín tự nhiên hòa cùng kem tươi mát lạnh.', N'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=1800&q=85', N'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=1200&q=85', N'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=300&q=80', N'light', 1, N'ACTIVE'),
    (N'Kem bơ sầu riêng', N'Tropical Bold', N'Lớp bơ mịn kết hợp sầu riêng đậm vị.', N'https://images.unsplash.com/photo-1497034825429-c343d7c6a68f?auto=format&fit=crop&w=1800&q=85', N'https://images.unsplash.com/photo-1497034825429-c343d7c6a68f?auto=format&fit=crop&w=1200&q=85', N'https://images.unsplash.com/photo-1497034825429-c343d7c6a68f?auto=format&fit=crop&w=300&q=80', N'dark', 2, N'ACTIVE'),
    (N'Sinh tố bơ kem', N'Creamy Smoothie', N'Sinh tố bơ sánh mịn thêm viên kem vàng mát lạnh.', N'https://images.unsplash.com/photo-1505252585461-04db1eb84625?auto=format&fit=crop&w=1800&q=85', N'https://images.unsplash.com/photo-1505252585461-04db1eb84625?auto=format&fit=crop&w=1200&q=85', N'https://images.unsplash.com/photo-1505252585461-04db1eb84625?auto=format&fit=crop&w=300&q=80', N'light', 3, N'ACTIVE'),
    (N'Combo mùa hè', N'Summer Set', N'Bộ menu mát lạnh cho nhóm bạn và gia đình.', N'https://images.unsplash.com/photo-1551024506-0bccd828d307?auto=format&fit=crop&w=1800&q=85', N'https://images.unsplash.com/photo-1551024506-0bccd828d307?auto=format&fit=crop&w=1200&q=85', N'https://images.unsplash.com/photo-1551024506-0bccd828d307?auto=format&fit=crop&w=300&q=80', N'light', 4, N'INACTIVE');
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.menu_posters)
BEGIN
    INSERT INTO dbo.menu_posters (branch_key, title, subtitle, image_url, alt_text, sort_order, status) VALUES
    (N'quy-nhon', N'ALOO Menu Quy Nhơn', N'Menu Poster', N'/menu-poster.png', N'Poster menu ALOO Quy Nhơn', 1, N'ACTIVE'),
    (N'nha-trang', N'ALOO Menu Nha Trang', N'Menu Poster', N'https://images.unsplash.com/photo-1551024601-bec78aea704b?auto=format&fit=crop&w=1600&q=85', N'Poster menu ALOO Nha Trang', 2, N'ACTIVE'),
    (N'tp-hcm', N'ALOO Menu TP.HCM', N'Menu Poster', N'https://images.unsplash.com/photo-1488900128323-21503983a07e?auto=format&fit=crop&w=1600&q=85', N'Poster menu ALOO TP.HCM', 3, N'ACTIVE'),
    (N'da-nang', N'ALOO Menu Đà Nẵng', N'Menu Poster', N'https://images.unsplash.com/photo-1514933651103-005eec06c04b?auto=format&fit=crop&w=1600&q=85', N'Poster menu ALOO Đà Nẵng', 4, N'ACTIVE');
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.locations)
BEGIN
    INSERT INTO dbo.locations (name, address, province, district, phone, opening_hours, map_url, image_url, amenities_json, display_order, featured, status) VALUES
    (N'ALOO Nguyễn Trãi', N'128 Nguyễn Trãi, Phường Bến Thành', N'TP.HCM', N'Quận 1', N'0900 888 168', N'09:00 - 22:00', N'https://maps.google.com/?q=128+Nguyen+Trai+TPHCM', N'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=900&q=85', N'["Wifi","Máy lạnh","Thanh toán thẻ","Mang đi"]', 1, 1, N'ACTIVE'),
    (N'ALOO Phú Mỹ Hưng', N'45 Nguyễn Đức Cảnh, Khu Phú Mỹ Hưng', N'TP.HCM', N'Quận 7', N'0901 222 168', N'10:00 - 22:30', N'https://maps.google.com/?q=45+Nguyen+Duc+Canh+Quan+7', N'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=900&q=85', N'["Wifi","Chỗ đậu xe","Thanh toán thẻ","Mang đi"]', 2, 1, N'ACTIVE'),
    (N'ALOO Thảo Điền', N'26 Xuân Thủy, Phường Thảo Điền', N'TP.HCM', N'Thủ Đức', N'0901 555 168', N'09:00 - 22:30', N'https://maps.google.com/?q=26+Xuan+Thuy+Thao+Dien', N'https://images.unsplash.com/photo-1521017432531-fbd92d768814?auto=format&fit=crop&w=900&q=85', N'["Wifi","Máy lạnh","Chỗ đậu xe"]', 3, 1, N'ACTIVE'),
    (N'ALOO Hải Châu', N'82 Bạch Đằng, Quận Hải Châu', N'Đà Nẵng', N'Hải Châu', N'0902 333 168', N'09:30 - 22:00', N'https://maps.google.com/?q=82+Bach+Dang+Da+Nang', N'https://images.unsplash.com/photo-1514933651103-005eec06c04b?auto=format&fit=crop&w=900&q=85', N'["Wifi","Máy lạnh","Mang đi"]', 4, 0, N'COMING_SOON'),
    (N'ALOO Ninh Kiều', N'19 Mậu Thân, Quận Ninh Kiều', N'Cần Thơ', N'Ninh Kiều', N'0903 444 168', N'09:00 - 21:30', N'https://maps.google.com/?q=19+Mau+Than+Can+Tho', N'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=900&q=85', N'["Wifi","Máy lạnh","Thanh toán thẻ"]', 5, 0, N'ACTIVE'),
    (N'ALOO Hoàn Kiếm', N'36 Lý Thường Kiệt, Quận Hoàn Kiếm', N'Hà Nội', N'Hoàn Kiếm', N'0904 555 168', N'10:00 - 22:00', N'https://maps.google.com/?q=36+Ly+Thuong+Kiet+Ha+Noi', N'https://images.unsplash.com/photo-1552566626-52f8b828add9?auto=format&fit=crop&w=900&q=85', N'["Wifi","Máy lạnh","Chỗ đậu xe"]', 6, 1, N'MAINTENANCE'),
    (N'ALOO Quy Nhơn', N'22 Xuân Diệu, TP. Quy Nhơn', N'Bình Định', N'Quy Nhơn', N'0905 666 168', N'09:00 - 22:00', N'https://maps.google.com/?q=22+Xuan+Dieu+Quy+Nhon', N'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=900&q=85', N'["Wifi","Mang đi"]', 7, 1, N'ACTIVE'),
    (N'ALOO Nha Trang', N'15 Trần Phú, TP. Nha Trang', N'Khánh Hòa', N'Nha Trang', N'0906 777 168', N'09:00 - 22:00', N'https://maps.google.com/?q=15+Tran+Phu+Nha+Trang', N'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=900&q=85', N'["Wifi","Máy lạnh","Mang đi"]', 8, 0, N'TEMPORARILY_CLOSED');
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.franchise_contents)
BEGIN
    INSERT INTO dbo.franchise_contents (section_key, title, content, amount, note, sort_order, status) VALUES
    (N'benefits', N'Công thức đồng bộ', N'Định lượng, topping và quy trình pha chế để đào tạo nhanh.', NULL, NULL, 1, N'ACTIVE'),
    (N'benefits', N'Nhận diện sẵn sàng', N'Bộ màu, menu, bảng hiệu và vật phẩm bán hàng thống nhất.', NULL, NULL, 2, N'ACTIVE'),
    (N'benefits', N'Hỗ trợ khai trương', N'Checklist vận hành, truyền thông tại điểm bán và theo dõi sau mở bán.', NULL, NULL, 3, N'ACTIVE'),
    (N'benefits', N'Chuỗi cung ứng tinh gọn', N'Ưu tiên nguyên liệu dễ kiểm soát, lưu kho rõ ràng và ít hao hụt.', NULL, NULL, 4, N'ACTIVE'),
    (N'conditions', N'Mặt bằng', N'Diện tích từ 12m2, mặt tiền dễ nhận diện và có khu vực bảo quản nguyên liệu.', NULL, NULL, 1, N'ACTIVE'),
    (N'conditions', N'Vốn đầu tư', N'Nguồn vốn phù hợp với gói kiosk, cửa hàng tiêu chuẩn hoặc flagship mini.', NULL, NULL, 2, N'ACTIVE'),
    (N'conditions', N'Vận hành', N'Cam kết tuân thủ quy trình sản phẩm, vệ sinh và dịch vụ của thương hiệu.', NULL, NULL, 3, N'ACTIVE'),
    (N'process', N'Tiếp nhận thông tin', N'Đội ngũ ALOO liên hệ và xác nhận nhu cầu đầu tư.', NULL, NULL, 1, N'ACTIVE'),
    (N'process', N'Khảo sát khu vực', N'Đánh giá lưu lượng khách, đối thủ và mức chi phí mặt bằng.', NULL, NULL, 2, N'ACTIVE'),
    (N'process', N'Triển khai cửa hàng', N'Thiết kế, lắp đặt, đào tạo và chuẩn bị khai trương.', NULL, NULL, 3, N'ACTIVE'),
    (N'process', N'Đào tạo vận hành', N'Đào tạo pha chế, bán hàng, kiểm kho và chăm sóc khách.', NULL, NULL, 4, N'ACTIVE'),
    (N'costs', N'Gói xe đẩy / kiosk', NULL, N'120 - 180 triệu', N'Phù hợp điểm bán nhỏ, chi phí gọn.', 1, N'ACTIVE'),
    (N'costs', N'Gói cửa hàng tiêu chuẩn', NULL, N'280 - 450 triệu', N'Dành cho mặt bằng phố hoặc trung tâm khu dân cư.', 2, N'ACTIVE'),
    (N'costs', N'Gói flagship mini', NULL, N'500 - 750 triệu', N'Không gian trải nghiệm đầy đủ và nhận diện nổi bật.', 3, N'ACTIVE');
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.brand_timelines)
BEGIN
    INSERT INTO dbo.brand_timelines (timeline_year, title, description, image_url, sort_order, status) VALUES
    (N'Khởi đầu', N'Tập trung vào một sản phẩm chủ lực', N'ALOO chọn kem bơ làm lõi sản phẩm để giữ công thức gọn, dễ kiểm soát chất lượng và dễ đào tạo.', N'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=900&q=85', 1, N'ACTIVE'),
    (N'Chuẩn hóa', N'Đưa trải nghiệm vào mô hình cửa hàng', N'Từ menu, hình ảnh, quy trình phục vụ đến nguyên liệu đều được đóng gói thành tiêu chuẩn vận hành.', N'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=900&q=85', 2, N'ACTIVE'),
    (N'Mở rộng', N'Sẵn sàng cho hệ thống và nhượng quyền', N'Mô hình hướng tới chi phí hợp lý, nhận diện nhất quán và dữ liệu quản trị được đồng bộ qua CMS.', N'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=900&q=85', 3, N'ACTIVE'),
    (N'Tối ưu', N'Quản trị bằng dữ liệu thật', N'CMS kết nối sản phẩm, bài viết, địa điểm, lead và nội dung thương hiệu để vận hành minh bạch.', N'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=900&q=85', 4, N'ACTIVE');
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.posts)
BEGIN
    DECLARE @now DATETIME2(0) = GETDATE();
    INSERT INTO dbo.posts (category_id, title, slug, excerpt, content, thumbnail_url, author, source, article_type, status, published_at, seo_title, seo_description, meta_keywords, tags) VALUES
    ((SELECT TOP 1 id FROM dbo.categories WHERE slug = N'cau-chuyen-thuong-hieu'), N'Câu chuyện kem bơ thuần Việt của ALOO', N'cau-chuyen-kem-bo-thuan-viet-cua-aloo', N'Hành trình xây dựng hương vị kem bơ gần gũi với người Việt.', N'<h2>Giới thiệu</h2><p>ALOO phát triển từ ý tưởng đưa món kem bơ quen thuộc vào mô hình cửa hàng hiện đại.</p>', N'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=1200&q=85', N'ALOO Editorial', N'ALOO', N'Câu chuyện thương hiệu', N'PUBLISHED', DATEADD(day, -1, @now), N'Câu chuyện kem bơ thuần Việt của ALOO', N'Hành trình xây dựng hương vị kem bơ gần gũi với người Việt.', N'kem bơ,ALOO,thương hiệu', N'kem bơ,ALOO,thương hiệu'),
    ((SELECT TOP 1 id FROM dbo.categories WHERE slug = N'nhuong-quyen'), N'Mô hình nhượng quyền kiosk kem bơ cần chuẩn bị gì?', N'mo-hinh-nhuong-quyen-kiosk-kem-bo-can-gi', N'Các hạng mục cần chuẩn bị trước khi mở kiosk kem bơ.', N'<h2>Mặt bằng</h2><p>Kiosk cần vị trí dễ nhìn, lưu lượng ổn định và đủ không gian bảo quản nguyên liệu.</p>', N'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=1200&q=85', N'ALOO Franchise Team', N'ALOO', N'Hướng dẫn nhượng quyền', N'PUBLISHED', DATEADD(day, -2, @now), N'Mô hình nhượng quyền kiosk kem bơ cần chuẩn bị gì?', N'Checklist chuẩn bị mô hình kiosk kem bơ.', N'nhượng quyền,kiosk,vận hành', N'nhượng quyền,kiosk,vận hành'),
    ((SELECT TOP 1 id FROM dbo.categories WHERE slug = N'review'), N'Review kem bơ truyền thống ALOO', N'review-kem-bo-truyen-thong-aloo', N'Món signature giữ vị bơ sáp tự nhiên, kem mát và topping cân bằng.', N'<h2>Vị bơ</h2><p>Phần bơ được xay mịn, giữ độ béo tự nhiên nhưng không quá ngọt.</p>', N'https://images.unsplash.com/photo-1497034825429-c343d7c6a68f?auto=format&fit=crop&w=1200&q=85', N'ALOO Editorial', N'ALOO', N'Review địa điểm', N'PUBLISHED', DATEADD(day, -3, @now), N'Review kem bơ truyền thống ALOO', N'Đánh giá món kem bơ truyền thống ALOO.', N'review,kem bơ,sản phẩm', N'review,kem bơ,sản phẩm'),
    ((SELECT TOP 1 id FROM dbo.categories WHERE slug = N'van-hanh'), N'Vận hành cửa hàng kem bơ trong giờ cao điểm', N'van-hanh-cua-hang-kem-bo-gio-cao-diem', N'Chuẩn bị nguyên liệu, phân vai nhân sự và tối ưu luồng order.', N'<h2>Chuẩn bị trước ca</h2><p>Nguyên liệu cần được chia sẵn theo định lượng để giảm thời gian thao tác.</p>', N'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=1200&q=85', N'ALOO Franchise Team', N'ALOO', N'Hướng dẫn vận hành', N'PUBLISHED', DATEADD(day, -4, @now), N'Vận hành cửa hàng kem bơ trong giờ cao điểm', N'Kinh nghiệm vận hành cửa hàng kem bơ khi đông khách.', N'vận hành,cửa hàng,giờ cao điểm', N'vận hành,cửa hàng,giờ cao điểm'),
    ((SELECT TOP 1 id FROM dbo.categories WHERE slug = N'tin-tuc'), N'ALOO cập nhật menu mùa hè', N'aloo-cap-nhat-menu-mua-he', N'Một số món lạnh và topping mới được bổ sung cho mùa hè.', N'<h2>Menu mùa hè</h2><p>Các món ưu tiên vị mát, thao tác nhanh và nguyên liệu dễ kiểm soát.</p>', N'https://images.unsplash.com/photo-1551024601-bec78aea704b?auto=format&fit=crop&w=1200&q=85', N'ALOO Editorial', N'ALOO', N'Tin tức', N'PUBLISHED', DATEADD(day, -5, @now), N'ALOO cập nhật menu mùa hè', N'Cập nhật menu mùa hè của ALOO.', N'menu,tin tức,mùa hè', N'menu,tin tức,mùa hè'),
    ((SELECT TOP 1 id FROM dbo.categories WHERE slug = N'nhuong-quyen'), N'Cách chọn mặt bằng bán kem bơ hiệu quả', N'cach-chon-mat-bang-ban-kem-bo', N'Mặt bằng tốt cần phù hợp thói quen mua đồ ăn vặt.', N'<h2>Lưu lượng khách</h2><p>Khu dân cư, trường học, văn phòng là nhóm vị trí đáng cân nhắc.</p>', N'https://images.unsplash.com/photo-1521305916504-4a1121188589?auto=format&fit=crop&w=1200&q=85', N'ALOO Franchise Team', N'ALOO', N'Bài SEO', N'PUBLISHED', DATEADD(day, -6, @now), N'Cách chọn mặt bằng bán kem bơ hiệu quả', N'Kinh nghiệm chọn mặt bằng bán kem bơ.', N'mặt bằng,kinh doanh,nhượng quyền', N'mặt bằng,kinh doanh,nhượng quyền'),
    ((SELECT TOP 1 id FROM dbo.categories WHERE slug = N'cau-chuyen-thuong-hieu'), N'Nhận diện thương hiệu ALOO tại điểm bán', N'nhan-dien-thuong-hieu-aloo-tai-diem-ban', N'Màu sắc, menu và trưng bày giúp khách nhận ra ALOO nhanh hơn.', N'<h2>Nhận diện</h2><p>Bộ nhận diện cần rõ ràng từ xa, dễ nhớ và đồng bộ giữa các điểm bán.</p>', N'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=1200&q=85', N'ALOO Editorial', N'ALOO', N'Câu chuyện thương hiệu', N'PUBLISHED', DATEADD(day, -7, @now), N'Nhận diện thương hiệu ALOO tại điểm bán', N'Cách ALOO xây dựng nhận diện tại cửa hàng.', N'nhận diện,thương hiệu,cửa hàng', N'nhận diện,thương hiệu,cửa hàng'),
    ((SELECT TOP 1 id FROM dbo.categories WHERE slug = N'review'), N'Kem bơ sầu riêng có gì khác biệt?', N'kem-bo-sau-rieng-co-gi-khac-biet', N'Phiên bản đậm vị hơn cho khách thích hương sầu riêng.', N'<h2>Hương vị</h2><p>Sầu riêng tạo điểm nhấn rõ, trong khi nền bơ giúp món ăn không bị gắt.</p>', N'https://images.unsplash.com/photo-1505252585461-04db1eb84625?auto=format&fit=crop&w=1200&q=85', N'ALOO Editorial', N'ALOO', N'Review địa điểm', N'PUBLISHED', DATEADD(day, -8, @now), N'Kem bơ sầu riêng có gì khác biệt?', N'Đánh giá vị kem bơ sầu riêng ALOO.', N'sầu riêng,kem bơ,review', N'sầu riêng,kem bơ,review'),
    ((SELECT TOP 1 id FROM dbo.categories WHERE slug = N'van-hanh'), N'Checklist khai trương cửa hàng ALOO', N'checklist-khai-truong-cua-hang-aloo', N'Các hạng mục cần chuẩn bị trước ngày khai trương.', N'<h2>Checklist</h2><p>Kiểm tra nguyên liệu, máy móc, bảng hiệu, POS và đội hình vận hành.</p>', N'https://images.unsplash.com/photo-1521017432531-fbd92d768814?auto=format&fit=crop&w=1200&q=85', N'ALOO Franchise Team', N'ALOO', N'Hướng dẫn vận hành', N'DRAFT', NULL, N'Checklist khai trương cửa hàng ALOO', N'Checklist khai trương cửa hàng ALOO.', N'khai trương,checklist,vận hành', N'khai trương,checklist,vận hành'),
    ((SELECT TOP 1 id FROM dbo.categories WHERE slug = N'tin-tuc'), N'ALOO thử nghiệm vị matcha mới', N'aloo-thu-nghiem-vi-matcha-moi', N'Một phiên bản mới đang được đội R&D thử nghiệm.', N'<h2>R&D</h2><p>Vị matcha hướng tới nhóm khách thích hậu vị thanh, ít ngọt.</p>', N'https://images.unsplash.com/photo-1570197788417-0e82375c9371?auto=format&fit=crop&w=1200&q=85', N'ALOO Editorial', N'ALOO', N'Tin tức', N'PENDING', NULL, N'ALOO thử nghiệm vị matcha mới', N'Thử nghiệm sản phẩm matcha mới.', N'matcha,R&D,tin tức', N'matcha,R&D,tin tức');

    INSERT INTO dbo.post_images (post_id, image_url, alt_text, image_type, sort_order)
    SELECT id, thumbnail_url, title, N'THUMBNAIL', 1 FROM dbo.posts WHERE thumbnail_url IS NOT NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.franchise_registrations)
BEGIN
    INSERT INTO dbo.franchise_registrations (full_name, phone, email, province, expected_budget, note, status) VALUES
    (N'Nguyễn Minh Anh', N'0918246579', N'minhanh@example.com', N'TP.HCM', 350000000, N'Muốn mở kiosk gần khu chung cư, cần tư vấn mặt bằng.', N'NEW'),
    (N'Trần Quang Huy', N'0936728145', N'quanghuy@example.com', N'Đà Nẵng', 500000000, N'Đã có mặt bằng mặt tiền, muốn tìm hiểu gói cửa hàng tiêu chuẩn.', N'CONTACTED'),
    (N'Lê Thu Hà', N'0974512386', N'thuha@example.com', N'Cần Thơ', 250000000, N'Quan tâm mô hình xe đẩy/kiosk.', N'CONSULTING'),
    (N'Phạm Gia Huy', N'0907638219', N'giahuy@example.com', N'Hà Nội', 700000000, N'Muốn mở flagship mini tại khu văn phòng.', N'DONE'),
    (N'Đỗ Mai Linh', N'0928415763', N'mailinh@example.com', N'Bình Dương', 180000000, N'Tạm dừng kế hoạch do chưa tìm được mặt bằng phù hợp.', N'CANCELED'),
    (N'Võ Thành Nam', N'0987654321', N'thanhnam@example.com', N'Khánh Hòa', 420000000, N'Có mặt bằng gần biển, cần tư vấn thiết kế nhận diện.', N'NEW'),
    (N'Hoàng Bảo Ngọc', N'0966123456', N'baongoc@example.com', N'Bình Định', 300000000, N'Quan tâm khu vực Quy Nhơn, muốn xem menu poster chi nhánh.', N'CONTACTED'),
    (N'Bùi Quốc Việt', N'0944556677', N'quocviet@example.com', N'Đồng Nai', 550000000, N'Cần báo giá thiết bị và chi phí nguyên liệu ban đầu.', N'CONSULTING');
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.contact_messages)
BEGIN



    INSERT INTO dbo.contact_messages (full_name, email, phone, subject, message, status) VALUES
    (N'Nguyễn Khánh An', N'khanhan@example.com', N'0901111222', N'Hỏi thông tin sản phẩm', N'Tôi muốn biết sản phẩm nào phù hợp cho trẻ em.', N'NEW'),
    (N'Lê Hoàng Minh', N'hoangminh@example.com', N'0902222333', N'Góp ý cửa hàng', N'Cửa hàng phục vụ tốt, mong thêm lựa chọn ít ngọt.', N'READ'),
    (N'Trần Hương Giang', N'huonggiang@example.com', N'0903333444', N'Hợp tác truyền thông', N'Tôi muốn liên hệ hợp tác review sản phẩm ALOO.', N'NEW'),
    (N'Phạm Đức Anh', N'ducanh@example.com', N'0904444555', N'Liên hệ website', N'Tôi cần hỗ trợ cập nhật thông tin tài khoản.', N'REPLIED'),
    (N'Vũ Thảo Vy', N'thaovy@example.com', N'0905555666', N'Tư vấn sự kiện', N'Tôi muốn đặt quầy kem bơ cho sự kiện công ty.', N'ARCHIVED');
END
GO

PRINT N'ALOO sample data inserted. Login admin/user password: 123456';
GO

