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

## Checklist quay 10–15 phút

### Dữ liệu nhập trong video

Dùng cùng một hậu tố thời gian để tìm lại dữ liệu nhanh. Ví dụ khi quay lúc 14:30:

| Trường | Giá trị gợi ý |
|---|---|
| Họ tên lead | `Video ALOO 1430` |
| Số điện thoại lead | `0901234567` |
| Email lead | `video.1430@example.com` |
| Tỉnh/thành | `TP.HCM` |
| Ngân sách | `300000000` |
| Ghi chú | `Dữ liệu tạo trong video bàn giao single-take` |
| Chủ đề liên hệ | `Demo bàn giao website` |
| Nội dung liên hệ | `Tôi cần tư vấn mô hình ALOO tại TP.HCM` |
| Nội dung đánh giá | `Sản phẩm ngon, giao diện rõ ràng và dễ sử dụng.` |

Không dùng email cá nhân, số điện thoại thật hoặc credential production.

### Trước khi bấm quay

- [ ] SQL Server đang chạy; database `ALOO_Franchise_CMS` đã có schema và sample data.
- [ ] Backend trả dữ liệu tại `http://localhost:8080/api/products`.
- [ ] Frontend mở được tại `http://localhost:5173`.
- [ ] `admin@aloo.vn / 123456` đăng nhập với vai trò `ADMIN`, scope `FULL`.
- [ ] `user@aloo.vn / 123456` đăng nhập với vai trò `USER`.
- [ ] Tắt thông báo Windows, email, ứng dụng chat và tab có dữ liệu riêng tư.
- [ ] Mở sẵn hai tab: Public/User và Admin; chưa đăng nhập Admin trước phần User.
- [ ] Phóng trình duyệt 100%, kiểm tra mic và vùng quay.
- [ ] Ghi lại branch và commit SHA sẽ đọc ở phần mở đầu.

### Timeline và lời thoại

#### 00:00–00:45 — Mở đầu

Thao tác:

- Mở trang chủ.
- Cho thấy URL local và giao diện ALOO.

Lời thoại:

> Đây là website doanh nghiệp và hệ thống CMS/CRM của ALOO. Frontend sử dụng Vue 3 và Vite, backend sử dụng Spring Boot, dữ liệu lưu trên SQL Server. Video này được quay liên tục, không cắt ghép. Phiên bản đang demo là branch [đọc branch] tại commit [đọc SHA].

#### 00:45–03:00 — Public site

Thao tác:

1. Trang chủ: hero, sản phẩm nổi bật, câu chuyện và gallery khoảnh khắc.
2. `/products`: chuyển danh mục và mở một sản phẩm.
3. `/locations`: tìm một cửa hàng, mở trang chi tiết và chỉ gallery/menu.
4. `/blog`: mở bài nổi bật, chỉ mục lục và thời gian đọc.
5. `/franchise`: cuộn qua quy trình và chi phí.

Lời thoại:

> Nội dung public không được viết cứng toàn bộ trong giao diện. Vue gọi REST API để lấy sản phẩm, cửa hàng, bài viết và nội dung CMS. Khi người dùng thao tác, Axios gửi request đến Spring Boot; backend xử lý qua controller, service và JPA repository rồi đọc dữ liệu SQL Server.

#### 03:00–04:15 — Tạo lead nhượng quyền

Thao tác:

1. Mở `/consultation`.
2. Điền bộ dữ liệu có hậu tố thời gian.
3. Gửi form và chờ thông báo thành công.

Lời thoại:

> Form này tạo một lead tư vấn mới qua `POST /api/franchise-registrations`. Tôi dùng tên có dấu thời gian để lát nữa tìm chính xác bản ghi này trong CMS.

#### 04:15–05:15 — Liên hệ và live chat

Thao tác:

1. Mở `/contact`, gửi nội dung liên hệ dùng cùng hậu tố.
2. Mở chat ALOO, tạo phiên và gửi một câu hỏi ngắn.

Lời thoại:

> Tin nhắn liên hệ được lưu qua REST API. Live chat tạo một session riêng và dùng STOMP/WebSocket để trao đổi gần thời gian thực. Trong phần Admin tôi sẽ kiểm tra lại session và nội dung vừa tạo.

Nếu WebSocket không kết nối trong 10 giây, nói rõ:

> Phiên chat đã được tạo nhưng kết nối WebSocket tại môi trường quay chưa ổn định. Nội dung này được ghi trong phần kiểm tra môi trường, tôi chuyển sang chứng minh session ở Admin.

#### 05:15–06:30 — Tài khoản User

Thao tác:

1. Đăng nhập `user@aloo.vn / 123456`.
2. Mở `/account`.
3. Chỉ thông tin hồ sơ và nút cập nhật; có thể cập nhật lại chính số điện thoại demo.
4. Mở một sản phẩm và gửi đánh giá 5 sao nếu sản phẩm chưa có review của User.

Lời thoại:

> Đây là tài khoản khách hàng trong database demo. Token JWT xác định role USER và bảo vệ route tài khoản. Người dùng có thể cập nhật hồ sơ và gửi đánh giá; đánh giá mới sẽ đi vào hàng chờ quản trị trước khi hiển thị.

Không đổi mật khẩu trong video.

#### 06:30–07:15 — Chuyển sang Admin

Thao tác:

1. Đăng xuất User.
2. Chuyển sang tab Admin.
3. Đăng nhập `admin@aloo.vn / 123456`.
4. Mở Dashboard.

Lời thoại:

> Tôi chuyển sang tài khoản Admin FULL. Sidebar được hiển thị theo scope; tài khoản FULL có quyền Content, Stores, CRM và System. Dashboard tổng hợp lead, bài viết, sản phẩm và cửa hàng từ cùng database vừa dùng ở phía User.

#### 07:15–09:15 — Chứng minh dữ liệu User → Admin

Thao tác:

1. Mở **Lead tư vấn**, tìm tên có hậu tố thời gian.
2. Mở chi tiết và đổi trạng thái từ `Mới` sang `Đã liên hệ`.
3. Mở **Tin nhắn liên hệ**, tìm cùng tên/chủ đề.
4. Mở **Chat trực tuyến**, chọn session vừa tạo.
5. Mở **Đánh giá sản phẩm**, tìm nội dung review và duyệt nếu đang chờ.

Lời thoại:

> Đây là dữ liệu vừa tạo ở giao diện khách hàng. Admin có thể tìm kiếm, xem chi tiết và cập nhật trạng thái. Việc thay đổi trạng thái gọi API có JWT Admin và scope CRM; backend kiểm tra quyền trước khi ghi SQL Server. Giao diện sau đó nhận JSON mới và cập nhật danh sách.

#### 09:15–11:30 — CMS nội dung

Thao tác:

1. Mở **Sản phẩm & hiển thị**.
2. Dùng ô tìm kiếm và bộ lọc trạng thái.
3. Mở form sửa một sản phẩm để giới thiệu các trường, sau đó đóng mà không lưu.
4. Chuyển tab **Menu poster**, tìm/lọc một poster và mở form sửa để chỉ upload.
5. Mở **Hành trình thương hiệu**, **Trang chủ** và **Hệ thống cửa hàng**.

Lời thoại:

> Module Sản phẩm hỗ trợ tìm kiếm, lọc, phân trang và CRUD. Tab Menu poster quản lý poster theo chi nhánh và có upload ảnh. Trong video bàn giao tôi chỉ mở form để minh họa, không xóa dữ liệu mẫu. Các module Home Sections, Brand Timeline và Stores dùng cùng mô hình controller–service–repository.

Không tạo/xóa sản phẩm trong bản quay chính; luồng E2E CRUD hiện có selector cần cập nhật theo form mới.

#### 11:30–12:30 — Accounts, Audit Logs và phân quyền

Thao tác:

1. Mở **Tài khoản & phân quyền**, thử tìm `user@aloo.vn`.
2. Chỉ các bộ lọc role/status/scope.
3. Mở **Nhật ký hệ thống**.
4. Không đổi role, trạng thái hoặc mật khẩu.

Lời thoại:

> Accounts hỗ trợ quản lý Admin và khách hàng, trạng thái tài khoản và scope. Các thao tác quản trị quan trọng được ghi Audit Logs. Tôi không thay đổi tài khoản chính trong video để giữ môi trường demo ổn định.

#### 12:30–13:30 — Kết thúc

Lời thoại:

> Source gồm frontend, backend, migration Flyway, schema, sample data, Postman collection và tài liệu cài đặt. Unit test frontend hiện có 84 trên 84 pass; backend có 39 trên 39 pass; production build thành công. Bộ Playwright Chromium desktop gần nhất đã đạt 8 trên 8 test trên SQL Server demo; log kết quả được lưu trong thư mục `handover/evidence`. Kết quả local này không thay thế kiểm thử production. Các giới hạn production như OAuth, SMTP, Redis, reverse proxy, upload và quyền media được ghi trong `KNOWN-ISSUES.md`.

## Những chức năng không nên thao tác trong video

- Không đổi mật khẩu User/Admin.
- Không xóa tài khoản, lead, tin nhắn, review, sản phẩm hoặc media.
- Không nâng/hạ role tài khoản chính.
- Không bật Google OAuth hoặc SMTP nếu chưa có credential demo riêng.
- Không upload ảnh cá nhân hoặc file có thông tin nhạy cảm.
- Không mở `.env`, terminal có secret hoặc trang quản trị dịch vụ production.
- Không tạo/sửa sản phẩm thật; chỉ mở form và đóng lại.

## Phục hồi nhanh khi quay

| Sự cố | Xử lý trong tối đa 20 giây |
|---|---|
| Trang trắng/stale | `Ctrl+F5`, chờ frontend tải lại; nếu vẫn lỗi thì nói rõ và chuyển module |
| Form báo trùng | Đổi hậu tố thời gian trong tên/email rồi gửi lại |
| Không thấy lead | Bỏ bộ lọc trạng thái, tìm theo đúng tên hoặc số điện thoại |
| Session hết hạn | Đăng xuất và đăng nhập lại bằng tài khoản demo |
| Admin bị chuyển về User | Dừng quay; khôi phục role `ADMIN/FULL` trong database demo trước khi quay lại |
| Chat không realtime | Chứng minh session trong Admin và ghi nhận WebSocket là mục cần kiểm tra |
| Upload lỗi | Không thử lặp lại; chỉ trình bày form và nêu yêu cầu `UPLOAD_DIR`/quyền ghi |
| API trả 500 | Nói rõ endpoint gặp lỗi, liên hệ `KNOWN-ISSUES.md`, rồi chuyển phần kế tiếp |
| Lỡ mở secret/thông tin cá nhân | Dừng và quay lại từ đầu; không sử dụng video đó |

## Trạng thái rehearsal gần nhất

Xem `handover/evidence/REHEARSAL-RESULTS-2026-07-23.md`.
