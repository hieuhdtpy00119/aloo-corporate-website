# BIÊN BẢN NGHIỆM THU VÀ BÀN GIAO WEBSITE

**Dự án:** ALOO Corporate Website & Franchise CMS  
**Ngày nghiệm thu:** 29/07/2026  
**Môi trường nghiệm thu:** Local — Frontend `localhost:5173`, Backend `localhost:8080`, PostgreSQL 17.10  
**Người bàn giao:** Huỳnh Đoàn Trung Hiếu  
**Đại diện bên nhận:** ______________________________

## 1. Mục đích

Biên bản xác nhận tình trạng kỹ thuật, dữ liệu, tài liệu và phạm vi bàn giao của website doanh nghiệp ALOO kết hợp hệ thống quản trị nội dung, CRM và live chat tại thời điểm nghiệm thu. Credential thật không được ghi trong biên bản và phải chuyển qua kênh bảo mật riêng.

## 2. Phạm vi bàn giao

- Website công khai: trang chủ, giới thiệu, sản phẩm, cửa hàng, nhượng quyền, blog, liên hệ, tư vấn và tài khoản khách hàng.
- CMS quản trị: nội dung trang chủ, sản phẩm/menu, cửa hàng, bài viết, nhượng quyền, phản hồi, đánh giá, lead, liên hệ, live chat, tài khoản và audit log.
- Backend Spring Boot REST API, JWT/RBAC, WebSocket/STOMP, upload ảnh và tích hợp tùy chọn OAuth/SMTP/Redis.
- PostgreSQL, Flyway migrations, dữ liệu CMS hiện có và tài liệu chuyển đổi từ SQL Server.
- Mã nguồn frontend/backend, kiểm thử tự động, Postman collection và tài liệu vận hành.

## 3. Hiện trạng dữ liệu

| Dữ liệu | Số lượng xác minh |
|---|---:|
| Sản phẩm | 69 |
| Bài blog đã xuất bản | 20 |
| Cửa hàng | 5 |
| Tài khoản | 6 |
| Nội dung nhượng quyền | 24 |
| Home section | 3 |
| Flyway migration thành công | 8 |

Kho ảnh local có 110 tệp tại thư mục `uploads/`. Riêng trang chủ đã được kiểm tra bằng trình duyệt với 16 ảnh và không có ảnh tải lỗi.

## 4. Kết quả nghiệm thu

| Hạng mục | Kết quả | Bằng chứng |
|---|---|---|
| Frontend unit test | Đạt — 87/87 | Vitest, 27 test file |
| Frontend production build | Đạt | Vite 8.0.12, 1.981 module |
| Backend test | Đạt — 40/40 | Maven, 13 suite |
| PostgreSQL/Flyway | Đạt local | PostgreSQL 17.10, 8 migration |
| API nội dung chính | Đạt | `home-sections`, `products`, `posts`, `stores` trả thành công |
| Trang chủ và ảnh | Đạt | 16 ảnh, 0 ảnh tải lỗi, không có lỗi console liên quan |
| Blog | Đạt local | 20 bài published và nội dung mở rộng |

Trong ngày nghiệm thu đã sửa lỗi API `home-sections` trả 400 do ánh xạ `@Lob` không tương thích PostgreSQL, đồng thời sửa cấu hình thư mục ảnh. Sau khi khởi động lại, API và ảnh đều trả HTTP 200.

## 5. Snapshot mã nguồn

- Repository: `https://github.com/hieuhdtpy00119/aloo-corporate-website`
- Branch: `agent/aloo-cms-handover-update`
- Commit nền tại thời điểm lập biên bản: `adf37d4`
- Trạng thái: working tree còn thay đổi chưa commit; cần review và tạo commit bàn giao cuối trước khi lưu trữ/phát hành.

## 6. Hạng mục chuyển giao

- Mã nguồn trong `frontend/` và `backend/`.
- Database PostgreSQL `aloo_cms`, Flyway migrations và dữ liệu CMS hiện có.
- Kho ảnh `uploads/` cùng tài nguyên tĩnh trong `frontend/public/`.
- Bộ hồ sơ trong `handover/`, gồm DOCX/PDF ký nghiệm thu, hướng dẫn cài đặt, checklist, API collection, bằng chứng kiểm thử và danh sách tồn đọng.
- Thông tin dịch vụ production và credential: bàn giao riêng qua password manager/kênh bí mật.

## 7. Điều kiện vận hành

- Khi chạy backend từ thư mục `backend/`, local cần `UPLOAD_DIR=../uploads`.
- Production phải dùng volume ảnh bền vững, backup định kỳ và thử phục hồi.
- Trước go-live cần commit/push snapshot cuối, đổi mật khẩu demo, cấu hình domain/HTTPS/reverse proxy và xác minh OAuth, SMTP, Redis, WebSocket.
- Bundle JavaScript còn cảnh báo kích thước lớn; không chặn chức năng nhưng nên tối ưu sau nghiệm thu.

## 8. Kết luận

Hai bên xác nhận hệ thống **đạt nghiệm thu kỹ thuật trên môi trường local ngày 29/07/2026** đối với phạm vi và dữ liệu nêu trong biên bản. Các hạng mục production chưa có bằng chứng trên môi trường đích được ghi nhận là công việc trước go-live, không được hiểu là đã nghiệm thu.

Lựa chọn xác nhận:

- [ ] Đồng ý nghiệm thu và nhận bàn giao theo hiện trạng nêu trên.
- [ ] Đồng ý có điều kiện, với nội dung bổ sung: ____________________________________________
- [ ] Chưa đồng ý, lý do: _________________________________________________________________

## 9. Chữ ký

| BÊN BÀN GIAO | BÊN NHẬN BÀN GIAO |
|---|---|
| Họ tên: Huỳnh Đoàn Trung Hiếu | Họ tên: ______________________________ |
| Chức vụ: __________________________ | Chức vụ: __________________________ |
| Ký, ghi rõ họ tên | Ký, ghi rõ họ tên |
| Ngày: ____/____/2026 | Ngày: ____/____/2026 |

