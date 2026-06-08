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

## Cấu hình môi trường

Production bắt buộc set env, không có fallback mật khẩu/secret trong `application.properties`:

```bash
DB_URL=jdbc:sqlserver://<host>:1433;databaseName=ALOO_Franchise_CMS;encrypt=true;trustServerCertificate=false
DB_USERNAME=<production-user>
DB_PASSWORD=<production-password>
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


## Chạy backend

Tạo database/schema bằng script:

```powershell
sqlcmd -S localhost -E -C -i database/aloo_franchise_cms.sql
```

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
- `GET /api/stores`
- `GET /api/stores/featured`
- `GET /api/stores/{slug}`
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
- `GET /api/admin/stores`
- `POST /api/admin/stores`
- `PUT /api/admin/stores/{id}`
- `DELETE /api/admin/stores/{id}`
- `PUT /api/franchise-contents/{id}`
- `POST /api/hero-banners`
- `PUT /api/hero-banners/{id}`
- `DELETE /api/hero-banners/{id}`
- `POST /api/menu-posters`
- `PUT /api/menu-posters/{id}`
- `DELETE /api/menu-posters/{id}`
