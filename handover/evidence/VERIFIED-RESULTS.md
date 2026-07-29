# KẾT QUẢ ĐÃ XÁC MINH

Thời điểm chạy: 29/07/2026 (Asia/Saigon).

| Kiểm tra | Kết quả |
|---|---|
| `cd frontend; npm test -- --run` | Đạt — 27 test file, 87/87 test |
| `cd frontend; npm run build` | Đạt — Vite 8.0.12, 1.981 module |
| `cd backend; mvn -q test` | Đạt — 13 suite, 40/40 test, 0 lỗi, 0 bỏ qua |
| PostgreSQL/Flyway | PostgreSQL 17.10; 8 migration thành công |
| Dữ liệu CMS | 69 sản phẩm; 20/20 blog published; 5 cửa hàng; 6 tài khoản; 24 nội dung nhượng quyền; 3 home section |
| API `home-sections` | HTTP 200, trả đủ 3 section |
| Ảnh trang chủ | 16 ảnh được trình duyệt kiểm tra; 0 ảnh hoàn tất nhưng có kích thước 0; không có lỗi console liên quan |

Build tạo bundle chính 1,488.91 kB (gzip 432.56 kB) và cảnh báo chunk vượt 500 kB. Đây là technical debt về hiệu năng, không làm build thất bại.

Kết quả trên áp dụng cho môi trường local tại ngày nghiệm thu. Chưa thay thế kiểm thử production, đa trình duyệt hoặc kiểm thử sau reverse proxy.

