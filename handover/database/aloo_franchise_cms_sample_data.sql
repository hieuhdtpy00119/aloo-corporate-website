USE ALOO_Franchise_CMS;
GO

-- =============================================================================
-- LOCAL / DEMO ONLY — DO NOT RUN ON PRODUCTION
-- Default password for seeded accounts is well-known (123456).
-- Change every seeded password immediately if this is ever applied by mistake.
-- =============================================================================

-- Sample/demo data for local development and UI testing only.
-- Run after backend/database/aloo_franchise_cms.sql.

DECLARE @passwordHash NVARCHAR(255) = N'$2a$10$.Qt3cc3WDZaSUrprSayKsePkQ/LoBW8z8dzFoSpmNkbLmqwCmuPAu'; -- bcrypt of 123456 (LOCAL ONLY) 

IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE email = N'admin@aloo.vn')
BEGIN
    INSERT INTO dbo.users (email, password_hash, full_name, phone, avatar_url, role, status, admin_profile)
    VALUES (N'admin@aloo.vn', @passwordHash, N'ALOO Admin', N'0900 888 168', NULL, N'ADMIN', N'ACTIVE', N'FULL');
END
ELSE
BEGIN
    UPDATE dbo.users SET admin_profile = COALESCE(admin_profile, N'FULL') WHERE email = N'admin@aloo.vn' AND role = N'ADMIN';
END

IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE email = N'content@aloo.vn')
BEGIN
    INSERT INTO dbo.users (email, password_hash, full_name, phone, avatar_url, role, status, admin_profile)
    VALUES (N'content@aloo.vn', @passwordHash, N'ALOO Content Manager', N'0900 888 169', NULL, N'ADMIN', N'ACTIVE', N'CONTENT');
END
ELSE
BEGIN
    UPDATE dbo.users SET admin_profile = COALESCE(admin_profile, N'CONTENT') WHERE email = N'content@aloo.vn' AND role = N'ADMIN';
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
DECLARE @kemId BIGINT = (SELECT TOP (1) id FROM dbo.categories WHERE type = N'PRODUCT' AND slug = N'kem');
DECLARE @kemBoId BIGINT = (SELECT TOP (1) id FROM dbo.categories WHERE type = N'PRODUCT' AND slug = N'kem-bo');
DECLARE @thienDuongBoId BIGINT = (SELECT TOP (1) id FROM dbo.categories WHERE type = N'PRODUCT' AND slug = N'thien-duong-bo-ngon');
DECLARE @caPheId BIGINT = (SELECT TOP (1) id FROM dbo.categories WHERE type = N'PRODUCT' AND slug = N'ca-phe');
DECLARE @sinhToId BIGINT = (SELECT TOP (1) id FROM dbo.categories WHERE type = N'PRODUCT' AND slug = N'sinh-to');
DECLARE @nuocEpNguyenChatId BIGINT = (SELECT TOP (1) id FROM dbo.categories WHERE type = N'PRODUCT' AND slug = N'nuoc-ep-nguyen-chat');
DECLARE @nuocEpMixId BIGINT = (SELECT TOP (1) id FROM dbo.categories WHERE type = N'PRODUCT' AND slug = N'nuoc-ep-mix');
DECLARE @traTraiCayId BIGINT = (SELECT TOP (1) id FROM dbo.categories WHERE type = N'PRODUCT' AND slug = N'tra-trai-cay');
DECLARE @toppingId BIGINT = (SELECT TOP (1) id FROM dbo.categories WHERE type = N'PRODUCT' AND slug = N'topping');
DECLARE @anVatId BIGINT = (SELECT TOP (1) id FROM dbo.categories WHERE type = N'PRODUCT' AND slug = N'an-vat');

INSERT INTO dbo.products
(category_id, name, slug, description, short_description, price, image_url, category, sort_order, featured, status)
VALUES

/* KEM */
(@kemId, N'Kem dừa', N'kem-dua',
 N'Kem vị dừa mát lạnh, thơm béo nhẹ.', N'Coconut ice cream', 18000, NULL, N'Kem', 1, 1, N'ACTIVE'),

(@kemId, N'Kem dâu', N'kem-dau',
 N'Kem vị dâu chua ngọt, dễ ăn.', N'Strawberry ice cream', 18000, NULL, N'Kem', 2, 0, N'ACTIVE'),

(@kemId, N'Kem socola', N'kem-socola',
 N'Kem socola đậm vị, phù hợp khách thích vị cacao.', N'Chocolate ice cream', 18000, NULL, N'Kem', 3, 0, N'ACTIVE'),

(@kemId, N'Kem khoai môn', N'kem-khoai-mon',
 N'Kem khoai môn thơm nhẹ, béo mịn.', N'Taro ice cream', 18000, NULL, N'Kem', 4, 0, N'ACTIVE'),

(@kemId, N'Kem sắc màu tùy chọn', N'kem-sac-mau-tuy-chon',
 N'Kem nhiều màu, khách có thể chọn vị theo sở thích.', N'Colorful ice cream', 25000, NULL, N'Kem', 5, 0, N'ACTIVE'),

(@kemId, N'Trái cây tươi dầm kem', N'trai-cay-tuoi-dam-kem',
 N'Trái cây tươi ăn kèm kem mát lạnh.', N'Mixed fresh fruit with ice cream', 28000, NULL, N'Kem', 6, 0, N'ACTIVE'),

(@kemId, N'Buffet kem như ý', N'buffet-kem-nhu-y',
 N'Buffet kem nhiều vị, phù hợp nhóm khách thích trải nghiệm đa dạng.', N'Buffet ice cream', 49000, NULL, N'Kem', 7, 0, N'ACTIVE'),

(@kemId, N'Kem ốc quế tùy vị', N'kem-oc-que-tuy-vi',
 N'Kem ốc quế tùy chọn vị.', N'Ice cream cone', 12000, NULL, N'Kem', 8, 0, N'ACTIVE'),


/* KEM BƠ */
(@kemBoId, N'Kem bơ ALOO đặc biệt', N'kem-bo-aloo-dac-biet',
 N'Kem bơ signature với bơ sáp chín tự nhiên, kem tươi mát lạnh và topping giòn thơm.', N'ALOO Premium Avocado Ice Cream', 38000, NULL, N'Kem bơ', 9, 1, N'ACTIVE'),

(@kemBoId, N'Kem bơ dừa', N'kem-bo-dua',
 N'Kem bơ kết hợp dừa, vị béo mát và thơm nhẹ.', N'Avocado Coconut Ice Cream', 25000, NULL, N'Kem bơ', 10, 1, N'ACTIVE'),

(@kemBoId, N'Kem bơ mãng cầu', N'kem-bo-mang-cau',
 N'Kem bơ phối mãng cầu, vị chua nhẹ cân bằng độ béo.', N'Soursop & Avocado Ice Cream', 31000, NULL, N'Kem bơ', 11, 0, N'ACTIVE'),

(@kemBoId, N'Kem bơ xoài', N'kem-bo-xoai',
 N'Kem bơ kết hợp xoài chín, hương vị nhiệt đới.', N'Mango & Avocado Ice Cream', 31000, NULL, N'Kem bơ', 12, 0, N'ACTIVE'),

(@kemBoId, N'Kem bơ sầu riêng', N'kem-bo-sau-rieng',
 N'Kem bơ kết hợp sầu riêng đậm vị.', N'Durian & Avocado Ice Cream', 33000, NULL, N'Kem bơ', 13, 1, N'ACTIVE'),

(@kemBoId, N'Kem bơ sắc màu', N'kem-bo-sac-mau',
 N'Kem bơ nhiều màu, phù hợp khách thích món bắt mắt.', N'Colorful Avocado Ice Cream', 38000, NULL, N'Kem bơ', 14, 0, N'ACTIVE'),

(@kemBoId, N'Kem sầu riêng tươi', N'kem-sau-rieng-tuoi',
 N'Kem sầu riêng tươi thơm béo, vị đặc trưng.', N'Fresh Durian Ice Cream', 42000, NULL, N'Kem bơ', 15, 0, N'ACTIVE'),


/* THIÊN ĐƯỜNG BƠ NGON */
(@thienDuongBoId, N'Sinh tố bơ', N'sinh-to-bo',
 N'Sinh tố bơ sánh mịn, vị bơ tự nhiên.', N'Avocado smoothie', 29000, NULL, N'Thiên đường bơ ngon', 16, 1, N'ACTIVE'),

(@thienDuongBoId, N'Sinh tố bơ mãng cầu', N'sinh-to-bo-mang-cau',
 N'Sinh tố bơ mix mãng cầu, vị chua ngọt dễ uống.', N'Avocado & Soursop Smoothie', 32000, NULL, N'Thiên đường bơ ngon', 17, 0, N'ACTIVE'),

(@thienDuongBoId, N'Sinh tố bơ xoài', N'sinh-to-bo-xoai',
 N'Sinh tố bơ mix xoài chín.', N'Avocado & Mango Smoothie', 32000, NULL, N'Thiên đường bơ ngon', 18, 0, N'ACTIVE'),

(@thienDuongBoId, N'Sinh tố bơ cafe', N'sinh-to-bo-cafe',
 N'Sinh tố bơ kết hợp cà phê, béo nhẹ và thơm.', N'Avocado & Coffee Smoothie', 32000, NULL, N'Thiên đường bơ ngon', 19, 0, N'ACTIVE'),

(@thienDuongBoId, N'Sinh tố bơ sầu riêng', N'sinh-to-bo-sau-rieng',
 N'Sinh tố bơ sầu riêng đậm vị nhiệt đới.', N'Avocado & Durian Smoothie', 35000, NULL, N'Thiên đường bơ ngon', 20, 1, N'ACTIVE'),

(@thienDuongBoId, N'Sinh tố bơ dâu', N'sinh-to-bo-dau',
 N'Sinh tố bơ dâu, vị béo và chua ngọt hài hòa.', N'Avocado & Strawberry Smoothie', 35000, NULL, N'Thiên đường bơ ngon', 21, 0, N'ACTIVE'),

(@thienDuongBoId, N'Bơ dầm', N'bo-dam',
 N'Bơ dầm sữa đặc, món tráng miệng béo mịn.', N'Mashed Avocado with Condensed Milk', 35000, NULL, N'Thiên đường bơ ngon', 22, 0, N'ACTIVE'),

(@thienDuongBoId, N'Chè bơ', N'che-bo',
 N'Chè bơ kiểu Việt, mát lạnh và thơm bơ.', N'Vietnamese Avocado Dessert', 29000, NULL, N'Thiên đường bơ ngon', 23, 0, N'ACTIVE'),


/* CÀ PHÊ */
(@caPheId, N'Cà phê đen', N'ca-phe-den',
 N'Cà phê đen pha phin hoặc pha máy.', N'Black coffee', 18000, NULL, N'Cà phê', 24, 0, N'ACTIVE'),

(@caPheId, N'Cà phê sữa', N'ca-phe-sua',
 N'Cà phê sữa pha phin hoặc pha máy.', N'Condensed milk coffee', 21000, NULL, N'Cà phê', 25, 0, N'ACTIVE'),

(@caPheId, N'Bạc xỉu', N'bac-xiu',
 N'Bạc xỉu nóng hoặc đá, vị sữa nhiều hơn cà phê.', N'Vietnamese white coffee', 28000, NULL, N'Cà phê', 26, 0, N'ACTIVE'),

(@caPheId, N'Cà phê kem sữa dừa', N'ca-phe-kem-sua-dua',
 N'Cà phê kết hợp kem sữa dừa béo thơm.', N'Milk coffee with coconut cream', 32000, NULL, N'Cà phê', 27, 1, N'ACTIVE'),

(@caPheId, N'Cacao nóng đá', N'cacao-nong-da',
 N'Cacao sữa dùng nóng hoặc đá.', N'Cocoa with milk', 25000, NULL, N'Cà phê', 28, 0, N'ACTIVE'),

(@caPheId, N'Matcha Latte', N'matcha-latte',
 N'Matcha latte thơm nhẹ, hậu vị thanh.', N'Matcha Latte', 28000, NULL, N'Cà phê', 29, 0, N'ACTIVE'),

(@caPheId, N'Sữa chua đá', N'sua-chua-da',
 N'Sữa chua đá mát lạnh, dễ uống.', N'Iced yogurt', 22000, NULL, N'Cà phê', 30, 0, N'ACTIVE'),


/* SINH TỐ */
(@sinhToId, N'Rau má bơ', N'rau-ma-bo',
 N'Sinh tố rau má bơ thanh mát.', N'Pennywort avocado smoothie', 21000, NULL, N'Sinh tố', 31, 1, N'ACTIVE'),

(@sinhToId, N'Sinh tố xoài', N'sinh-to-xoai',
 N'Sinh tố xoài chín thơm ngọt.', N'Mango smoothie', 27000, NULL, N'Sinh tố', 32, 0, N'ACTIVE'),

(@sinhToId, N'Sinh tố dâu', N'sinh-to-dau',
 N'Sinh tố dâu chua ngọt, mát lạnh.', N'Strawberry smoothie', 30000, NULL, N'Sinh tố', 33, 0, N'ACTIVE'),

(@sinhToId, N'Sinh tố mãng cầu', N'sinh-to-mang-cau',
 N'Sinh tố mãng cầu vị chua nhẹ.', N'Soursop smoothie', 31000, NULL, N'Sinh tố', 34, 0, N'ACTIVE'),

(@sinhToId, N'Sinh tố sầu riêng', N'sinh-to-sau-rieng',
 N'Sinh tố sầu riêng đậm vị, béo thơm.', N'Durian smoothie', 38000, NULL, N'Sinh tố', 35, 0, N'ACTIVE'),


/* NƯỚC ÉP NGUYÊN CHẤT */
(@nuocEpNguyenChatId, N'Nước ép ổi', N'nuoc-ep-oi',
 N'Nước ép ổi nguyên chất.', N'Guava juice', 22000, NULL, N'Nước ép nguyên chất', 36, 0, N'ACTIVE'),

(@nuocEpNguyenChatId, N'Nước ép cóc', N'nuoc-ep-coc',
 N'Nước ép cóc chua nhẹ, thanh mát.', N'Ambarella juice', 22000, NULL, N'Nước ép nguyên chất', 37, 0, N'ACTIVE'),

(@nuocEpNguyenChatId, N'Nước ép dưa hấu', N'nuoc-ep-dua-hau',
 N'Nước ép dưa hấu ngọt mát.', N'Watermelon juice', 22000, NULL, N'Nước ép nguyên chất', 38, 0, N'ACTIVE'),

(@nuocEpNguyenChatId, N'Nước ép thơm', N'nuoc-ep-thom',
 N'Nước ép thơm vị chua ngọt.', N'Pineapple juice', 25000, NULL, N'Nước ép nguyên chất', 39, 0, N'ACTIVE'),

(@nuocEpNguyenChatId, N'Nước ép cà rốt', N'nuoc-ep-ca-rot',
 N'Nước ép cà rốt nguyên chất.', N'Carrot juice', 23000, NULL, N'Nước ép nguyên chất', 40, 0, N'ACTIVE'),

(@nuocEpNguyenChatId, N'Nước chanh mật ong', N'nuoc-chanh-mat-ong',
 N'Nước chanh mật ong thanh mát.', N'Honey lemon', 22000, NULL, N'Nước ép nguyên chất', 41, 0, N'ACTIVE'),

(@nuocEpNguyenChatId, N'Nước chanh dây', N'nuoc-chanh-day',
 N'Nước chanh dây chua ngọt.', N'Passion fruit juice', 22000, NULL, N'Nước ép nguyên chất', 42, 0, N'ACTIVE'),

(@nuocEpNguyenChatId, N'Nước ép cà chua', N'nuoc-ep-ca-chua',
 N'Nước ép cà chua nguyên chất.', N'Tomato juice', 23000, NULL, N'Nước ép nguyên chất', 43, 0, N'ACTIVE'),

(@nuocEpNguyenChatId, N'Nước ép táo', N'nuoc-ep-tao',
 N'Nước ép táo tươi.', N'Apple juice', 30000, NULL, N'Nước ép nguyên chất', 44, 0, N'ACTIVE'),

(@nuocEpNguyenChatId, N'Nước ép cam', N'nuoc-ep-cam',
 N'Nước ép cam tươi.', N'Orange juice', 27000, NULL, N'Nước ép nguyên chất', 45, 0, N'ACTIVE'),

(@nuocEpNguyenChatId, N'Nước ép dâu tây', N'nuoc-ep-dau-tay',
 N'Nước ép dâu tây chua ngọt.', N'Strawberry juice', 28000, NULL, N'Nước ép nguyên chất', 46, 0, N'ACTIVE'),


/* NƯỚC ÉP MIX */
(@nuocEpMixId, N'Thơm ổi', N'thom-oi',
 N'Nước ép mix thơm và ổi.', N'Pineapple - Guava', 25000, NULL, N'Nước ép mix', 47, 0, N'ACTIVE'),

(@nuocEpMixId, N'Cóc ổi', N'coc-oi',
 N'Nước ép mix cóc và ổi.', N'Ambarella - Guava', 24000, NULL, N'Nước ép mix', 48, 0, N'ACTIVE'),

(@nuocEpMixId, N'Cam cà rốt', N'cam-ca-rot',
 N'Nước ép mix cam và cà rốt.', N'Orange - Carrot', 24000, NULL, N'Nước ép mix', 49, 0, N'ACTIVE'),

(@nuocEpMixId, N'Thơm cà rốt', N'thom-ca-rot',
 N'Nước ép mix thơm và cà rốt.', N'Pineapple - Carrot', 25000, NULL, N'Nước ép mix', 50, 0, N'ACTIVE'),

(@nuocEpMixId, N'Táo thơm', N'tao-thom',
 N'Nước ép mix táo và thơm.', N'Apple - Pineapple', 28000, NULL, N'Nước ép mix', 51, 0, N'ACTIVE'),

(@nuocEpMixId, N'Cam táo', N'cam-tao',
 N'Nước ép mix cam và táo.', N'Orange - Apple', 28000, NULL, N'Nước ép mix', 52, 0, N'ACTIVE'),

(@nuocEpMixId, N'Cam dâu', N'cam-dau',
 N'Nước ép mix cam và dâu.', N'Orange - Strawberry', 27000, NULL, N'Nước ép mix', 53, 0, N'ACTIVE'),

(@nuocEpMixId, N'Dưa hấu dâu', N'dua-hau-dau',
 N'Nước ép mix dưa hấu và dâu.', N'Watermelon - Strawberry', 27000, NULL, N'Nước ép mix', 54, 0, N'ACTIVE'),


/* TRÀ TRÁI CÂY */
(@traTraiCayId, N'Trà tắc mật ong', N'tra-tac-mat-ong',
 N'Trà tắc mật ong dùng nóng hoặc đá.', N'Honey kumquat tea', 21000, NULL, N'Trà trái cây', 55, 0, N'ACTIVE'),

(@traTraiCayId, N'Trà đào cam', N'tra-dao-cam',
 N'Trà đào cam vị trái cây thanh mát.', N'Peach orange tea', 27000, NULL, N'Trà trái cây', 56, 0, N'ACTIVE'),

(@traTraiCayId, N'Trà trái cây nhiệt đới', N'tra-trai-cay-nhiet-doi',
 N'Trà trái cây nhiệt đới nhiều tầng hương vị.', N'Tropical fruit tea', 27000, NULL, N'Trà trái cây', 57, 1, N'ACTIVE'),


/* TOPPING */
(@toppingId, N'Kem viên', N'kem-vien',
 N'Topping kem viên ăn kèm.', N'Ice cream scoop', 9000, NULL, N'Topping', 58, 0, N'ACTIVE'),

(@toppingId, N'Bơ thêm', N'bo-them',
 N'Topping bơ thêm cho món kem hoặc sinh tố.', N'Avocado added', 9000, NULL, N'Topping', 59, 0, N'ACTIVE'),

(@toppingId, N'Sầu riêng thêm', N'sau-rieng-them',
 N'Topping sầu riêng thêm.', N'Durian added', 9000, NULL, N'Topping', 60, 0, N'ACTIVE'),

(@toppingId, N'Dừa khô 40g', N'dua-kho-40g',
 N'Dừa khô giòn dùng kèm.', N'Dried coconut 40g', 9000, NULL, N'Topping', 61, 0, N'ACTIVE'),

(@toppingId, N'Bánh quế 4 cái', N'banh-que-4-cai',
 N'Bánh quế giòn ăn kèm kem.', N'Wafer biscuits 4 pieces', 9000, NULL, N'Topping', 62, 0, N'ACTIVE'),

(@toppingId, N'Hạnh nhân 20g', N'hanh-nhan-20g',
 N'Hạnh nhân giòn thơm.', N'Almonds 20g', 9000, NULL, N'Topping', 63, 0, N'ACTIVE'),


/* ĂN VẶT */
(@anVatId, N'Hạt dưa hạt hướng dương', N'hat-dua-hat-huong-duong',
 N'Hạt dưa và hạt hướng dương ăn vặt.', N'Watermelon seeds - Sunflower seeds', 15000, NULL, N'Ăn vặt', 64, 0, N'ACTIVE'),

(@anVatId, N'Bánh tráng trộn', N'banh-trang-tron',
 N'Bánh tráng trộn vị đậm đà.', N'Mixed rice paper salad', 25000, NULL, N'Ăn vặt', 65, 0, N'ACTIVE'),

(@anVatId, N'Mực xé tẩm gia vị', N'muc-xe-tam-gia-vi',
 N'Mực xé tẩm gia vị ăn vặt.', N'Seasoned shredded squid', 23000, NULL, N'Ăn vặt', 66, 0, N'ACTIVE'),

(@anVatId, N'Trái cây hộp xắt lát', N'trai-cay-hop-xat-lat',
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
    (N'Kem bơ ALOO đặc biệt', N'Signature ALOO', N'Kem bơ signature với bơ sáp chín tự nhiên, kem tươi mát lạnh và topping giòn thơm.', N'/media/products/aloo-products-hero-ai.webp', N'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=1200&q=85', N'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=300&q=80', N'light', 1, N'ACTIVE'),
    (N'Kem bơ sầu riêng', N'Tropical Bold', N'Lớp bơ mịn kết hợp sầu riêng đậm vị.', N'/media/products/aloo-products-hero-durian-ai.webp', N'https://images.unsplash.com/photo-1497034825429-c343d7c6a68f?auto=format&fit=crop&w=1200&q=85', N'https://images.unsplash.com/photo-1497034825429-c343d7c6a68f?auto=format&fit=crop&w=300&q=80', N'dark', 2, N'ACTIVE'),
    (N'Sinh tố bơ', N'Creamy Smoothie', N'Sinh tố bơ sánh mịn, vị bơ tự nhiên.', N'/media/products/aloo-products-hero-smoothie-ai.webp', N'https://images.unsplash.com/photo-1505252585461-04db1eb84625?auto=format&fit=crop&w=1200&q=85', N'https://images.unsplash.com/photo-1505252585461-04db1eb84625?auto=format&fit=crop&w=300&q=80', N'light', 3, N'ACTIVE'),
    (N'Trà trái cây nhiệt đới', N'Tropical Tea', N'Trà trái cây nhiệt đới nhiều tầng hương vị.', N'https://images.unsplash.com/photo-1551024506-0bccd828d307?auto=format&fit=crop&w=1800&q=85', N'https://images.unsplash.com/photo-1551024506-0bccd828d307?auto=format&fit=crop&w=1200&q=85', N'https://images.unsplash.com/photo-1551024506-0bccd828d307?auto=format&fit=crop&w=300&q=80', N'light', 4, N'INACTIVE');
END
GO

UPDATE dbo.hero_banners
SET background_image_url = N'/media/products/aloo-products-hero-ai.webp',
    updated_at = GETDATE()
WHERE title = N'Kem bơ ALOO đặc biệt';
GO

UPDATE dbo.hero_banners
SET background_image_url = CASE title
        WHEN N'Kem bơ sầu riêng' THEN N'/media/products/aloo-products-hero-durian-ai.webp'
        WHEN N'Sinh tố bơ' THEN N'/media/products/aloo-products-hero-smoothie-ai.webp'
    END,
    updated_at = GETDATE()
WHERE title IN (N'Kem bơ sầu riêng', N'Sinh tố bơ');
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
    (N'hero', N'Khởi nghiệp cùng ALOO – Mô hình kem bơ dễ vận hành', N'{"title":"Khởi nghiệp cùng ALOO – Mô hình kem bơ dễ vận hành","subtitle":"Nhượng quyền kem bơ ALOO","description":"Đồng hành từ khảo sát mặt bằng đến setup cửa hàng, đào tạo vận hành và khai trương thực tế.","image":"https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=1800&q=85","buttonText":"Nhận tư vấn miễn phí","buttonLink":"/consultation","secondaryButtonText":"Xem chi phí đầu tư","secondaryButtonLink":"#investment"}', NULL, NULL, 1, N'ACTIVE'),
    (N'advantages', N'Sản phẩm khác biệt', N'{"icon":"product","title":"Sản phẩm khác biệt","description":"Kem bơ là sản phẩm chủ lực dễ ghi nhớ, phù hợp khí hậu Việt Nam và có biên độ sáng tạo topping tốt."}', NULL, NULL, 1, N'ACTIVE'),
    (N'advantages', N'Dễ vận hành', N'{"icon":"operation","title":"Dễ vận hành","description":"Menu tinh gọn, định lượng rõ và quy trình pha chế chuẩn giúp đào tạo nhân sự nhanh hơn."}', NULL, NULL, 2, N'ACTIVE'),
    (N'advantages', N'Chi phí hợp lý', N'{"icon":"cost","title":"Chi phí hợp lý","description":"Nhiều mô hình đầu tư từ kiosk đến flagship để phù hợp mặt bằng và ngân sách của từng khu vực."}', NULL, NULL, 3, N'ACTIVE'),
    (N'advantages', N'Hỗ trợ toàn diện', N'{"icon":"support","title":"Hỗ trợ toàn diện","description":"Đồng hành khảo sát, setup, đào tạo, khai trương và theo dõi vận hành sau mở bán."}', NULL, NULL, 4, N'ACTIVE'),
    (N'advantages', N'Marketing đồng hành', N'{"icon":"marketing","title":"Marketing đồng hành","description":"Cung cấp bộ nhận diện, nội dung truyền thông và checklist khai trương tại điểm bán."}', NULL, NULL, 5, N'ACTIVE'),
    (N'advantages', N'Thương hiệu đang phát triển', N'{"icon":"brand","title":"Thương hiệu đang phát triển","description":"ALOO tập trung xây dựng hình ảnh trẻ, gần gũi và có khả năng nhân rộng tại nhiều khu vực."}', NULL, NULL, 6, N'ACTIVE'),
    (N'models', N'Kiosk', N'{"modelName":"Kiosk","area":"12–20m²","investment":"120–180 triệu","description":"Phù hợp mặt bằng nhỏ, khu dân cư, trường học hoặc vị trí có lưu lượng mua mang đi cao.","image":"https://images.unsplash.com/photo-1521017432531-fbd92d768814?auto=format&fit=crop&w=900&q=85","featured":false}', N'120–180 triệu', NULL, 1, N'ACTIVE'),
    (N'models', N'Standard', N'{"modelName":"Standard","area":"20–50m²","investment":"280–450 triệu","description":"Mô hình cân bằng giữa trải nghiệm tại chỗ và vận hành tinh gọn, phù hợp phố thương mại.","image":"https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=900&q=85","featured":true}', N'280–450 triệu', NULL, 2, N'ACTIVE'),
    (N'models', N'Flagship', N'{"modelName":"Flagship","area":"50m²+","investment":"500–750 triệu","description":"Không gian nhận diện nổi bật, phù hợp khu trung tâm, du lịch hoặc vị trí chiến lược.","image":"https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=900&q=85","featured":false}', N'500–750 triệu', NULL, 3, N'ACTIVE'),
    (N'investment', N'Nhượng quyền & setup thương hiệu', N'{"itemName":"Nhượng quyền & setup thương hiệu","kioskValue":"Theo gói","standardValue":"Theo gói","flagshipValue":"Theo gói","note":"Bao gồm hướng dẫn nhận diện, layout và quy trình triển khai."}', NULL, NULL, 1, N'ACTIVE'),
    (N'investment', N'Thiết bị & quầy pha chế', N'{"itemName":"Thiết bị & quầy pha chế","kioskValue":"60–90 triệu","standardValue":"130–220 triệu","flagshipValue":"250–360 triệu","note":"Tùy diện tích, công suất và cấu hình mặt bằng."}', NULL, NULL, 2, N'ACTIVE'),
    (N'investment', N'Bảng hiệu & nội thất', N'{"itemName":"Bảng hiệu & nội thất","kioskValue":"30–50 triệu","standardValue":"90–150 triệu","flagshipValue":"180–260 triệu","note":"Tùy vật liệu, diện tích mặt tiền và thiết kế không gian."}', NULL, NULL, 3, N'ACTIVE'),
    (N'investment', N'Nguyên liệu ban đầu', N'{"itemName":"Nguyên liệu ban đầu","kioskValue":"15–25 triệu","standardValue":"30–50 triệu","flagshipValue":"50–80 triệu","note":"Tùy dự kiến sản lượng và khu vực vận hành."}', NULL, NULL, 4, N'ACTIVE'),
    (N'profit', N'Khách/ngày', N'{"metric":"Khách/ngày","value":"80–180","description":"Lượng khách tham khảo với vị trí có lưu lượng ổn định và vận hành đều."}', NULL, NULL, 1, N'ACTIVE'),
    (N'profit', N'Giá trị đơn hàng', N'{"metric":"Giá trị đơn hàng","value":"35–65k","description":"Tùy menu, topping và thói quen tiêu dùng tại từng khu vực."}', NULL, NULL, 2, N'ACTIVE'),
    (N'profit', N'Doanh thu tham khảo', N'{"metric":"Doanh thu tham khảo","value":"90–300 triệu/tháng","description":"Không phải cam kết lợi nhuận; kết quả phụ thuộc mặt bằng, đội ngũ và thị trường."}', NULL, NULL, 3, N'ACTIVE'),
    (N'process', N'Đăng ký tư vấn', N'{"stepNumber":1,"title":"Đăng ký tư vấn","description":"Đối tác để lại thông tin và khu vực mong muốn mở cửa hàng."}', NULL, NULL, 1, N'ACTIVE'),
    (N'process', N'Tư vấn mô hình', N'{"stepNumber":2,"title":"Tư vấn mô hình","description":"ALOO đề xuất mô hình phù hợp ngân sách, diện tích và mục tiêu kinh doanh."}', NULL, NULL, 2, N'ACTIVE'),
    (N'process', N'Khảo sát mặt bằng', N'{"stepNumber":3,"title":"Khảo sát mặt bằng","description":"Đánh giá vị trí, lưu lượng khách, đối thủ và khả năng setup vận hành."}', NULL, NULL, 3, N'ACTIVE'),
    (N'process', N'Ký kết hợp đồng', N'{"stepNumber":4,"title":"Ký kết hợp đồng","description":"Thống nhất phạm vi hỗ trợ, timeline triển khai và tiêu chuẩn vận hành."}', NULL, NULL, 4, N'ACTIVE'),
    (N'process', N'Setup cửa hàng', N'{"stepNumber":5,"title":"Setup cửa hàng","description":"Triển khai nhận diện, thiết bị, đào tạo đội ngũ và chuẩn bị nguyên liệu."}', NULL, NULL, 5, N'ACTIVE'),
    (N'process', N'Khai trương', N'{"stepNumber":6,"title":"Khai trương","description":"Hỗ trợ checklist khai trương, truyền thông tại điểm bán và theo dõi vận hành."}', NULL, NULL, 6, N'ACTIVE'),
    (N'founder_story', N'Câu chuyện ALOO', N'{"founderName":"Đội ngũ sáng lập ALOO","image":"https://images.unsplash.com/photo-1556761175-b413da4baf72?auto=format&fit=crop&w=900&q=85","title":"Từ một món kem bơ quen thuộc đến mô hình cửa hàng có thể nhân rộng","storyContent":"ALOO được xây dựng với tư duy sản phẩm rõ ràng: tập trung vào món chủ lực, chuẩn hóa công thức và tạo trải nghiệm điểm bán dễ nhận diện. Tầm nhìn của ALOO là phát triển một mô hình F&B vừa gần gũi với khách Việt, vừa đủ tinh gọn để đối tác có thể vận hành bền vững."}', NULL, NULL, 1, N'ACTIVE'),
    (N'faq', N'Mất bao lâu để mở cửa hàng?', N'{"question":"Mất bao lâu để mở cửa hàng?","answer":"Thông thường quá trình từ tư vấn, khảo sát, setup đến khai trương mất khoảng 30–60 ngày tùy mặt bằng và quy mô mô hình."}', NULL, NULL, 1, N'ACTIVE'),
    (N'faq', N'Có cần kinh nghiệm F&B không?', N'{"question":"Có cần kinh nghiệm F&B không?","answer":"Không bắt buộc. ALOO cung cấp đào tạo quy trình pha chế, bán hàng, vệ sinh và vận hành cơ bản trước khai trương."}', NULL, NULL, 2, N'ACTIVE'),
    (N'faq', N'Có hỗ trợ marketing không?', N'{"question":"Có hỗ trợ marketing không?","answer":"Có. Đối tác được hỗ trợ bộ nhận diện, nội dung khai trương và định hướng truyền thông tại điểm bán."}', NULL, NULL, 3, N'ACTIVE'),
    (N'faq', N'Có hỗ trợ khai trương không?', N'{"question":"Có hỗ trợ khai trương không?","answer":"Có. ALOO đồng hành theo checklist khai trương, setup menu, kiểm tra quy trình và tư vấn vận hành giai đoạn đầu."}', NULL, NULL, 4, N'ACTIVE'),
    (N'cta', N'Sẵn sàng mở cửa hàng ALOO?', N'{"title":"Sẵn sàng mở cửa hàng ALOO?","description":"Đăng ký tư vấn để đội ngũ ALOO phân tích khu vực, mô hình phù hợp và dự toán chi phí đầu tư.","buttonText":"Nhận tư vấn miễn phí","buttonLink":"/consultation"}', NULL, NULL, 1, N'ACTIVE');
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

-- Enrich the sample blog posts for both fresh databases and databases that already
-- contain the original short seed records. These updates are intentionally
-- idempotent and only target the known sample slugs.
UPDATE dbo.posts
SET excerpt = N'Từ món kem bơ quen thuộc của miền nhiệt đới, ALOO từng bước chuẩn hóa hương vị, trải nghiệm cửa hàng và cách phục vụ để xây dựng một thương hiệu gần gũi với người Việt.',
    content = N'<h2>Từ một món ăn quen thuộc</h2><p>Kem bơ vốn không phải là món xa lạ với người Việt. Vị béo tự nhiên của bơ sáp, cảm giác mát lạnh của kem và một chút giòn vui miệng từ topping đã tạo nên ký ức ẩm thực của nhiều thế hệ. ALOO bắt đầu từ chính sự gần gũi đó, với mong muốn làm món kem bơ chỉn chu hơn nhưng vẫn giữ được nét thân thuộc.</p><p>Thay vì xây dựng một menu quá rộng ngay từ đầu, đội ngũ chọn tập trung vào sản phẩm chủ lực. Cách tiếp cận này giúp từng công đoạn, từ chọn nguyên liệu, sơ chế, định lượng đến trình bày, được quan sát và cải tiến liên tục.</p><h2>Giữ vị bơ làm trung tâm</h2><p>Trong một ly kem bơ, nguyên liệu chính cần được nhận ra ngay từ muỗng đầu tiên. Bơ phải có độ chín phù hợp, thịt dẻo, vị béo rõ nhưng không để lại cảm giác nặng. Phần kem đóng vai trò cân bằng, tạo nhiệt độ mát và làm kết cấu tổng thể mượt hơn.</p><p>ALOO hướng tới vị ngọt vừa phải để hương bơ không bị che lấp. Topping được lựa chọn theo nguyên tắc bổ sung kết cấu thay vì cạnh tranh hương vị: một chút giòn, một chút thơm và đủ lượng để mỗi muỗng vẫn giữ được sự cân đối.</p><blockquote>Điều quan trọng không phải làm món ăn trở nên cầu kỳ, mà là làm những điều quen thuộc thật ổn định và dễ nhớ.</blockquote><h2>Từ công thức đến tiêu chuẩn</h2><p>Một công thức ngon tại một thời điểm chưa đủ để trở thành sản phẩm có thể phục vụ mỗi ngày. Đội ngũ cần chuyển kinh nghiệm pha chế thành định lượng, thời gian thao tác và tiêu chí kiểm tra rõ ràng. Mỗi mẻ nguyên liệu đều được đánh giá về màu sắc, độ chín và mùi vị trước khi đưa vào quầy.</p><ul><li>Nguyên liệu được bảo quản theo từng nhóm nhiệt độ.</li><li>Định lượng được chuẩn hóa để hương vị giữa các ca không chênh lệch.</li><li>Dụng cụ tiếp xúc thực phẩm được vệ sinh theo checklist.</li><li>Thành phẩm được kiểm tra trước khi giao cho khách.</li></ul><h2>Một trải nghiệm dễ nhận diện</h2><p>Câu chuyện thương hiệu không chỉ nằm trong sản phẩm. Màu sắc cửa hàng, bảng menu, cách chào khách và tốc độ phục vụ đều góp phần tạo nên cảm nhận chung. ALOO lựa chọn ngôn ngữ hình ảnh tươi sáng, thân thiện và dễ nhận biết từ xa.</p><p>Ở mỗi điểm bán, mục tiêu là để khách có thể nhanh chóng hiểu món chủ lực là gì, chọn món thuận tiện và nhận được sản phẩm trong trạng thái tốt nhất. Trải nghiệm đơn giản nhưng nhất quán là nền tảng để một lần ghé thử có thể trở thành thói quen.</p><h2>Hành trình vẫn đang tiếp tục</h2><p>Từ một món kem bơ thuần Việt, ALOO tiếp tục thử nghiệm những cách kết hợp mới, cải thiện quy trình và lắng nghe phản hồi tại từng khu vực. Mỗi thay đổi đều cần trả lời hai câu hỏi: sản phẩm có ngon hơn không và cửa hàng có vận hành ổn định hơn không.</p><p>ALOO xem sự phát triển bền vững là quá trình tích lũy từ những chi tiết nhỏ. Giữ sản phẩm rõ ràng, tiêu chuẩn dễ áp dụng và trải nghiệm gần gũi là cách thương hiệu tiếp tục kể câu chuyện kem bơ theo một hình thức hiện đại hơn.</p>',
    seo_description = N'Khám phá hành trình ALOO phát triển món kem bơ thuần Việt thành sản phẩm được chuẩn hóa trong mô hình cửa hàng hiện đại.'
WHERE slug = N'cau-chuyen-kem-bo-thuan-viet-cua-aloo';

UPDATE dbo.posts
SET excerpt = N'Mở một kiosk kem bơ cần nhiều hơn một quầy đẹp: từ mặt bằng, điện nước, thiết bị, nguyên liệu đến nhân sự và kế hoạch khai trương đều phải được chuẩn bị theo checklist.',
    content = N'<h2>Hiểu đúng về mô hình kiosk</h2><p>Kiosk là mô hình có diện tích gọn, tập trung vào bán mang đi và tối ưu tốc độ phục vụ. Ưu điểm của mô hình này là chi phí mặt bằng và nhân sự thường thấp hơn cửa hàng đầy đủ. Tuy nhiên, không gian nhỏ cũng khiến mọi quyết định về bố trí thiết bị, lưu trữ và luồng di chuyển phải chính xác hơn.</p><p>Trước khi ký hợp đồng mặt bằng, nhà đầu tư nên xác định nhóm khách chính, khung giờ bán tốt và khả năng tiếp cận của khách đi bộ lẫn khách đi xe. Một vị trí đông người chưa chắc phù hợp nếu khách khó dừng lại hoặc quầy bị che khuất.</p><h2>Checklist khảo sát mặt bằng</h2><ul><li>Mặt tiền có dễ quan sát từ hướng di chuyển chính không.</li><li>Khu vực có chỗ dừng xe hoặc nhận đơn giao hàng thuận tiện không.</li><li>Nguồn điện, nước sạch và thoát nước có đáp ứng thiết bị không.</li><li>Quy định của tòa nhà hoặc khu thương mại về bảng hiệu và giờ hoạt động.</li><li>Không gian có đủ chỗ cho quầy pha chế, kho nhỏ và khu rửa dụng cụ không.</li></ul><p>Nên khảo sát ít nhất ba khung giờ trong ngày và thực hiện vào cả ngày thường lẫn cuối tuần. Việc quan sát thực tế giúp tránh đánh giá mặt bằng chỉ dựa trên cảm giác tại một thời điểm.</p><h2>Thiết bị và bố trí quầy</h2><p>Thiết bị cần được chọn theo sản lượng dự kiến thay vì mua theo danh sách càng nhiều càng tốt. Một kiosk cơ bản thường cần khu bảo quản lạnh, khu sơ chế, khu hoàn thiện món, bồn rửa, vị trí đặt POS và khu giao hàng. Các thiết bị sử dụng thường xuyên nên nằm trong tầm thao tác để nhân viên không phải di chuyển chéo nhau.</p><p>Bản vẽ quầy nên mô phỏng một đơn hàng từ lúc tiếp nhận đến lúc giao cho khách. Nếu hai nhân viên cùng làm việc, cần kiểm tra họ có thể thao tác đồng thời mà không chắn lối hay không.</p><h2>Nguyên liệu và kiểm soát tồn kho</h2><p>Bơ là nguyên liệu có độ chín thay đổi theo ngày, vì vậy kế hoạch nhập hàng phải gắn với dự báo doanh số. Nhập quá ít gây thiếu hàng trong giờ cao điểm; nhập quá nhiều làm tăng hao hụt. Nên chia tồn kho thành nguyên liệu đang chín, nguyên liệu sẵn sàng sử dụng và nguyên liệu dự phòng.</p><p>Mỗi ca cần ghi nhận lượng đầu kỳ, lượng sử dụng và lượng hủy. Dữ liệu đơn giản này giúp người quản lý điều chỉnh định mức mua hàng và phát hiện chênh lệch sớm.</p><h2>Nhân sự và đào tạo</h2><p>Kiosk tinh gọn thường yêu cầu nhân viên có thể đảm nhiệm nhiều vị trí. Chương trình đào tạo nên bao gồm công thức, vệ sinh an toàn thực phẩm, sử dụng POS, xử lý giờ cao điểm và giao tiếp với khách. Trước khai trương, đội ngũ cần chạy thử với các tình huống đơn lẻ, đơn nhóm và đơn giao hàng cùng lúc.</p><h2>Ngân sách dự phòng và kế hoạch khai trương</h2><p>Ngoài chi phí thiết bị và thi công, cần có ngân sách cho tiền cọc, nguyên liệu ban đầu, đồng phục, phần mềm bán hàng, vật tư tiêu hao và marketing địa phương. Một khoản dự phòng giúp cửa hàng xử lý các phát sinh mà không làm gián đoạn tiến độ.</p><p>Khai trương nên được xem là một giai đoạn kiểm thử vận hành. Có thể bắt đầu bằng soft opening để đo tốc độ phục vụ, ghi nhận phản hồi và điều chỉnh ca làm trước khi triển khai chương trình truyền thông lớn.</p>',
    seo_description = N'Checklist chuẩn bị mặt bằng, thiết bị, nguyên liệu, nhân sự và ngân sách trước khi mở kiosk kem bơ.'
WHERE slug = N'mo-hinh-nhuong-quyen-kiosk-kem-bo-can-gi';

UPDATE dbo.posts
SET excerpt = N'Bài review chi tiết về kem bơ truyền thống ALOO: hương bơ, độ ngọt, kết cấu kem, topping, khẩu phần và cách thưởng thức để cảm nhận món signature trọn vẹn.',
    content = N'<h2>Ấn tượng từ muỗng đầu tiên</h2><p>Kem bơ truyền thống là món thể hiện rõ nhất cách ALOO cân bằng giữa nguyên liệu quen thuộc và trải nghiệm hiện đại. Thành phẩm có màu xanh tự nhiên, phần bơ mịn và lớp kem lạnh vừa đủ để tạo cảm giác tươi mát ngay khi dùng.</p><p>Hương bơ xuất hiện trước, sau đó là vị béo nhẹ của kem và độ giòn của topping. Món không đi theo hướng quá ngọt, vì nếu lượng đường lấn át thì đặc trưng của bơ sáp sẽ khó được nhận ra.</p><h2>Hương vị và độ ngọt</h2><p>Phần bơ giữ được mùi thơm nhẹ, không có vị đắng hoặc cảm giác xơ. Độ ngọt ở mức dễ ăn, phù hợp cả với khách dùng món tráng miệng lẫn khách muốn một bữa xế. Khi bơ và kem tan cùng nhau, hậu vị vẫn gọn thay vì để lại cảm giác ngấy kéo dài.</p><p>Khách thích vị đậm có thể trộn kỹ hơn để bơ phủ đều phần kem. Nếu muốn cảm nhận từng lớp, nên dùng lần lượt một ít bơ, kem và topping trong cùng một muỗng.</p><h2>Kết cấu là điểm đáng chú ý</h2><p>Một ly kem bơ ngon không chỉ dựa vào vị. Bơ cần đủ mịn, kem phải giữ form nhưng không quá cứng, topping phải giòn mà không làm món bị khô. Sự thay đổi kết cấu giữa mềm, lạnh và giòn khiến món ăn thú vị đến những muỗng cuối.</p><ul><li>Bơ: mịn, dẻo và có độ béo tự nhiên.</li><li>Kem: mát, tan vừa phải, hỗ trợ vị bơ.</li><li>Topping: tạo điểm giòn và mùi thơm nhẹ.</li><li>Tổng thể: dễ trộn, không bị tách nước quá nhanh.</li></ul><h2>Khẩu phần và thời điểm thưởng thức</h2><p>Khẩu phần tiêu chuẩn phù hợp cho một người dùng trong bữa xế. Với người ăn nhẹ, món có thể chia sẻ cùng một đồ uống ít ngọt. Kem bơ ngon nhất khi dùng ngay sau khi nhận để phần kem chưa tan nhiều và topping còn giữ độ giòn.</p><p>Nếu mang đi, nên hạn chế để sản phẩm ngoài nhiệt độ phòng quá lâu. Khi nhận món giao tận nơi, có thể trộn nhẹ từ dưới lên để kết cấu trở lại đồng đều.</p><h2>Phù hợp với ai?</h2><p>Phiên bản truyền thống phù hợp với khách lần đầu thử ALOO vì thể hiện rõ hương vị cốt lõi. Món cũng hợp với người thích tráng miệng béo nhưng không muốn độ ngọt quá cao. Khách yêu topping đậm vị có thể chọn phiên bản mở rộng sau khi đã trải nghiệm bản gốc.</p><h2>Đánh giá tổng thể</h2><p>Điểm mạnh của kem bơ truyền thống ALOO nằm ở sự rõ ràng: bơ là trung tâm, kem làm nền và topping tạo nhịp. Đây không phải món cần quá nhiều thành phần để gây ấn tượng. Khi nguyên liệu đạt độ chín phù hợp và sản phẩm được phục vụ đúng nhiệt độ, sự đơn giản lại trở thành nét dễ nhớ nhất.</p>',
    seo_description = N'Review chi tiết hương vị, kết cấu, độ ngọt và cách thưởng thức kem bơ truyền thống ALOO.'
WHERE slug = N'review-kem-bo-truyen-thong-aloo';

UPDATE dbo.posts
SET excerpt = N'Giờ cao điểm sẽ nhẹ hơn khi cửa hàng dự báo đúng sản lượng, chia sẵn nguyên liệu, phân vai rõ ràng và tổ chức một luồng đơn hàng thống nhất từ POS đến quầy giao.',
    content = N'<h2>Giờ cao điểm bắt đầu trước khi khách đến</h2><p>Khả năng phục vụ nhanh không được tạo ra trong lúc quầy đã đông. Nó đến từ việc dự báo lượng khách, chuẩn bị nguyên liệu và kiểm tra thiết bị trước ca. Người quản lý nên xem dữ liệu bán hàng theo ngày trong tuần và theo khung giờ để quyết định mức chuẩn bị phù hợp.</p><p>Mục tiêu không phải chuẩn bị càng nhiều càng tốt mà là đủ cho giai đoạn cao điểm, có phương án bổ sung nhanh và vẫn kiểm soát được chất lượng.</p><h2>Checklist trước ca</h2><ul><li>Kiểm tra nhiệt độ tủ lạnh và tình trạng thiết bị.</li><li>Đánh giá độ chín của bơ, chia nhóm sử dụng trước và sau.</li><li>Chuẩn bị topping theo khay nhỏ có nắp và nhãn thời gian.</li><li>Bổ sung ly, muỗng, khăn giấy và vật tư đóng gói.</li><li>Kiểm tra POS, máy in hóa đơn và kết nối đơn giao hàng.</li><li>Brief nhanh mục tiêu ca, chương trình bán hàng và món tạm hết.</li></ul><h2>Phân vai theo luồng đơn hàng</h2><p>Khi có từ hai nhân sự trở lên, mỗi người cần biết vị trí ưu tiên của mình. Một người tiếp nhận và xác nhận đơn, một người thực hiện sản phẩm, người còn lại hoàn thiện topping, đóng gói và giao món. Vai trò có thể đổi khi lượng khách thay đổi nhưng không nên đổi liên tục trong từng đơn.</p><p>Đơn tại quầy và đơn giao hàng cần đi vào cùng một hàng đợi có thứ tự rõ ràng. Nếu mỗi kênh tự gọi món bằng một cách khác nhau, quầy dễ bỏ sót hoặc làm trùng.</p><h2>Giảm thao tác không tạo giá trị</h2><p>Mọi dụng cụ nên được đặt theo tần suất sử dụng. Nguyên liệu chính nằm gần vùng thao tác, vật tư dự phòng ở tầng dưới hoặc kho sau, khu đóng gói tách khỏi khu sơ chế ướt. Nhân viên không nên phải quay người nhiều lần để hoàn thành một món cơ bản.</p><p>Công thức được hiển thị ngắn gọn bằng định lượng và thứ tự thao tác. Việc ghi nhớ theo cảm tính có thể nhanh với nhân viên cũ nhưng gây chậm và sai lệch khi có người mới.</p><h2>Giao tiếp trong ca đông</h2><p>Cả đội nên dùng câu gọi đơn thống nhất, chẳng hạn số đơn, món cần làm và yêu cầu đặc biệt. Khi nguyên liệu sắp hết, thông tin phải được báo sớm để POS chủ động tư vấn món thay thế. Tránh để khách thanh toán xong mới biết sản phẩm không còn.</p><blockquote>Tốc độ tốt là giao đúng món trong thời gian hợp lý, không phải làm nhanh bằng cách bỏ qua bước kiểm tra.</blockquote><h2>Kiểm soát chất lượng và vệ sinh</h2><p>Dù đông khách, mỗi món vẫn cần bước nhìn lại trước khi giao: đúng loại, đúng topping, bao bì sạch và nắp kín. Bề mặt quầy nên được vệ sinh nhanh theo chu kỳ, dụng cụ bẩn được chuyển khỏi vùng làm món ngay thay vì để tích tụ.</p><h2>Sau cao điểm</h2><p>Kết thúc đợt đông khách, người phụ trách ghi nhận món bán mạnh, thời gian chờ, nguyên liệu thiếu và lỗi phát sinh. Một cuộc trao đổi năm phút sau ca có thể tạo ra thay đổi hữu ích cho ngày hôm sau. Khi dữ liệu được tích lũy đều, kế hoạch nhân sự và chuẩn bị nguyên liệu sẽ ngày càng sát thực tế.</p>',
    seo_description = N'Quy trình chuẩn bị nguyên liệu, phân vai nhân sự và tối ưu luồng phục vụ cửa hàng kem bơ trong giờ cao điểm.'
WHERE slug = N'van-hanh-cua-hang-kem-bo-gio-cao-diem';

UPDATE dbo.posts
SET excerpt = N'Menu mùa hè của ALOO tập trung vào cảm giác mát, vị trái cây rõ, topping có kết cấu và quy trình đủ gọn để cửa hàng phục vụ ổn định trong những ngày đông khách.',
    content = N'<h2>Một menu dành cho thời tiết nóng</h2><p>Mùa hè là thời điểm khách ưu tiên những món mát, dễ dùng và có hương vị tươi sáng. Khi phát triển menu theo mùa, ALOO không chỉ cân nhắc sản phẩm mới có hấp dẫn hay không mà còn xem món đó có phù hợp với năng lực vận hành tại cửa hàng.</p><p>Các lựa chọn mới được xây dựng quanh nền sản phẩm quen thuộc, giúp khách dễ hình dung hương vị và giúp nhân viên không phải học một quy trình hoàn toàn khác.</p><h2>Nguyên tắc phát triển món mới</h2><ul><li>Hương vị chính phải rõ ràng ngay từ lần thử đầu tiên.</li><li>Độ ngọt được cân bằng để phù hợp thời tiết nóng.</li><li>Topping bổ sung kết cấu nhưng không làm món khó sử dụng.</li><li>Nguyên liệu có thể bảo quản và định lượng ổn định.</li><li>Thời gian hoàn thiện món phù hợp giờ cao điểm.</li></ul><h2>Nhóm vị thanh mát</h2><p>Một số lựa chọn ưu tiên trái cây có độ chua nhẹ để cân bằng nền kem béo. Cách kết hợp này tạo cảm giác tươi hơn và phù hợp với khách không thích món tráng miệng quá đậm. Phần sốt được dùng vừa đủ để hương trái cây xuất hiện nhưng không che mất vị bơ.</p><h2>Topping mới và trải nghiệm kết cấu</h2><p>Bên cạnh hương vị, menu mùa hè chú trọng sự thay đổi giữa mềm, mịn và giòn. Topping được thử nghiệm ở nhiều kích thước để đảm bảo khách có thể dùng thuận tiện bằng muỗng và sản phẩm vẫn đẹp khi mang đi.</p><p>Mỗi topping đều có định lượng riêng. Việc thêm quá nhiều không chỉ làm lệch vị mà còn khiến chất lượng giữa các ly thiếu ổn định.</p><h2>Thử nghiệm tại cửa hàng</h2><p>Trước khi áp dụng rộng, món mới được chạy thử theo từng giai đoạn. Đội ngũ theo dõi tốc độ phục vụ, phản hồi về độ ngọt, tỷ lệ khách gọi lại và lượng nguyên liệu hao hụt. Những dữ liệu này giúp quyết định món nào nên giữ lâu dài và món nào chỉ phù hợp cho chiến dịch ngắn hạn.</p><h2>Gợi ý chọn món</h2><p>Khách lần đầu có thể bắt đầu bằng kem bơ truyền thống để cảm nhận nền vị đặc trưng. Người thích hương thơm đậm có thể chọn phiên bản sầu riêng, còn người muốn hậu vị thanh nên thử nhóm trái cây hoặc matcha khi có tại cửa hàng.</p><p>Thông tin món và tình trạng phục vụ có thể khác nhau giữa từng điểm bán. Khách nên kiểm tra menu tại cửa hàng gần nhất hoặc theo dõi kênh chính thức của ALOO trước khi ghé.</p><h2>Menu thay đổi nhưng tiêu chuẩn không đổi</h2><p>Sự mới mẻ chỉ có ý nghĩa khi sản phẩm vẫn được phục vụ ổn định. Vì vậy, mỗi món theo mùa đều đi kèm hướng dẫn bảo quản, định lượng, hình ảnh chuẩn và checklist thao tác. Đây là cách ALOO làm mới trải nghiệm mà vẫn giữ được nền tảng vận hành nhất quán.</p>',
    seo_description = N'Khám phá định hướng menu mùa hè ALOO với các món lạnh, vị trái cây và topping mới được thiết kế cho thời tiết nóng.'
WHERE slug = N'aloo-cap-nhat-menu-mua-he';

UPDATE dbo.posts
SET excerpt = N'Hướng dẫn đánh giá mặt bằng bán kem bơ dựa trên khách mục tiêu, lưu lượng thật, khả năng dừng xe, chi phí thuê, đối thủ và điều kiện kỹ thuật thay vì chỉ nhìn vào vị trí đông người.',
    content = N'<h2>Bắt đầu từ khách hàng mục tiêu</h2><p>Một mặt bằng hiệu quả là nơi nhóm khách mục tiêu xuất hiện đều đặn và có nhu cầu phù hợp với sản phẩm. Với kem bơ và đồ ăn vặt, các khu dân cư, trường học, văn phòng, tuyến du lịch và khu mua sắm đều có tiềm năng, nhưng hành vi mua ở mỗi nơi rất khác nhau.</p><p>Trước khi đi xem mặt bằng, nhà đầu tư nên mô tả khách chính về độ tuổi, thời điểm mua, mức chi tiêu và hình thức dùng tại chỗ hay mang đi. Bản mô tả này là tiêu chí để loại bỏ những vị trí đông nhưng không đúng khách.</p><h2>Đo lưu lượng thay vì đoán</h2><p>Hãy đứng tại vị trí dự kiến và đếm người qua lại trong từng khoảng 15 hoặc 30 phút. Thực hiện ở buổi sáng, trưa, chiều tối, ngày thường và cuối tuần. Đồng thời ghi nhận hướng di chuyển, tốc độ và tỷ lệ người có thể nhìn thấy bảng hiệu.</p><p>Lưu lượng xe lớn không đồng nghĩa với khả năng mua cao nếu tuyến đường khó quay đầu, không có chỗ dừng hoặc khách di chuyển quá nhanh.</p><h2>Khả năng tiếp cận</h2><ul><li>Có vị trí dừng xe máy an toàn và không cản trở giao thông.</li><li>Tài xế giao hàng có thể nhận đơn mà không làm nghẽn lối vào.</li><li>Mặt tiền không bị cây, biển quảng cáo hoặc xe đỗ che khuất.</li><li>Khách có thể nhận ra cửa hàng trước khi đi qua vị trí.</li><li>Lối vào phù hợp trong điều kiện mưa và buổi tối.</li></ul><h2>Chi phí thuê và doanh thu hòa vốn</h2><p>Không nên đánh giá tiền thuê chỉ bằng con số tuyệt đối. Hãy đưa tiền thuê, phí quản lý, điện nước tối thiểu, tiền cọc và chi phí cải tạo vào bảng dòng tiền. Sau đó ước tính số đơn cần bán mỗi ngày để trang trải chi phí cố định.</p><p>Nên xây dựng ít nhất ba kịch bản: thận trọng, cơ sở và tích cực. Nếu mặt bằng chỉ khả thi trong kịch bản tốt nhất, mức rủi ro có thể quá cao cho giai đoạn đầu.</p><h2>Đối thủ và hệ sinh thái xung quanh</h2><p>Có đối thủ gần đó không luôn là tín hiệu xấu. Sự hiện diện của nhiều quán ăn vặt có thể chứng minh khu vực đã hình thành thói quen tiêu dùng. Điều cần phân tích là mức giá, khung giờ đông, chất lượng trải nghiệm và khoảng trống mà cửa hàng mới có thể đáp ứng.</p><h2>Điều kiện kỹ thuật</h2><p>Nguồn điện phải đủ công suất cho thiết bị lạnh, khu vực cần có nước sạch và hệ thống thoát nước phù hợp. Kiểm tra quyền lắp bảng hiệu, giờ được phép vận chuyển hàng, yêu cầu phòng cháy và giới hạn tiếng ồn. Những vấn đề này nên được xác nhận trước khi đặt cọc.</p><h2>Chấm điểm và ra quyết định</h2><p>Tạo bảng điểm cho khách mục tiêu, lưu lượng, tiếp cận, chi phí, cạnh tranh, kỹ thuật và tiềm năng quảng bá. Dùng cùng một thang điểm cho mọi vị trí để giảm ảnh hưởng của cảm xúc. Mặt bằng tốt nhất không nhất thiết là nơi đẹp nhất, mà là nơi cân bằng được doanh thu tiềm năng, chi phí và khả năng vận hành lâu dài.</p>',
    seo_description = N'Cách khảo sát và chấm điểm mặt bằng bán kem bơ theo lưu lượng khách, chi phí thuê, khả năng tiếp cận và điều kiện vận hành.'
WHERE slug = N'cach-chon-mat-bang-ban-kem-bo';

UPDATE dbo.posts
SET excerpt = N'Nhận diện tại điểm bán không chỉ là logo: màu sắc, bảng hiệu, menu, bao bì, đồng phục và cách phục vụ cần phối hợp nhất quán để khách nhận ra ALOO nhanh và nhớ lâu.',
    content = N'<h2>Điểm bán là nơi thương hiệu trở nên hữu hình</h2><p>Khách có thể biết đến ALOO qua mạng xã hội, nhưng cửa hàng là nơi họ trực tiếp nhìn, chạm và trải nghiệm thương hiệu. Một điểm bán tốt cần giúp khách hiểu nhanh đây là thương hiệu gì, sản phẩm chủ lực là gì và họ nên bắt đầu chọn món từ đâu.</p><p>Nhận diện hiệu quả không đồng nghĩa với phủ logo lên mọi bề mặt. Mỗi yếu tố cần có vai trò rõ ràng và cùng kể một câu chuyện thống nhất.</p><h2>Bảng hiệu nhìn rõ từ hướng di chuyển</h2><p>Kích thước chữ, độ tương phản và ánh sáng phải được kiểm tra từ khoảng cách thực tế. Bảng hiệu đẹp khi nhìn gần nhưng khó đọc từ phía đường sẽ giảm khả năng thu hút khách mới. Với kiosk, phần tên thương hiệu và hình ảnh sản phẩm chủ lực cần được ưu tiên.</p><h2>Màu sắc và vật liệu</h2><p>Bảng màu của ALOO hướng đến cảm giác tươi, tự nhiên và thân thiện. Khi áp dụng vào không gian, cần cân bằng giữa màu nhận diện và các vùng trung tính để cửa hàng không bị nặng thị giác. Vật liệu tại quầy phải dễ vệ sinh và giữ màu tốt trong điều kiện sử dụng thường xuyên.</p><h2>Menu giúp khách quyết định nhanh</h2><ul><li>Nhóm món theo nhu cầu thay vì liệt kê dàn trải.</li><li>Làm nổi bật sản phẩm chủ lực và lựa chọn phổ biến.</li><li>Giá, kích cỡ và topping được trình bày dễ so sánh.</li><li>Hình ảnh phản ánh đúng thành phẩm thực tế.</li><li>Nội dung khuyến mãi không che khuất thông tin chính.</li></ul><p>Menu tại quầy và menu trên kênh giao hàng cần dùng cùng tên món để tránh nhầm lẫn khi nhân viên xác nhận đơn.</p><h2>Bao bì và chi tiết mang theo</h2><p>Với sản phẩm mang đi, ly, túi và tem nhãn tiếp tục đại diện cho thương hiệu sau khi khách rời cửa hàng. Bao bì cần sạch, chắc chắn, dễ cầm và có thông tin vừa đủ. Một thiết kế tốt giúp món ăn được bảo vệ đồng thời tạo cơ hội để người khác nhận ra ALOO.</p><h2>Con người là một phần của nhận diện</h2><p>Đồng phục tạo sự gọn gàng, nhưng cách nhân viên chào hỏi, tư vấn và xử lý vấn đề mới quyết định cảm nhận của khách. Ngôn ngữ phục vụ nên thân thiện, rõ ràng và không gây áp lực mua thêm. Những nguyên tắc này cần được đưa vào đào tạo chứ không chỉ truyền miệng.</p><h2>Kiểm tra tính nhất quán</h2><p>Điểm bán nên được rà soát định kỳ bằng ảnh chụp từ ngoài vào trong. Kiểm tra bảng hiệu, menu, vật phẩm quảng cáo, khu giao hàng và đồng phục có còn đúng chuẩn hay không. Khi có chương trình mới, vật phẩm cũ cần được tháo đúng thời điểm để không tạo thông tin xung đột.</p><p>Sự nhất quán giúp khách yên tâm rằng họ sẽ nhận được trải nghiệm quen thuộc ở mỗi lần ghé. Đó cũng là nền tảng để hệ thống mở rộng mà không làm hình ảnh thương hiệu bị phân mảnh.</p>',
    seo_description = N'Cách xây dựng nhận diện ALOO nhất quán tại điểm bán qua bảng hiệu, màu sắc, menu, bao bì và trải nghiệm phục vụ.'
WHERE slug = N'nhan-dien-thuong-hieu-aloo-tai-diem-ban';

UPDATE dbo.posts
SET excerpt = N'Kem bơ sầu riêng có hương thơm đậm và hậu vị dài hơn bản truyền thống, trong khi nền bơ mịn giúp cân bằng độ béo để món rõ vị nhưng không quá gắt.',
    content = N'<h2>Hai nguyên liệu có cá tính rõ</h2><p>Bơ sáp và sầu riêng đều có độ béo tự nhiên, nhưng mùi hương và hậu vị rất khác nhau. Khi kết hợp, thách thức lớn nhất là giữ được đặc trưng của sầu riêng mà phần bơ vẫn có vai trò trong tổng thể.</p><p>Phiên bản này phù hợp với người đã quen hương sầu riêng. Khách chưa từng thử nên bắt đầu bằng khẩu phần tiêu chuẩn và dùng khi sản phẩm còn lạnh để cảm nhận vị cân bằng nhất.</p><h2>Khác biệt về hương thơm</h2><p>So với kem bơ truyền thống, hương sầu riêng xuất hiện sớm và lưu lại lâu hơn. Nền bơ làm mùi thơm trở nên tròn, giảm cảm giác sắc ở cuối vị. Phần kem lạnh giúp hai nguyên liệu hòa vào nhau thay vì tạo thành hai lớp rời.</p><h2>Độ ngọt và độ béo</h2><p>Vì cả bơ và sầu riêng đều có kết cấu giàu, lượng đường cần được kiểm soát cẩn thận. Độ ngọt vừa phải giúp món không bị nặng sau vài muỗng. Topping nên thiên về giòn và có hương nhẹ, tránh bổ sung thêm một thành phần quá mạnh.</p><h2>Kết cấu khi thưởng thức</h2><ul><li>Phần bơ tạo độ mịn và màu xanh tự nhiên.</li><li>Sầu riêng mang đến kết cấu dẻo và hương thơm nổi bật.</li><li>Kem giữ nhiệt độ mát, làm tổng thể dễ ăn hơn.</li><li>Topping tạo điểm giòn để cân bằng hai thành phần mềm.</li></ul><p>Nên trộn nhẹ trước khi dùng để sầu riêng phân bố đều, nhưng không cần trộn quá lâu vì kem sẽ tan nhanh và làm món mất độ tương phản.</p><h2>So với phiên bản truyền thống</h2><p>Bản truyền thống nhẹ hơn, vị bơ rõ hơn và phù hợp số đông. Bản sầu riêng đậm hương, hậu vị dài và có cảm giác như một món tráng miệng đầy đặn hơn. Không có phiên bản nào tốt hơn tuyệt đối; lựa chọn phụ thuộc vào sở thích về cường độ hương vị.</p><h2>Gợi ý dùng món</h2><p>Kem bơ sầu riêng phù hợp cho bữa xế hoặc món tráng miệng sau một bữa ăn nhẹ. Nếu dùng cùng đồ uống, nên chọn loại ít ngọt để không làm vị giác bị quá tải. Sản phẩm nên được dùng ngay, đặc biệt khi mua mang đi trong ngày nóng.</p><h2>Đánh giá tổng thể</h2><p>Điểm khác biệt của phiên bản này là hương sầu riêng rõ nhưng vẫn có nền bơ cân bằng. Đây là lựa chọn dành cho khách thích món béo thơm và muốn trải nghiệm một phiên bản mạnh hơn sản phẩm signature. Với người chuộng vị nhẹ, kem bơ truyền thống vẫn là điểm bắt đầu phù hợp hơn.</p>',
    seo_description = N'Kem bơ sầu riêng khác gì bản truyền thống? So sánh hương thơm, độ béo, kết cấu và cách thưởng thức.'
WHERE slug = N'kem-bo-sau-rieng-co-gi-khac-biet';

UPDATE dbo.posts
SET excerpt = N'Checklist khai trương ALOO theo từng giai đoạn: pháp lý, mặt bằng, thiết bị, nguyên liệu, nhân sự, POS, truyền thông, chạy thử và đánh giá sau ngày mở cửa.',
    content = N'<h2>Bốn tuần trước khai trương</h2><p>Giai đoạn đầu cần chốt phạm vi thi công, danh sách thiết bị, lịch giao hàng và người chịu trách nhiệm từng hạng mục. Hồ sơ pháp lý, thỏa thuận mặt bằng và các yêu cầu của ban quản lý khu vực phải được kiểm tra sớm để tránh ảnh hưởng ngày mở cửa.</p><ul><li>Xác nhận bản vẽ quầy, điện, nước và bảng hiệu.</li><li>Đặt thiết bị có thời gian giao hàng dài.</li><li>Lập ngân sách khai trương và khoản dự phòng.</li><li>Tuyển vị trí quản lý hoặc nhân sự nòng cốt.</li><li>Tạo tài khoản bản đồ, mạng xã hội và kênh giao hàng cần thiết.</li></ul><h2>Hai tuần trước khai trương</h2><p>Khi phần thi công chính gần hoàn tất, cửa hàng bắt đầu lắp đặt thiết bị và kiểm tra công suất. Hệ thống POS cần được cấu hình đầy đủ tên món, giá, topping, phương thức thanh toán và phân quyền nhân viên.</p><p>Nguyên liệu khô và vật tư đóng gói có thể nhập trước. Nguyên liệu tươi cần có lịch giao sát ngày chạy thử và phương án đổi trả nếu chất lượng không đạt.</p><h2>Đào tạo đội ngũ</h2><p>Nhân viên cần được học theo trình tự từ vệ sinh, nhận biết nguyên liệu, công thức, thao tác thiết bị đến giao tiếp với khách. Sau phần hướng dẫn, mỗi người phải trực tiếp thực hiện món và được đánh giá bằng cùng một tiêu chí.</p><p>Buổi mô phỏng giờ cao điểm giúp đội ngũ luyện cách gọi đơn, phối hợp vị trí và xử lý yêu cầu đặc biệt. Các lỗi phát hiện trong buổi chạy thử nên được ghi thành checklist thay vì chỉ nhắc miệng.</p><h2>Ba ngày trước khai trương</h2><ul><li>Tổng vệ sinh toàn bộ cửa hàng và kiểm tra côn trùng.</li><li>Đo nhiệt độ thiết bị lạnh, chạy thử liên tục.</li><li>Nhận nguyên liệu, dán nhãn ngày và sắp xếp kho.</li><li>Kiểm tra bảng giá, nội dung khuyến mãi và QR thanh toán.</li><li>Chạy thử đơn tại quầy, đơn mang đi và đơn giao hàng.</li><li>Chuẩn bị danh sách liên hệ kỹ thuật và nhà cung cấp.</li></ul><h2>Soft opening</h2><p>Một buổi mở cửa thử với lượng khách giới hạn giúp kiểm tra toàn bộ hành trình thực tế. Hãy đo thời gian chờ, ghi nhận món bị làm lại, câu hỏi khách thường hỏi và điểm nghẽn tại quầy. Không nên tập trung quá nhiều vào doanh số trong giai đoạn này.</p><h2>Ngày khai trương</h2><p>Phân công một người điều phối thay vì tất cả cùng tham gia làm món. Người này theo dõi hàng chờ, tình trạng nguyên liệu, phản hồi khách và sự cố kỹ thuật. Chương trình ưu đãi phải đơn giản để POS áp dụng nhanh và khách dễ hiểu.</p><blockquote>Một ngày khai trương tốt không phải là ngày không có sự cố, mà là ngày đội ngũ phát hiện và xử lý sự cố có tổ chức.</blockquote><h2>Sau khai trương</h2><p>Trong bảy ngày đầu, cửa hàng nên họp ngắn cuối mỗi ca. So sánh doanh số, hao hụt, thời gian phục vụ và phản hồi với kế hoạch ban đầu. Điều chỉnh lịch nhân sự và mức chuẩn bị nguyên liệu theo dữ liệu thật, nhưng không thay đổi công thức tùy tiện.</p><p>Checklist khai trương chỉ hoàn tất khi các vấn đề sau mở cửa đã có người chịu trách nhiệm và thời hạn xử lý. Đây là bước chuyển từ một dự án setup sang một cửa hàng vận hành ổn định.</p>',
    seo_description = N'Checklist đầy đủ để chuẩn bị và vận hành ngày khai trương cửa hàng ALOO từ bốn tuần trước đến giai đoạn sau mở cửa.'
WHERE slug = N'checklist-khai-truong-cua-hang-aloo';

UPDATE dbo.posts
SET excerpt = N'Đội R&D ALOO đang thử nghiệm phiên bản matcha có hậu vị thanh, độ ngọt vừa và khả năng kết hợp với nền kem bơ mà vẫn đảm bảo thao tác ổn định tại cửa hàng.',
    content = N'<h2>Vì sao ALOO thử nghiệm matcha?</h2><p>Matcha có hương thực vật, vị chát nhẹ và màu sắc dễ nhận biết. Đây là đối trọng thú vị với nền bơ béo mịn. Mục tiêu của thử nghiệm không phải thêm hương vị theo xu hướng, mà là tìm một công thức có cá tính riêng và phù hợp với nhóm khách thích món ít ngọt.</p><h2>Tiêu chí của phiên bản thử nghiệm</h2><ul><li>Hương matcha rõ nhưng không có vị bột.</li><li>Độ chát đủ cân bằng phần kem béo.</li><li>Màu thành phẩm ổn định trong thời gian phục vụ.</li><li>Công thức có thể định lượng và đào tạo dễ dàng.</li><li>Thời gian thao tác không làm chậm quầy giờ cao điểm.</li></ul><h2>Cân bằng matcha và bơ</h2><p>Nếu lượng matcha quá thấp, hương vị sẽ mất khi kết hợp với bơ. Nếu quá cao, món có thể đắng và khô ở hậu vị. Đội ngũ thử nhiều tỷ lệ để tìm điểm mà khách nhận ra cả hai thành phần trong cùng một muỗng.</p><p>Độ ngọt cũng được điều chỉnh theo từng phiên bản. Một lượng ngọt vừa đủ làm hương matcha tròn hơn, nhưng không nên biến món thành một lựa chọn nặng vị.</p><h2>Thử nghiệm kết cấu và topping</h2><p>Matcha có dạng bột nên quy trình hòa tan ảnh hưởng trực tiếp đến độ mịn. Công thức cần tránh vón và giữ màu đồng đều. Topping được chọn theo hướng nhẹ, giòn và không có mùi quá mạnh để phần matcha vẫn là điểm chính.</p><h2>Đánh giá tại quầy</h2><p>Mỗi công thức được kiểm tra không chỉ bằng buổi nếm nội bộ mà còn qua khả năng thao tác thực tế. Nhân viên thực hiện liên tiếp nhiều đơn để đo thời gian, mức bám dụng cụ và độ ổn định giữa các ly. Một công thức ngon nhưng khó vận hành sẽ cần tiếp tục điều chỉnh.</p><h2>Phản hồi cần thu thập</h2><p>Nhóm thử nghiệm quan tâm đến mức độ nhận biết matcha, cảm nhận về độ ngọt, độ béo, khẩu phần và ý định gọi lại. Phản hồi được ghi theo câu hỏi cụ thể để tránh kết luận chỉ từ nhận xét chung như ngon hoặc chưa ngon.</p><h2>Bước tiếp theo</h2><p>Sản phẩm hiện vẫn ở giai đoạn thử nghiệm nên công thức, tên gọi và thời gian ra mắt có thể thay đổi. Nếu đạt tiêu chí về hương vị, chất lượng và vận hành, món sẽ được thử ở phạm vi nhỏ trước khi quyết định triển khai rộng hơn.</p><p>Quá trình R&D giúp ALOO mở rộng menu có chọn lọc: mỗi sản phẩm mới cần mang lại trải nghiệm khác biệt nhưng vẫn phù hợp với nền tảng nguyên liệu và khả năng phục vụ của hệ thống.</p>',
    seo_description = N'Bên trong quá trình ALOO thử nghiệm vị matcha mới, từ cân bằng hương vị đến kiểm tra khả năng vận hành tại cửa hàng.'
WHERE slug = N'aloo-thu-nghiem-vi-matcha-moi';
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

PRINT N'ALOO sample data inserted. LOCAL ONLY login password for seeded users: 123456 — change before any shared/staging use.';
GO


