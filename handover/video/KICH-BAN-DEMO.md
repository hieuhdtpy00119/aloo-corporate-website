# KỊCH BẢN VIDEO DEMO SINGLE-TAKE

Thời lượng gợi ý: 12–18 phút. Quay liên tục, bật mic, không cắt ghép.

## Chuẩn bị trước khi bấm quay

- Import schema và sample data; khởi động backend `:8080` và frontend `:5173`.
- Mở DevTools Network để có thể chỉ ra request API.
- Chuẩn bị 2 cửa sổ/tab: User và Admin.
- Admin: `admin@aloo.vn / 123456`; User: `user@aloo.vn / 123456`.
- Không để credential production, token, email cá nhân hoặc cửa sổ nhạy cảm xuất hiện.

## Flow quay

1. **Mở đầu (30 giây):** giới thiệu project, stack và commit/branch đang demo.
2. **Public site (3–4 phút):** trang chủ và gallery khoảnh khắc thương hiệu → sản phẩm/hero mới → cửa hàng/chi tiết có gallery và menu poster → bài blog có mục lục, thời gian đọc, chia sẻ/in → nhượng quyền. Nêu dữ liệu được lấy qua API.
3. **Tạo lead (1 phút):** vào `/consultation`, gửi đăng ký với tên có dấu thời gian; nói rõ request `POST /api/franchise-registrations`.
4. **Liên hệ và live chat (1–2 phút):** gửi form liên hệ; mở chat, tạo session và gửi tin nhắn.
5. **User account (2 phút):** đăng nhập User, xem/cập nhật profile; mở một sản phẩm và gửi đánh giá nếu dữ liệu hỗ trợ.
6. **Admin (5–7 phút):** tab khác đăng nhập Admin; mở Dashboard; vào CRM Leads tìm đúng lead vừa tạo, cập nhật trạng thái; kiểm tra Contact Messages và Live Chat; duyệt Product Review nếu có.
7. **CMS content (3–4 phút):** minh họa CRUD sản phẩm; trong module Sản phẩm mở tab Menu poster, thử tìm kiếm/lọc và tạo/sửa poster có upload ảnh; cho xem Home Sections/Brand Timeline/Stores và phân trang; nói rõ scope phân quyền.
8. **System (1–2 phút):** Accounts, Audit Logs và Profile; không đổi/xóa tài khoản chính trong video.
9. **Kết thúc (1 phút):** trình bày known issues, test status, vị trí schema/sample data/Postman và cách chạy dự án.

## Câu thuyết minh mẫu cho luồng dữ liệu

“Người dùng thao tác trên Vue tại trình duyệt. Axios gửi request tới Spring Boot REST API. Security filter xác thực JWT và scope; controller chuyển dữ liệu cho service, repository dùng JPA ghi/đọc SQL Server. Kết quả trả JSON cho frontend cập nhật giao diện. Riêng live chat dùng STOMP/WebSocket để đẩy tin nhắn gần thời gian thực.”

## Tiêu chí video đạt

- Màn hình, URL và thao tác đọc được; giọng nói rõ.
- Thấy dữ liệu User vừa tạo xuất hiện ở Admin.
- Có ít nhất một request API được giải thích.
- Nếu gặp lỗi, nói thẳng lỗi và liên kết nó với `KNOWN-ISSUES.md`.
- Video không chứa secret production.
