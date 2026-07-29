# ALOO Corporate Website

Website frontend và giao diện quản trị CMS tích hợp backend cho **ALOO - Kem Bơ Thuần Việt**.

## Công nghệ sử dụng

- Vue 3
- Vite
- Vue Router
- Pinia
- Tailwind CSS
- Axios

## Yêu cầu

- Node.js 22.11.0 trở lên
- npm
- Git

## Node Version Manager

Sử dụng Node Version Manager để chuyển sang đúng phiên bản Node.js mà project yêu cầu.

```bash
nvm install 22.11.0
nvm use 22.11.0
node -v
```

Project cũng có file `.nvmrc`, nên Node Version Manager có thể đọc phiên bản Node.js cần dùng trực tiếp từ repository.

## Tải project

Clone repository:

```bash
git clone https://github.com/hieuhdtpy00119/aloo-corporate-website.git
cd aloo-corporate-website
```

## Cài đặt dependencies

```bash
npm install
```

## Cấu hình môi trường

Tạo file `.env` từ file mẫu nếu cần:

```bash
cp .env.example .env
```

Default example:

```env
VITE_API_URL=http://localhost:8080/api
```

Các chức năng nghiệp vụ dùng API backend. Khởi động backend tại cổng `8080` trước khi kiểm thử tích hợp hoặc dùng CMS.

## Chạy development server

```bash
npm run dev
```

Mở:

```text
http://localhost:5173/
```

## Build production

```bash
npm run build
```

## Xem trước bản production build

```bash
npm run preview
```

## Demo admin

Đường dẫn đăng nhập admin:

```text
http://localhost:5173/admin/login
```

Tài khoản demo:

```text
Email: admin@aloo.vn
Password: 123456
```

## Các route chính

Public:

- `/`
- `/about`
- `/products`, `/products/:slug`
- `/locations`, `/locations/:slug`
- `/franchise`
- `/blog`, `/blog/:slug`
- `/consultation`
- `/contact`
- `/account`
- `/login`, `/oauth/callback`

Admin (canonical nested paths):

- `/admin`
- `/admin/content/home-sections`
- `/admin/content/brand-timeline`
- `/admin/content/products`
- `/admin/content/franchise`
- `/admin/content/articles`
- `/admin/stores/locations`
- `/admin/crm/feedbacks`
- `/admin/crm/product-reviews`
- `/admin/crm/leads`
- `/admin/crm/contact-messages`
- `/admin/crm/live-chat`
- `/admin/system/accounts`
- `/admin/system/audit-logs`
- `/admin/profile`

Legacy flat paths like `/admin/products` still redirect to the nested routes above.
## Ghi chú

- `node_modules/`, `dist/` và `.env` được Git bỏ qua.
- Không commit API key thật hoặc secret thật lên Git.
- Các biến Vite bắt đầu bằng `VITE_` sẽ bị expose ra browser, nên secret key phải được lưu ở backend service.
