# ALOO Franchise CMS Backend

Backend Spring Boot cho ALOO Franchise CMS.

## Stack

- Java 21
- Spring Boot 3
- Maven
- SQL Server
- Spring Data JPA
- Spring Security JWT
- Lombok
- Jakarta Validation
- Telegram notification

## Cấu hình

Database mặc định:

```properties
spring.datasource.url=jdbc:sqlserver://localhost:1433;databaseName=ALOO_Franchise_CMS;encrypt=true;trustServerCertificate=true
spring.datasource.username=sa
spring.datasource.password=change-me
```

Nên override bằng biến môi trường:

```powershell
$env:DB_URL="jdbc:sqlserver://localhost:1433;databaseName=ALOO_Franchise_CMS;encrypt=true;trustServerCertificate=true"
$env:DB_USERNAME="sa"
$env:DB_PASSWORD="your-password"
$env:JWT_SECRET="change-this-secret-to-at-least-32-characters"
$env:TELEGRAM_BOT_TOKEN="your-telegram-bot-token"
$env:TELEGRAM_CHAT_ID="your-telegram-chat-id"
```

## Rate limit

Mặc định local dùng in-memory rate limit, không cần Redis:

```properties
app.rate-limit.backend=memory
```

Khi deploy production nhiều instance, bật Redis để chia sẻ rate limit giữa các server:

```powershell
$env:RATE_LIMIT_BACKEND="redis"
$env:REDIS_HOST="localhost"
$env:REDIS_PORT="6379"
$env:REDIS_PASSWORD=""
```

Các endpoint đang được giới hạn:

- Admin login: 8 lần / 15 phút / IP + email
- User login: 10 lần / 15 phút / IP + email
- Admin upload: 40 lần / 10 phút / IP
- User upload: 30 lần / 10 phút / IP

Nếu Redis lỗi, backend ghi warning và fallback tạm về in-memory để API không sập.

Admin seed mặc định khi bảng `users` đang trống:

```text
Email: admin@aloo.vn
Password: 123456
```

Có thể đổi bằng:

```powershell
$env:ADMIN_EMAIL="admin@example.com"
$env:ADMIN_PASSWORD="your-strong-password"
$env:ADMIN_FULL_NAME="Admin"
```

User seed mặc định khi bảng `customer_users` chưa có tài khoản:

```text
Email: user@aloo.vn
Password: 123456
```

Có thể đổi bằng:

```powershell
$env:USER_EMAIL="user@example.com"
$env:USER_PASSWORD="your-strong-password"
$env:USER_FULL_NAME="ALOO User"
```

## Chạy backend

Tạo database/schema bằng script:

```powershell
sqlcmd -S localhost -E -C -i database/aloo_franchise_cms.sql
```

Chạy app:

```powershell
mvn spring-boot:run
```

Backend chạy tại:

```text
http://localhost:8080/api
```

CORS đã cho phép frontend:

```text
http://localhost:5173
```

## Auth

Login:

```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "admin@aloo.vn",
  "password": "123456"
}
```

Response trả JWT:

```json
{
  "token": "...",
  "tokenType": "Bearer",
  "user": {
    "id": 1,
    "email": "admin@aloo.vn",
    "fullName": "ALOO Admin",
    "role": "ADMIN"
  }
}
```

Các API admin dùng header:

```http
Authorization: Bearer <token>
```

## User Auth

Login user:

```http
POST /api/user-auth/login
Content-Type: application/json

{
  "email": "user@aloo.vn",
  "password": "123456"
}
```

Các API user dùng header:

```http
Authorization: Bearer <user-token>
```

- `GET /api/user-auth/me`
- `PUT /api/user-auth/profile`
- `PUT /api/user-auth/change-password`
- `POST /api/user-auth/uploads/images`

## Public API

- `GET /api/products`
- `GET /api/products/{id}`
- `GET /api/posts`
- `GET /api/posts/{id}`
- `GET /api/posts/slug/{slug}`
- `GET /api/locations`
- `GET /api/franchise-contents`
- `GET /api/hero-banners`
- `GET /api/menu-posters`
- `POST /api/franchise-registrations`

## Admin API

- `GET /api/auth/me`
- `PUT /api/auth/profile`
- `PUT /api/auth/change-password`
- `POST /api/products`
- `PUT /api/products/{id}`
- `DELETE /api/products/{id}`
- `POST /api/posts`
- `PUT /api/posts/{id}`
- `DELETE /api/posts/{id}`
- `GET /api/categories`
- `POST /api/categories`
- `PUT /api/categories/{id}`
- `DELETE /api/categories/{id}`
- `GET /api/franchise-registrations`
- `GET /api/franchise-registrations/{id}`
- `PATCH /api/franchise-registrations/{id}/status`
- `DELETE /api/franchise-registrations/{id}`
- `POST /api/locations`
- `PUT /api/locations/{id}`
- `DELETE /api/locations/{id}`
- `PUT /api/franchise-contents/{id}`
- `POST /api/hero-banners`
- `PUT /api/hero-banners/{id}`
- `DELETE /api/hero-banners/{id}`
- `POST /api/menu-posters`
- `PUT /api/menu-posters/{id}`
- `DELETE /api/menu-posters/{id}`

## Telegram

Khi `POST /api/franchise-registrations` thành công, backend lưu database rồi gửi Telegram cho admin.
Nếu Telegram lỗi hoặc thiếu config, API chính vẫn trả thành công và backend chỉ ghi warning log.
