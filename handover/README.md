# BỘ BÀN GIAO ALOO CORPORATE WEBSITE & FRANCHISE CMS

Ngày lập/cập nhật: 22/07/2026, sau thay đổi giao diện và dữ liệu lúc 19:30  
Phạm vi: trạng thái mã nguồn hiện có trong working tree tại thời điểm lập tài liệu.

## Thành phần

| Hạng mục | Tệp/thư mục |
|---|---|
| Tài liệu kiến trúc, tính năng, đóng góp | `output/ALOO-Tai-lieu-ban-giao.pdf` |
| Bản nguồn dễ chỉnh sửa | `TAI-LIEU-BAN-GIAO.md` |
| Hướng dẫn cài đặt và chạy | `INSTALLATION.md`, `.env.example`, `frontend.env.example` |
| Database mới và dữ liệu demo | `database/` |
| API collection | `api/ALOO-CMS.postman_collection.json` |
| Kịch bản quay video single-take | `video/KICH-BAN-DEMO.md` |
| Tài khoản test | `TEST-ACCOUNTS.md` |
| Dịch vụ bên thứ ba | `THIRD-PARTY-SERVICES.md` |
| Nguồn media và metadata còn thiếu | `media/` |
| Lỗi tồn đọng/technical debt | `KNOWN-ISSUES.md` |
| Checklist nghiệm thu | `CHECKLIST.md` |

## Kết quả kiểm tra ngày 22/07/2026

- Frontend unit test: **27 test files, 84/84 test pass**.
- Frontend production build: **thành công**.
- Backend test: **12 suites, 39/39 test pass**.
- Cảnh báo build: bundle JavaScript sau minify khoảng **1.472 MB**, vượt ngưỡng cảnh báo 500 kB.
- Bản cập nhật đã ghi nhận: CRUD menu poster trong tab Sản phẩm, tìm kiếm/phân trang rộng hơn trong CMS, gallery media thương hiệu, menu poster tại chi tiết cửa hàng, thiết kế lại bài blog và cơ chế dọn service worker/cache cũ.
- Chưa chạy E2E thật với SQL Server và hai tiến trình frontend/backend trong lượt kiểm tra này.
- Working tree có nhiều thay đổi chưa commit; cần review và commit có chủ đích trước bàn giao Git.

## Cách dùng nhanh

1. Đọc `INSTALLATION.md` và cấu hình biến môi trường.
2. Import lần lượt `database/aloo_franchise_cms.sql`, sau đó `database/aloo_franchise_cms_sample_data.sql`.
3. Import Postman collection và chạy request `Auth / Login`, collection sẽ tự lưu JWT.
4. Làm theo `video/KICH-BAN-DEMO.md` để quay video.
5. Hoàn tất các ô còn trống trong `THIRD-PARTY-SERVICES.md` và `CHECKLIST.md` trước khi gửi.

> Lưu ý bảo mật: dữ liệu mẫu dùng mật khẩu công khai `123456`, chỉ dành cho local/demo. Không dùng database hoặc tài khoản mẫu ở production.
