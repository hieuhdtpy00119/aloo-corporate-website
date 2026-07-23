# KNOWN ISSUES & TECHNICAL DEBT

Ngày rà soát: 22/07/2026.

## Đã xác minh

- Frontend unit test 84/84 pass; backend test 39/39 pass; frontend build thành công.
- Bundle JS production khoảng 1.472 MB (gzip 427 kB), Vite cảnh báo chunk vượt 500 kB. Nên lazy-load route/admin editor và tách vendor chunks.
- Frontend chủ động hủy service worker và xóa cache do ứng dụng PWA cũ để tránh phục vụ giao diện lỗi thời. Đây là cơ chế dọn cache, không phải hỗ trợ offline/PWA; cần smoke test trên trình duyệt từng từng truy cập origin cũ.
- E2E thật chưa được chạy trong lượt bàn giao này vì cần SQL Server demo và hai server cùng hoạt động. Các script Playwright đã có trong `frontend/tests/e2e`.
- Bộ test backend in nhiều cảnh báo do Spring Data Redis quét các JPA repository; không làm test fail nhưng nên tách rõ repository scanning nếu muốn log sạch.
- H2 test cấu hình dialect tường minh và phát cảnh báo deprecated; có thể bỏ `hibernate.dialect` trong test profile.
- Working tree đang có nhiều tệp modified/untracked. Chưa thể xác nhận “toàn bộ code mới nhất đã commit và push” cho tới khi chủ dự án review phạm vi và commit.

## Cần xác minh trên môi trường đích

- Migration Flyway trên bản SQL Server/backup production thật.
- Google OAuth redirect URI và whitelist email production.
- WebSocket/live chat qua reverse proxy, HTTPS và timeout thực tế.
- Upload ảnh: quyền ghi, giới hạn dung lượng, backup và phục vụ URL trên production.
- SMTP gửi OTP/thông báo với mailbox production.
- CORS, rate limiting Redis, TLS và secret rotation.
- Responsive/đa trình duyệt bằng Chrome, Edge, Safari/mobile thật.
- Quyền sử dụng ba ảnh hero có tên `*-ai.webp` và quy trình lưu prompt/nguồn tạo ảnh.

## Không được coi là lỗi đã sửa

Tài liệu này không tuyên bố các mục “cần xác minh” đã pass. Chỉ đánh dấu hoàn tất sau khi có ảnh chụp/log/video chứng minh trên môi trường bàn giao.
