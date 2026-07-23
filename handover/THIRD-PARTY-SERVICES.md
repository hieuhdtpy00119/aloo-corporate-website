# DỊCH VỤ BÊN THỨ BA

Không có credential thật nào được chép vào bộ bàn giao. Người sở hữu dự án cần hoàn tất bảng sau trước khi gửi:

| Dịch vụ | Hiện diện trong code | Cách bàn giao an toàn | Trạng thái |
|---|---|---|---|
| Google OAuth 2.0 | Có | Invite tài khoản quản trị Google Cloud; cấu hình `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, redirect URI | Chưa xác nhận credential production |
| SMTP email | Có, tùy chọn | Bàn giao mailbox/app password qua password manager; cấu hình nhóm `MAIL_*` | Chưa xác nhận |
| Redis | Có, tùy chọn | Bàn giao endpoint/password qua secret manager; local dùng memory | Chưa xác nhận production |
| SQL Server | Có | Tạo riêng runtime user và migration user; không gửi mật khẩu trong file nén | Chưa xác nhận production |
| Lưu ảnh | Local filesystem qua `UPLOAD_DIR` | Bàn giao volume/quyền truy cập và chính sách backup | Chưa xác nhận production |
| Zalo chat link | Có ở frontend | Xác nhận số/URL trong `VITE_ZALO_CHAT_URL` | Đang có URL mẫu trong env example |
| Media Google Drive của khách hàng | Có | Danh sách nguồn nằm tại `frontend/public/media/drive/SOURCES.md`; xác nhận quyền sử dụng trước production | Có metadata nguồn Drive |
| Ảnh hero AI sản phẩm | Có | Lưu prompt/công cụ tạo và xác nhận quyền thương mại cho ba tệp `frontend/public/media/products/*-ai.webp` | Chưa thấy metadata nguồn trong repo |

Không thấy SDK Firebase, AWS, Cloudinary, VNPay hoặc Momo trong dependency hiện tại.
