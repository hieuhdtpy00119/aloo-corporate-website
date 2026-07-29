# HƯỚNG DẪN CÀI ĐẶT VÀ VẬN HÀNH

Cập nhật: 29/07/2026.

## 1. Yêu cầu

- Node.js 22.11.0 trở lên và npm.
- JDK 21, Maven 3.9+.
- PostgreSQL 17 (hệ thống hiện được xác minh với PostgreSQL 17.10).
- Redis chỉ cần khi `RATE_LIMIT_BACKEND=redis`; local dùng `memory`.

## 2. PostgreSQL local

Tạo database và tài khoản runtime theo chính sách của đơn vị vận hành. Cấu hình tối thiểu:

```powershell
$env:DB_URL='jdbc:postgresql://localhost:5432/aloo_cms'
$env:DB_USERNAME='postgres'
$env:DB_PASSWORD='<mat-khau-postgresql>'
$env:JWT_SECRET='<chuoi-bi-mat-ngau-nhien-it-nhat-32-ky-tu>'
$env:CORS_ALLOWED_ORIGIN='http://localhost:5173'
$env:RATE_LIMIT_BACKEND='memory'
```

Flyway tự kiểm tra và áp dụng migration trong `backend/src/main/resources/db/migration`. Không sửa migration đã chạy và không dùng lại script SQL Server cũ để khởi tạo môi trường mới.

## 3. Backend

Kho ảnh hiện tại nằm ở `uploads/` tại thư mục gốc dự án. Khi chạy Maven từ `backend/`, đặt:

```powershell
$env:UPLOAD_DIR='../uploads'
cd backend
mvn spring-boot:run -Dspring-boot.run.profiles=local
```

Backend: `http://localhost:8080`  
API: `http://localhost:8080/api`

Với production, `UPLOAD_DIR` phải trỏ đến volume bền vững có quyền ghi và cơ chế backup. Không dùng đường dẫn tương đối nếu thư mục làm việc của tiến trình không được cố định.

## 4. Frontend

Mở terminal khác:

```powershell
cd frontend
Copy-Item .env.example .env
npm install
npm run dev
```

Frontend: `http://localhost:5173`

## 5. Kiểm tra nghiệm thu

```powershell
cd frontend
npm test -- --run
npm run build
```

```powershell
cd backend
mvn test
```

Kiểm tra nhanh khi hai tiến trình đang chạy:

```powershell
curl.exe -i "http://localhost:8080/api/home-sections?activeOnly=true"
curl.exe -i "http://localhost:8080/api/products"
curl.exe -i "http://localhost:8080/api/posts"
```

## 6. Bảo mật và vận hành

- Không commit `.env`, mật khẩu PostgreSQL, JWT secret, OAuth secret hoặc SMTP credential.
- Chuyển credential production qua password manager/kênh bí mật riêng; không ghi trong biên bản.
- Đổi hoặc vô hiệu hóa tài khoản demo trước khi mở internet.
- Backup cả PostgreSQL và volume `UPLOAD_DIR`, sau đó thử phục hồi trước go-live.
- Cấu hình HTTPS, reverse proxy, CORS, rate limit và WebSocket trên môi trường đích.

