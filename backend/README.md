# ALOO Franchise CMS Backend

Backend Spring Boot cho ALOO Franchise CMS.

## Stack

- Java 21
- Spring Boot 3
- Maven
- PostgreSQL
- Flyway
- Spring Data JPA
- Spring Security JWT
- Lombok
- Jakarta Validation

## Cấu hình môi trường

Production bắt buộc set env, không có fallback mật khẩu/secret trong `application.properties`:

```bash
DB_URL=jdbc:postgresql://<host>:5432/aloo_cms
DB_USERNAME=<production-user>
DB_PASSWORD=<production-password>
DB_MIGRATION_USERNAME=<migration-user-with-ddl-permission>
DB_MIGRATION_PASSWORD=<migration-password>
JWT_SECRET=<random-secret-at-least-32-characters>
CORS_ALLOWED_ORIGIN=https://your-domain.com
```

Local dùng profile `local`, cấu hình nằm trong `application-local.properties`:

```powershell
mvn spring-boot:run -Dspring-boot.run.profiles=local
```

Không commit `.env`, mật khẩu database, JWT secret hoặc credential production vào Git.

## Rate limit

Mặc định local dùng in-memory rate limit, không cần set biến môi trường và không cần Redis:

```properties
app.rate-limit.backend=memory
```

Các endpoint đang được giới hạn:

- Admin login: 8 lần / 15 phút / IP + email
- User login: 10 lần / 15 phút / IP + email
- Admin upload: 40 lần / 10 phút / IP
- User upload: 30 lần / 10 phút / IP


## Quản lý schema database

Flyway trong `src/main/resources/db/migration` quản lý các thay đổi schema
PostgreSQL. Các script SQL Server cũ trong `database/` chỉ được giữ lại làm
tài liệu tham khảo khi di chuyển dữ liệu và không được dùng cho môi trường mới.

Các thay đổi schema mới phải nằm trong `src/main/resources/db/migration` và dùng
tên `V<version>__<description>.sql`. Flyway chạy migration trước khi Hibernate
kiểm tra schema. Không sửa migration đã được áp dụng và không dùng `DROP TABLE`
trong migration thông thường.

Production nên tách hai tài khoản:

- `DB_MIGRATION_USERNAME`: có quyền `CREATE`/`ALTER`, chỉ dùng khi triển khai.
- `DB_USERNAME`: tài khoản runtime, chỉ có `SELECT`/`INSERT`/`UPDATE`/`DELETE`.

Khởi tạo database mới lần đầu:

```powershell
sqlcmd -S localhost -E -C -i database/aloo_franchise_cms.sql
```

## Chạy backend

Chạy app:

```powershell
mvn spring-boot:run -Dspring-boot.run.profiles=local
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

## Auth (unified for admin + customer)

Login:

```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@aloo.vn",
  "password": "your-password"
}
```

Authenticated calls use:

```http
Authorization: Bearer <token>
```

- `GET /api/auth/me`
- `PUT /api/auth/profile`
- `POST /api/auth/profile/avatar`
- `PUT /api/auth/change-password`
- `POST /api/auth/password-change/request-otp`
- Google OAuth: `/oauth2/**` → frontend `/oauth/callback` (token delivered in URL fragment)

## Public API

- `GET /api/products` (active only for anonymous)
- `GET /api/products/slug/{slug}`
- `GET /api/posts` (published only for anonymous)
- `GET /api/posts/slug/{slug}`
- `GET /api/stores`
- `GET /api/stores/featured`
- `GET /api/stores/{slug}`
- `GET /api/franchise-contents`
- `GET /api/home-sections?activeOnly=true`
- `GET /api/brand-timelines?activeOnly=true`
- `GET /api/hero-banners`
- `GET /api/menu-posters`
- `GET /api/testimonials`
- `POST /api/contact-messages`
- `POST /api/franchise-registrations`
- `POST /api/chat/sessions`

## Admin API (requires ADMIN + scope)

- Content: products, posts, categories, home-sections, franchise-contents, hero-banners, brand-timelines, menu-posters
- Stores: `/api/admin/stores`
- CRM: franchise-registrations, contact-messages, testimonials, product reviews, live chat
- System: accounts, audit-logs
- `POST /api/uploads/images`
