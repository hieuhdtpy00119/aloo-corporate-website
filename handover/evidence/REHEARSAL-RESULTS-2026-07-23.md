# KẾT QUẢ REHEARSAL VIDEO BÀN GIAO

Thời điểm kiểm tra: 23/07/2026, múi giờ Asia/Saigon.

## Môi trường

| Hạng mục | Kết quả | Ghi chú |
|---|---|---|
| SQL Server local | PASS | Cổng 1433; database `ALOO_Franchise_CMS` |
| Flyway | PASS | Schema ở version `20260719`; không có migration chờ |
| Backend | PASS | `http://localhost:8080`; profile local |
| Frontend | PASS | `http://localhost:5173` |
| Admin demo | PASS sau khi khôi phục dữ liệu demo | `admin@aloo.vn` trả role `ADMIN`, profile `FULL` |
| User demo | PASS | `user@aloo.vn` trả role `USER` |

Tài khoản Admin trong database demo ban đầu bị lệch thành role `USER`. Rehearsal chỉ khôi phục đúng bản ghi local `admin@aloo.vn` về `ADMIN/FULL`; không đổi mật khẩu và không chạm môi trường production.

## Luồng đã xác minh

| Luồng | Kết quả | Bằng chứng |
|---|---|---|
| Trang chủ, sản phẩm, cửa hàng, blog | PASS | Các route tải dữ liệu và hiển thị nội dung từ API |
| Đăng nhập User | PASS | Điều hướng đến `/account`, hiển thị hồ sơ demo |
| Cập nhật profile | PASS qua API thật | Gửi lại dữ liệu hiện có, không đổi thông tin quan trọng |
| Lead User → Admin | PASS | Lead `Demo Single Take 20260723-124047`, ID 14, hiện trong Dashboard/CRM |
| Cập nhật trạng thái lead | PASS | `CONTACTED` |
| Contact User → Admin | PASS | Contact ID 6 hiện trong bảng Tin nhắn liên hệ, trạng thái `READ` |
| Chat session User → Admin | PASS một phần | Session ID 3 hiện trong Live Chat; chưa gửi message WebSocket trong lượt này |
| Review User → Admin | PASS | Review ID 3 hiện trong Admin, trạng thái `APPROVED` |
| Admin Dashboard | PASS | Đăng nhập `ADMIN/FULL`, sidebar đủ Content/Stores/CRM/System |
| Tìm kiếm/lọc/phân trang CMS | PASS kiểm tra giao diện | Products, Menu poster, CRM, Accounts có control tương ứng |
| Product/Menu poster CRUD | CHƯA XÁC NHẬN TOÀN BỘ | Form và dữ liệu hiển thị; test CRUD tự động bị lệch selector form mới |

## Kiểm thử

| Bộ kiểm tra | Kết quả |
|---|---|
| Frontend Vitest | PASS — 27 files, 84/84 tests |
| Frontend production build | PASS |
| Backend Maven | PASS — 39/39 tests |
| Playwright desktop | PARTIAL — 5/8 pass |

Ba Playwright test chưa pass:

1. Product CRUD vẫn tìm trường `Giá sản phẩm`, trong khi form hiện tại đã thay đổi.
2. Lead đã tạo và hiển thị trong Admin, nhưng locator tên lead khớp cả table row và card nên bị strict-mode violation.
3. User profile test dùng mock/selector cũ và không tìm được nút cập nhật, trong khi nút `Cập nhật thông tin` có trên UI thật.

Không đánh dấu E2E pass toàn bộ cho đến khi cập nhật ba test và chạy lại xanh.

## Cảnh báo khi quay

- Dùng `localhost:5173`, không dùng `127.0.0.1:5173` nếu Vite chỉ bind IPv6 loopback.
- Không thao tác đổi mật khẩu, xóa dữ liệu hoặc thay role.
- Chờ khoảng một giây sau khi mở bảng CRM để dữ liệu API render đầy đủ.
- Live chat mới xác minh session; nên thử gửi message trước lúc bấm quay.
- Bundle build khoảng 1.472 MB, gzip 427 kB và còn cảnh báo chunk trên 500 kB.
