# TỒN ĐỌNG VÀ RỦI RO KỸ THUẬT

Rà soát gần nhất: 29/07/2026.

## Đã khắc phục trong ngày nghiệm thu

- API `GET /api/home-sections?activeOnly=true` từng trả 400 do `@Lob` ánh xạ cột PostgreSQL `text` thành Large Object OID. Đã gỡ ánh xạ sai, thêm kiểm thử hồi quy và xác minh API trả 200.
- Ảnh `/uploads/...` từng trả 404 vì backend chạy trong `backend/` nhưng dữ liệu ảnh nằm ở `uploads/` cấp dự án. Local đã cấu hình `UPLOAD_DIR=../uploads`; trình duyệt không còn ảnh tải lỗi.

## Tồn đọng không chặn nghiệm thu local

- Bundle JavaScript production 1,488.91 kB (gzip 432.56 kB), vượt ngưỡng cảnh báo 500 kB. Nên lazy-load route CMS/editor và tách vendor chunk.
- Spring Data Redis quét các JPA repository tạo nhiều cảnh báo log; không làm test thất bại.
- Flyway hiện cảnh báo PostgreSQL 17 mới hơn phiên bản được thư viện xác nhận chính thức. Migration vẫn validate và chạy thành công; nên nâng Flyway/Spring Boot sau kiểm thử tương thích.
- Working tree còn thay đổi chưa commit; snapshot Git cuối cùng cần được review, commit và push trước khi đóng gói bàn giao chính thức.
- SQL Server cũ chỉ nên giữ làm nguồn rollback/đối chiếu cho đến khi có backup PostgreSQL và thử phục hồi thành công.

## Cần xác minh trên production

- HTTPS, reverse proxy, CORS, WebSocket/live chat và timeout.
- Google OAuth redirect URI, whitelist email admin, SMTP gửi OTP/thông báo.
- Redis rate limiting nếu bật.
- `UPLOAD_DIR` trên volume bền vững, quyền ghi, backup và phục vụ URL.
- Backup/restore PostgreSQL và quy trình rollback.
- Đa trình duyệt, thiết bị di động thật và domain production.
- Quyền sử dụng media, đặc biệt các ảnh có hậu tố `-ai.webp`.

Không mục nào trong phần “cần xác minh trên production” được coi là đã đạt nếu chưa có log, ảnh chụp hoặc biên bản riêng trên môi trường đích.

