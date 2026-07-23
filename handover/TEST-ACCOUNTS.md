# TÀI KHOẢN TEST LOCAL/DEMO

Các tài khoản dưới đây được tạo bởi `database/aloo_franchise_cms_sample_data.sql` và đều dùng mật khẩu **123456**.

| Vai trò | Email | Mật khẩu | Phạm vi |
|---|---|---|---|
| Admin đầy đủ | `admin@aloo.vn` | `123456` | FULL |
| Admin nội dung | `content@aloo.vn` | `123456` | CONTENT |
| Khách hàng | `user@aloo.vn` | `123456` | USER |
| Khách hàng phụ | `khachhang@aloo.vn` | `123456` | USER |

Các tài khoản này chỉ dành cho máy local hoặc môi trường demo tách biệt. Trước khi đưa dữ liệu lên môi trường có internet:

1. Đổi toàn bộ mật khẩu.
2. Không dùng `reset_admin_password.sql` trong gói production.
3. Kiểm tra `ADMIN_EMAIL_WHITELIST`.
4. Dùng JWT secret ngẫu nhiên riêng cho từng môi trường.

