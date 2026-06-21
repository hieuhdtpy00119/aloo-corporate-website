USE ALOO_Franchise_CMS;
GO

DELETE FROM dbo.franchise_contents
WHERE section_key IN (N'benefits', N'conditions', N'costs', N'process');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.franchise_contents WHERE section_key = N'hero')
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
