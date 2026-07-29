# CHECKLIST NGHIỆM THU VÀ BÀN GIAO

Ngày nghiệm thu local: **29/07/2026**.

## Đã hoàn thành và xác minh

- [x] PostgreSQL 17.10 hoạt động; Flyway xác nhận 8 migration thành công.
- [x] Dữ liệu hiện có: 69 sản phẩm, 20 bài blog đã xuất bản, 5 cửa hàng, 6 tài khoản, 24 nội dung nhượng quyền, 3 home section.
- [x] Frontend unit test: 27 file, 87/87 test đạt.
- [x] Frontend production build: đạt với Vite 8.0.12.
- [x] Backend Maven test: 13 suite, 40/40 test đạt.
- [x] API `home-sections`, `products`, `posts`, `stores` trả kết quả thành công.
- [x] Đã sửa ánh xạ PostgreSQL `HomeSection.description`; API `home-sections` trả 200.
- [x] Đã cấu hình đúng kho ảnh local; trình duyệt xác nhận 16 ảnh trang chủ, không có ảnh tải lỗi và không có lỗi console liên quan.
- [x] Có DOCX/PDF biên bản nghiệm thu và bàn giao ngày 29/07/2026.
- [x] Có hướng dẫn cài đặt PostgreSQL, biến môi trường, API collection và tài liệu vận hành.

## Cần hoàn tất trước go-live/production

- [ ] Review `git diff`, commit có chủ đích và push snapshot nghiệm thu.
- [ ] Ghi URL repository, branch và commit SHA cuối cùng vào biên bản sau khi push.
- [ ] Bàn giao credential production qua password manager/kênh bí mật riêng.
- [ ] Đổi hoặc vô hiệu hóa mật khẩu demo.
- [ ] Backup PostgreSQL và volume ảnh; thực hiện thử phục hồi.
- [ ] Xác minh HTTPS, reverse proxy, CORS, WebSocket, Google OAuth, SMTP và Redis trên môi trường đích.
- [ ] Smoke test Chrome/Edge/mobile thật trên domain production.
- [ ] Xác nhận quyền sử dụng media và metadata của các ảnh AI.
- [ ] Quay video demo single-take nếu bên nhận yêu cầu.

Repo URL: `https://github.com/hieuhdtpy00119/aloo-corporate-website`  
Branch lúc nghiệm thu: `agent/aloo-cms-handover-update`  
Commit nền lúc nghiệm thu: `adf37d4`  
Trạng thái snapshot: working tree còn thay đổi chưa commit  
Người bàn giao: Huỳnh Đoàn Trung Hiếu  
Đại diện bên nhận: ______________________________  
Ngày ký: ____/____/2026

