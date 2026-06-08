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

IF NOT EXISTS (SELECT 1 FROM dbo.categories WHERE type = N'PRODUCT' AND slug = N'kem')
BEGIN
    INSERT INTO dbo.categories (name, slug, type, description, sort_order, status, language_code) VALUES
    (N'Kem', N'kem', N'PRODUCT', N'Các món kem ly theo menu ALOO.', 1, N'ACTIVE', N'vi'),
    (N'Kem bơ', N'kem-bo', N'PRODUCT', N'Các món kem bơ signature ALOO.', 2, N'ACTIVE', N'vi'),
    (N'Thiên đường bơ ngon', N'thien-duong-bo-ngon', N'PRODUCT', N'Sinh tố và chè bơ trong nhóm bơ đặc trưng.', 3, N'ACTIVE', N'vi'),
    (N'Cà phê', N'ca-phe', N'PRODUCT', N'Cà phê và đồ uống pha chế theo menu.', 4, N'ACTIVE', N'vi'),
    (N'Sinh tố', N'sinh-to', N'PRODUCT', N'Các món sinh tố trái cây tươi mát.', 5, N'ACTIVE', N'vi'),
    (N'Nước ép nguyên chất', N'nuoc-ep-nguyen-chat', N'PRODUCT', N'Nước ép trái cây nguyên chất.', 6, N'ACTIVE', N'vi'),
    (N'Nước ép mix', N'nuoc-ep-mix', N'PRODUCT', N'Nước ép phối nhiều loại trái cây.', 7, N'ACTIVE', N'vi'),
    (N'Trà trái cây', N'tra-trai-cay', N'PRODUCT', N'Trà trái cây thanh mát.', 8, N'ACTIVE', N'vi'),
    (N'Topping', N'topping', N'PRODUCT', N'Topping ăn kèm kem bơ, kem ly và sinh tố.', 9, N'ACTIVE', N'vi'),
    (N'Ăn vặt', N'an-vat', N'PRODUCT', N'Món ăn vặt bán kèm tại cửa hàng.', 10, N'ACTIVE', N'vi');
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
INSERT INTO dbo.products
(category_id, name, slug, description, short_description, price, image_url, category, sort_order, featured, status)
VALUES

/* KEM */
((SELECT id FROM dbo.categories WHERE slug = N'kem'), N'Kem dừa', N'kem-dua',
 N'Kem vị dừa mát lạnh, thơm béo nhẹ.', N'Coconut ice cream', 18000, NULL, N'Kem', 1, 1, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'kem'), N'Kem dâu', N'kem-dau',
 N'Kem vị dâu chua ngọt, dễ ăn.', N'Strawberry ice cream', 18000, NULL, N'Kem', 2, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'kem'), N'Kem socola', N'kem-socola',
 N'Kem socola đậm vị, phù hợp khách thích vị cacao.', N'Chocolate ice cream', 18000, NULL, N'Kem', 3, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'kem'), N'Kem khoai môn', N'kem-khoai-mon',
 N'Kem khoai môn thơm nhẹ, béo mịn.', N'Taro ice cream', 18000, NULL, N'Kem', 4, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'kem'), N'Kem sắc màu tùy chọn', N'kem-sac-mau-tuy-chon',
 N'Kem nhiều màu, khách có thể chọn vị theo sở thích.', N'Colorful ice cream', 25000, NULL, N'Kem', 5, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'kem'), N'Trái cây tươi dầm kem', N'trai-cay-tuoi-dam-kem',
 N'Trái cây tươi ăn kèm kem mát lạnh.', N'Mixed fresh fruit with ice cream', 28000, NULL, N'Kem', 6, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'kem'), N'Buffet kem như ý', N'buffet-kem-nhu-y',
 N'Buffet kem nhiều vị, phù hợp nhóm khách thích trải nghiệm đa dạng.', N'Buffet ice cream', 49000, NULL, N'Kem', 7, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'kem'), N'Kem ốc quế tùy vị', N'kem-oc-que-tuy-vi',
 N'Kem ốc quế tùy chọn vị.', N'Ice cream cone', 12000, NULL, N'Kem', 8, 0, N'ACTIVE'),


/* KEM BƠ */
((SELECT id FROM dbo.categories WHERE slug = N'kem-bo'), N'Kem bơ ALOO đặc biệt', N'kem-bo-aloo-dac-biet',
 N'Kem bơ signature với bơ sáp chín tự nhiên, kem tươi mát lạnh và topping giòn thơm.', N'ALOO Premium Avocado Ice Cream', 38000, NULL, N'Kem bơ', 9, 1, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'kem-bo'), N'Kem bơ dừa', N'kem-bo-dua',
 N'Kem bơ kết hợp dừa, vị béo mát và thơm nhẹ.', N'Avocado Coconut Ice Cream', 25000, NULL, N'Kem bơ', 10, 1, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'kem-bo'), N'Kem bơ mãng cầu', N'kem-bo-mang-cau',
 N'Kem bơ phối mãng cầu, vị chua nhẹ cân bằng độ béo.', N'Soursop & Avocado Ice Cream', 31000, NULL, N'Kem bơ', 11, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'kem-bo'), N'Kem bơ xoài', N'kem-bo-xoai',
 N'Kem bơ kết hợp xoài chín, hương vị nhiệt đới.', N'Mango & Avocado Ice Cream', 31000, NULL, N'Kem bơ', 12, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'kem-bo'), N'Kem bơ sầu riêng', N'kem-bo-sau-rieng',
 N'Kem bơ kết hợp sầu riêng đậm vị.', N'Durian & Avocado Ice Cream', 33000, NULL, N'Kem bơ', 13, 1, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'kem-bo'), N'Kem bơ sắc màu', N'kem-bo-sac-mau',
 N'Kem bơ nhiều màu, phù hợp khách thích món bắt mắt.', N'Colorful Avocado Ice Cream', 38000, NULL, N'Kem bơ', 14, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'kem-bo'), N'Kem sầu riêng tươi', N'kem-sau-rieng-tuoi',
 N'Kem sầu riêng tươi thơm béo, vị đặc trưng.', N'Fresh Durian Ice Cream', 42000, NULL, N'Kem bơ', 15, 0, N'ACTIVE'),


/* THIÊN ĐƯỜNG BƠ NGON */
((SELECT id FROM dbo.categories WHERE slug = N'thien-duong-bo-ngon'), N'Sinh tố bơ', N'sinh-to-bo',
 N'Sinh tố bơ sánh mịn, vị bơ tự nhiên.', N'Avocado smoothie', 29000, NULL, N'Thiên đường bơ ngon', 16, 1, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'thien-duong-bo-ngon'), N'Sinh tố bơ mãng cầu', N'sinh-to-bo-mang-cau',
 N'Sinh tố bơ mix mãng cầu, vị chua ngọt dễ uống.', N'Avocado & Soursop Smoothie', 32000, NULL, N'Thiên đường bơ ngon', 17, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'thien-duong-bo-ngon'), N'Sinh tố bơ xoài', N'sinh-to-bo-xoai',
 N'Sinh tố bơ mix xoài chín.', N'Avocado & Mango Smoothie', 32000, NULL, N'Thiên đường bơ ngon', 18, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'thien-duong-bo-ngon'), N'Sinh tố bơ cafe', N'sinh-to-bo-cafe',
 N'Sinh tố bơ kết hợp cà phê, béo nhẹ và thơm.', N'Avocado & Coffee Smoothie', 32000, NULL, N'Thiên đường bơ ngon', 19, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'thien-duong-bo-ngon'), N'Sinh tố bơ sầu riêng', N'sinh-to-bo-sau-rieng',
 N'Sinh tố bơ sầu riêng đậm vị nhiệt đới.', N'Avocado & Durian Smoothie', 35000, NULL, N'Thiên đường bơ ngon', 20, 1, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'thien-duong-bo-ngon'), N'Sinh tố bơ dâu', N'sinh-to-bo-dau',
 N'Sinh tố bơ dâu, vị béo và chua ngọt hài hòa.', N'Avocado & Strawberry Smoothie', 35000, NULL, N'Thiên đường bơ ngon', 21, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'thien-duong-bo-ngon'), N'Bơ dầm', N'bo-dam',
 N'Bơ dầm sữa đặc, món tráng miệng béo mịn.', N'Mashed Avocado with Condensed Milk', 35000, NULL, N'Thiên đường bơ ngon', 22, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'thien-duong-bo-ngon'), N'Chè bơ', N'che-bo',
 N'Chè bơ kiểu Việt, mát lạnh và thơm bơ.', N'Vietnamese Avocado Dessert', 29000, NULL, N'Thiên đường bơ ngon', 23, 0, N'ACTIVE'),


/* CÀ PHÊ */
((SELECT id FROM dbo.categories WHERE slug = N'ca-phe'), N'Cà phê đen', N'ca-phe-den',
 N'Cà phê đen pha phin hoặc pha máy.', N'Black coffee', 18000, NULL, N'Cà phê', 24, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'ca-phe'), N'Cà phê sữa', N'ca-phe-sua',
 N'Cà phê sữa pha phin hoặc pha máy.', N'Condensed milk coffee', 21000, NULL, N'Cà phê', 25, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'ca-phe'), N'Bạc xỉu', N'bac-xiu',
 N'Bạc xỉu nóng hoặc đá, vị sữa nhiều hơn cà phê.', N'Vietnamese white coffee', 28000, NULL, N'Cà phê', 26, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'ca-phe'), N'Cà phê kem sữa dừa', N'ca-phe-kem-sua-dua',
 N'Cà phê kết hợp kem sữa dừa béo thơm.', N'Milk coffee with coconut cream', 32000, NULL, N'Cà phê', 27, 1, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'ca-phe'), N'Cacao nóng đá', N'cacao-nong-da',
 N'Cacao sữa dùng nóng hoặc đá.', N'Cocoa with milk', 25000, NULL, N'Cà phê', 28, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'ca-phe'), N'Matcha Latte', N'matcha-latte',
 N'Matcha latte thơm nhẹ, hậu vị thanh.', N'Matcha Latte', 28000, NULL, N'Cà phê', 29, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'ca-phe'), N'Sữa chua đá', N'sua-chua-da',
 N'Sữa chua đá mát lạnh, dễ uống.', N'Iced yogurt', 22000, NULL, N'Cà phê', 30, 0, N'ACTIVE'),


/* SINH TỐ */
((SELECT id FROM dbo.categories WHERE slug = N'sinh-to'), N'Rau má bơ', N'rau-ma-bo',
 N'Sinh tố rau má bơ thanh mát.', N'Pennywort avocado smoothie', 21000, NULL, N'Sinh tố', 31, 1, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'sinh-to'), N'Sinh tố xoài', N'sinh-to-xoai',
 N'Sinh tố xoài chín thơm ngọt.', N'Mango smoothie', 27000, NULL, N'Sinh tố', 32, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'sinh-to'), N'Sinh tố dâu', N'sinh-to-dau',
 N'Sinh tố dâu chua ngọt, mát lạnh.', N'Strawberry smoothie', 30000, NULL, N'Sinh tố', 33, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'sinh-to'), N'Sinh tố mãng cầu', N'sinh-to-mang-cau',
 N'Sinh tố mãng cầu vị chua nhẹ.', N'Soursop smoothie', 31000, NULL, N'Sinh tố', 34, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'sinh-to'), N'Sinh tố sầu riêng', N'sinh-to-sau-rieng',
 N'Sinh tố sầu riêng đậm vị, béo thơm.', N'Durian smoothie', 38000, NULL, N'Sinh tố', 35, 0, N'ACTIVE'),


/* NƯỚC ÉP NGUYÊN CHẤT */
((SELECT id FROM dbo.categories WHERE slug = N'nuoc-ep-nguyen-chat'), N'Nước ép ổi', N'nuoc-ep-oi',
 N'Nước ép ổi nguyên chất.', N'Guava juice', 22000, NULL, N'Nước ép nguyên chất', 36, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'nuoc-ep-nguyen-chat'), N'Nước ép cóc', N'nuoc-ep-coc',
 N'Nước ép cóc chua nhẹ, thanh mát.', N'Ambarella juice', 22000, NULL, N'Nước ép nguyên chất', 37, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'nuoc-ep-nguyen-chat'), N'Nước ép dưa hấu', N'nuoc-ep-dua-hau',
 N'Nước ép dưa hấu ngọt mát.', N'Watermelon juice', 22000, NULL, N'Nước ép nguyên chất', 38, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'nuoc-ep-nguyen-chat'), N'Nước ép thơm', N'nuoc-ep-thom',
 N'Nước ép thơm vị chua ngọt.', N'Pineapple juice', 25000, NULL, N'Nước ép nguyên chất', 39, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'nuoc-ep-nguyen-chat'), N'Nước ép cà rốt', N'nuoc-ep-ca-rot',
 N'Nước ép cà rốt nguyên chất.', N'Carrot juice', 23000, NULL, N'Nước ép nguyên chất', 40, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'nuoc-ep-nguyen-chat'), N'Nước chanh mật ong', N'nuoc-chanh-mat-ong',
 N'Nước chanh mật ong thanh mát.', N'Honey lemon', 22000, NULL, N'Nước ép nguyên chất', 41, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'nuoc-ep-nguyen-chat'), N'Nước chanh dây', N'nuoc-chanh-day',
 N'Nước chanh dây chua ngọt.', N'Passion fruit juice', 22000, NULL, N'Nước ép nguyên chất', 42, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'nuoc-ep-nguyen-chat'), N'Nước ép cà chua', N'nuoc-ep-ca-chua',
 N'Nước ép cà chua nguyên chất.', N'Tomato juice', 23000, NULL, N'Nước ép nguyên chất', 43, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'nuoc-ep-nguyen-chat'), N'Nước ép táo', N'nuoc-ep-tao',
 N'Nước ép táo tươi.', N'Apple juice', 30000, NULL, N'Nước ép nguyên chất', 44, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'nuoc-ep-nguyen-chat'), N'Nước ép cam', N'nuoc-ep-cam',
 N'Nước ép cam tươi.', N'Orange juice', 27000, NULL, N'Nước ép nguyên chất', 45, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'nuoc-ep-nguyen-chat'), N'Nước ép dâu tây', N'nuoc-ep-dau-tay',
 N'Nước ép dâu tây chua ngọt.', N'Strawberry juice', 28000, NULL, N'Nước ép nguyên chất', 46, 0, N'ACTIVE'),


/* NƯỚC ÉP MIX */
((SELECT id FROM dbo.categories WHERE slug = N'nuoc-ep-mix'), N'Thơm ổi', N'thom-oi',
 N'Nước ép mix thơm và ổi.', N'Pineapple - Guava', 25000, NULL, N'Nước ép mix', 47, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'nuoc-ep-mix'), N'Cóc ổi', N'coc-oi',
 N'Nước ép mix cóc và ổi.', N'Ambarella - Guava', 24000, NULL, N'Nước ép mix', 48, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'nuoc-ep-mix'), N'Cam cà rốt', N'cam-ca-rot',
 N'Nước ép mix cam và cà rốt.', N'Orange - Carrot', 24000, NULL, N'Nước ép mix', 49, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'nuoc-ep-mix'), N'Thơm cà rốt', N'thom-ca-rot',
 N'Nước ép mix thơm và cà rốt.', N'Pineapple - Carrot', 25000, NULL, N'Nước ép mix', 50, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'nuoc-ep-mix'), N'Táo thơm', N'tao-thom',
 N'Nước ép mix táo và thơm.', N'Apple - Pineapple', 28000, NULL, N'Nước ép mix', 51, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'nuoc-ep-mix'), N'Cam táo', N'cam-tao',
 N'Nước ép mix cam và táo.', N'Orange - Apple', 28000, NULL, N'Nước ép mix', 52, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'nuoc-ep-mix'), N'Cam dâu', N'cam-dau',
 N'Nước ép mix cam và dâu.', N'Orange - Strawberry', 27000, NULL, N'Nước ép mix', 53, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'nuoc-ep-mix'), N'Dưa hấu dâu', N'dua-hau-dau',
 N'Nước ép mix dưa hấu và dâu.', N'Watermelon - Strawberry', 27000, NULL, N'Nước ép mix', 54, 0, N'ACTIVE'),


/* TRÀ TRÁI CÂY */
((SELECT id FROM dbo.categories WHERE slug = N'tra-trai-cay'), N'Trà tắc mật ong', N'tra-tac-mat-ong',
 N'Trà tắc mật ong dùng nóng hoặc đá.', N'Honey kumquat tea', 21000, NULL, N'Trà trái cây', 55, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'tra-trai-cay'), N'Trà đào cam', N'tra-dao-cam',
 N'Trà đào cam vị trái cây thanh mát.', N'Peach orange tea', 27000, NULL, N'Trà trái cây', 56, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'tra-trai-cay'), N'Trà trái cây nhiệt đới', N'tra-trai-cay-nhiet-doi',
 N'Trà trái cây nhiệt đới nhiều tầng hương vị.', N'Tropical fruit tea', 27000, NULL, N'Trà trái cây', 57, 1, N'ACTIVE'),


/* TOPPING */
((SELECT id FROM dbo.categories WHERE slug = N'topping'), N'Kem viên', N'kem-vien',
 N'Topping kem viên ăn kèm.', N'Ice cream scoop', 9000, NULL, N'Topping', 58, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'topping'), N'Bơ thêm', N'bo-them',
 N'Topping bơ thêm cho món kem hoặc sinh tố.', N'Avocado added', 9000, NULL, N'Topping', 59, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'topping'), N'Sầu riêng thêm', N'sau-rieng-them',
 N'Topping sầu riêng thêm.', N'Durian added', 9000, NULL, N'Topping', 60, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'topping'), N'Dừa khô 40g', N'dua-kho-40g',
 N'Dừa khô giòn dùng kèm.', N'Dried coconut 40g', 9000, NULL, N'Topping', 61, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'topping'), N'Bánh quế 4 cái', N'banh-que-4-cai',
 N'Bánh quế giòn ăn kèm kem.', N'Wafer biscuits 4 pieces', 9000, NULL, N'Topping', 62, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'topping'), N'Hạnh nhân 20g', N'hanh-nhan-20g',
 N'Hạnh nhân giòn thơm.', N'Almonds 20g', 9000, NULL, N'Topping', 63, 0, N'ACTIVE'),


/* ĂN VẶT */
((SELECT id FROM dbo.categories WHERE slug = N'an-vat'), N'Hạt dưa hạt hướng dương', N'hat-dua-hat-huong-duong',
 N'Hạt dưa và hạt hướng dương ăn vặt.', N'Watermelon seeds - Sunflower seeds', 15000, NULL, N'Ăn vặt', 64, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'an-vat'), N'Bánh tráng trộn', N'banh-trang-tron',
 N'Bánh tráng trộn vị đậm đà.', N'Mixed rice paper salad', 25000, NULL, N'Ăn vặt', 65, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'an-vat'), N'Mực xé tẩm gia vị', N'muc-xe-tam-gia-vi',
 N'Mực xé tẩm gia vị ăn vặt.', N'Seasoned shredded squid', 23000, NULL, N'Ăn vặt', 66, 0, N'ACTIVE'),

((SELECT id FROM dbo.categories WHERE slug = N'an-vat'), N'Trái cây hộp xắt lát', N'trai-cay-hop-xat-lat',
 N'Trái cây hộp xắt lát tiện dùng.', N'Sliced canned fruit', 28000, NULL, N'Ăn vặt', 67, 0, N'ACTIVE');
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.home_sections)
BEGIN
    INSERT INTO dbo.home_sections (section_key, type, title, subtitle, description, image_url, button_text, button_link, badge, sort_order, status) VALUES
    (N'featured-product', N'FEATURED_CARD', N'Kem bơ ALOO đặc biệt', N'Tuyển chọn', N'Kem bơ signature với bơ sáp chín tự nhiên, kem tươi mát lạnh và topping giòn thơm.', N'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=1400&q=85', N'Xem sản phẩm', N'/products/kem-bo-aloo-dac-biet', N'Bán chạy nhất', 1, N'ACTIVE'),
    (N'franchise-model', N'CTA_CARD', N'Mô hình nhượng quyền ALOO', N'Tuyển chọn', N'Cửa hàng tinh gọn, nhận diện trẻ trung, quy trình dễ vận hành cho đối tác mới.', N'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=1400&q=85', N'Tìm hiểu ngay', N'/franchise', N'Cơ hội hợp tác', 2, N'ACTIVE'),
    (N'new-store', N'LOCATION_CARD', N'Cửa hàng ALOO mới', N'Trải nghiệm trực tiếp', N'Không gian phục vụ nhanh, menu kem bơ signature và nhiều topping dễ chọn.', N'https://images.unsplash.com/photo-1514933651103-005eec06c04b?auto=format&fit=crop&w=1400&q=85', N'Xem hệ thống', N'/locations', N'Điểm đến mới', 3, N'INACTIVE');
END
GO
IF NOT EXISTS (SELECT 1 FROM dbo.hero_banners)
BEGIN
    INSERT INTO dbo.hero_banners (title, subtitle, description, background_image_url, product_image_url, thumbnail_image_url, tone, sort_order, status) VALUES
    (N'Kem bơ ALOO đặc biệt', N'Signature ALOO', N'Kem bơ signature với bơ sáp chín tự nhiên, kem tươi mát lạnh và topping giòn thơm.', N'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=1800&q=85', N'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=1200&q=85', N'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=300&q=80', N'light', 1, N'ACTIVE'),
    (N'Kem bơ sầu riêng', N'Tropical Bold', N'Lớp bơ mịn kết hợp sầu riêng đậm vị.', N'https://images.unsplash.com/photo-1497034825429-c343d7c6a68f?auto=format&fit=crop&w=1800&q=85', N'https://images.unsplash.com/photo-1497034825429-c343d7c6a68f?auto=format&fit=crop&w=1200&q=85', N'https://images.unsplash.com/photo-1497034825429-c343d7c6a68f?auto=format&fit=crop&w=300&q=80', N'dark', 2, N'ACTIVE'),
    (N'Sinh tố bơ', N'Creamy Smoothie', N'Sinh tố bơ sánh mịn, vị bơ tự nhiên.', N'https://images.unsplash.com/photo-1505252585461-04db1eb84625?auto=format&fit=crop&w=1800&q=85', N'https://images.unsplash.com/photo-1505252585461-04db1eb84625?auto=format&fit=crop&w=1200&q=85', N'https://images.unsplash.com/photo-1505252585461-04db1eb84625?auto=format&fit=crop&w=300&q=80', N'light', 3, N'ACTIVE'),
    (N'Trà trái cây nhiệt đới', N'Tropical Tea', N'Trà trái cây nhiệt đới nhiều tầng hương vị.', N'https://images.unsplash.com/photo-1551024506-0bccd828d307?auto=format&fit=crop&w=1800&q=85', N'https://images.unsplash.com/photo-1551024506-0bccd828d307?auto=format&fit=crop&w=1200&q=85', N'https://images.unsplash.com/photo-1551024506-0bccd828d307?auto=format&fit=crop&w=300&q=80', N'light', 4, N'INACTIVE');
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

IF NOT EXISTS (SELECT 1 FROM dbo.stores)
BEGIN
    INSERT INTO dbo.stores
    (store_code, name, slug, address, province, district, ward, latitude, longitude, phone, email, google_map_url, store_type, description, cover_image_url, featured, display_order, status)
    VALUES
    (
        N'ALOO-QN-001',
        N'Kem Bơ ALoo - 395 Nguyễn Huệ',
        N'kem-bo-aloo-395-nguyen-hue',
        N'395 Nguyễn Huệ, P. Trần Phú, TP. Quy Nhơn, Bình Định',
        N'Bình Định',
        N'Quy Nhơn',
        N'Trần Phú',
        NULL,
        NULL,
        N'0935 113 589 / 0383 869 253',
        NULL,
        N'https://maps.google.com/?q=Kem+Bơ+ALoo+395+Nguyễn+Huệ+Quy+Nhơn',
        N'FLAGSHIP',
        N'Chi nhánh ALOO Quy Nhơn tại Nguyễn Huệ, một trong các điểm bán chính của thương hiệu kem bơ ALOO.',
        NULL,
        1,
        1,
        N'ACTIVE'
    ),
    (
        N'ALOO-QN-002',
        N'Kem Bơ ALoo - 174 Nguyễn Thị Định',
        N'kem-bo-aloo-174-nguyen-thi-dinh',
        N'174 Nguyễn Thị Định, TP. Quy Nhơn, Bình Định',
        N'Bình Định',
        N'Quy Nhơn',
        NULL,
        NULL,
        NULL,
        N'0935 113 589 / 0383 869 253',
        NULL,
        N'https://maps.google.com/?q=Kem+Bơ+ALoo+174+Nguyễn+Thị+Định+Quy+Nhơn',
        N'STANDARD',
        N'Chi nhánh ALOO tại Nguyễn Thị Định, phục vụ kem bơ, nước ép và sinh tố tại cửa hàng.',
        NULL,
        1,
        2,
        N'ACTIVE'
    ),
    (
        N'ALOO-NT-001',
        N'Kem Bơ ALoo - 120 Hoàng Hoa Thám',
        N'kem-bo-aloo-120-hoang-hoa-tham',
        N'120 Hoàng Hoa Thám, P. Lộc Thọ, TP. Nha Trang, Khánh Hòa',
        N'Khánh Hòa',
        N'Nha Trang',
        N'Lộc Thọ',
        NULL,
        NULL,
        N'0935 113 589 / 0984 666 077',
        NULL,
        N'https://maps.google.com/?q=Kem+Bơ+ALoo+120+Hoàng+Hoa+Thám+Nha+Trang',
        N'STANDARD',
        N'Chi nhánh ALOO Nha Trang tại Hoàng Hoa Thám, phục vụ khách trải nghiệm menu kem bơ tại cửa hàng.',
        NULL,
        1,
        3,
        N'ACTIVE'
    ),
    (
        N'ALOO-NT-002',
        N'Kem Bơ ALoo - 42 Lê Thánh Tôn',
        N'kem-bo-aloo-42-le-thanh-ton',
        N'42 Lê Thánh Tôn, Phố Ẩm Thực Phan Bội Châu, TP. Nha Trang, Khánh Hòa',
        N'Khánh Hòa',
        N'Nha Trang',
        NULL,
        NULL,
        NULL,
        N'02583 510 777',
        NULL,
        N'https://maps.google.com/?q=Kem+Bơ+ALoo+42+Lê+Thánh+Tôn+Nha+Trang',
        N'STANDARD',
        N'Chi nhánh ALOO Nha Trang tại Lê Thánh Tôn, thuộc khu phố ẩm thực Phan Bội Châu.',
        NULL,
        1,
        4,
        N'ACTIVE'
    );
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
    ((SELECT TOP 1 id FROM dbo.categories WHERE slug = N'van-hanh'), N'Vận hành cửa hàng kem bơ trong giờ cao điểm', N'van-hanh-cua-hang-kem-bo-gio-cao-diem', N'Chuẩn bị nguyên liệu, phân vai nhân sự và tối ưu luồng phục vụ.', N'<h2>Chuẩn bị trước ca</h2><p>Nguyên liệu cần được chia sẵn theo định lượng để giảm thời gian thao tác.</p>', N'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=1200&q=85', N'ALOO Franchise Team', N'ALOO', N'Hướng dẫn vận hành', N'PUBLISHED', DATEADD(day, -4, @now), N'Vận hành cửa hàng kem bơ trong giờ cao điểm', N'Kinh nghiệm vận hành cửa hàng kem bơ khi đông khách.', N'vận hành,cửa hàng,giờ cao điểm', N'vận hành,cửa hàng,giờ cao điểm'),
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
    (N'Phạm Gia Huy', N'0907638219', N'giahuy@example.com', N'Hà Nội', 700000000, N'Muốn mở flagship mini tại khu văn phòng.', N'SIGNED'),
    (N'Đỗ Mai Linh', N'0928415763', N'mailinh@example.com', N'Bình Dương', 180000000, N'Tạm dừng kế hoạch do chưa tìm được mặt bằng phù hợp.', N'REJECTED'),
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

PRINT N'ALOO sample data inserted. Login admin password: 123456';
GO



