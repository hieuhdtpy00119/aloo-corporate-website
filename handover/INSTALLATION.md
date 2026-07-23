# HƯỚNG DẪN CÀI ĐẶT VÀ CHẠY DỰ ÁN

## 1. Yêu cầu

- Git.
- Node.js **22.11.0 trở lên** và npm.
- Java Development Kit **21** (project được kiểm thử thành công bằng Java 22.0.2, nhưng `pom.xml` target Java 21).
- Maven 3.9+ hoặc Maven đi kèm IntelliJ IDEA.
- Microsoft SQL Server và `sqlcmd`/SQL Server Management Studio.
- Redis chỉ bắt buộc khi đặt `RATE_LIMIT_BACKEND=redis`; local nên dùng `memory`.

## 2. Database local/demo

Chạy trong PowerShell từ thư mục gốc repo:

```powershell
sqlcmd -S localhost -E -C -i handover/database/aloo_franchise_cms.sql
sqlcmd -S localhost -E -C -i handover/database/aloo_franchise_cms_sample_data.sql
```

Nếu dùng SQL authentication:

```powershell
sqlcmd -S localhost -U sa -P '<password>' -C -i handover/database/aloo_franchise_cms.sql
sqlcmd -S localhost -U sa -P '<password>' -C -i handover/database/aloo_franchise_cms_sample_data.sql
```

Script schema chỉ dùng để tạo database mới. Sau khi hệ thống đã hoạt động, thay đổi schema phải đi qua Flyway trong `backend/src/main/resources/db/migration`.

## 3. Backend

Không commit `.env` hoặc secret thật. Copy `handover/.env.example` làm danh sách biến cần cấu hình, rồi đặt biến trong shell/secret manager.

```powershell
$env:DB_URL='jdbc:sqlserver://localhost:1433;databaseName=ALOO_Franchise_CMS;encrypt=true;trustServerCertificate=true'
$env:DB_USERNAME='sa'
$env:DB_PASSWORD='<your-password>'
$env:DB_MIGRATION_USERNAME='sa'
$env:DB_MIGRATION_PASSWORD='<your-password>'
$env:JWT_SECRET='<random-secret-at-least-32-characters>'
$env:CORS_ALLOWED_ORIGIN='http://localhost:5173'
$env:CORS_INCLUDE_LOCALHOST='true'
$env:RATE_LIMIT_BACKEND='memory'

cd backend
mvn spring-boot:run
```

Backend: `http://localhost:8080`  
API base URL: `http://localhost:8080/api`

Google OAuth và email là tùy chọn cho local. Nếu bật, điền các biến tương ứng trong `.env.example`.

## 4. Frontend

Mở terminal khác:

```powershell
cd frontend
Copy-Item .env.example .env
npm install
npm run dev
```

Frontend: `http://localhost:5173`

## 5. Kiểm tra

```powershell
cd frontend
npm test
npm run build
```

```powershell
cd backend
mvn test
```

E2E cần frontend và backend đang chạy cùng database demo:

```powershell
cd frontend
npm run e2e
```

Có thể override tài khoản admin E2E bằng `E2E_ADMIN_EMAIL` và `E2E_ADMIN_PASSWORD`.

## 6. Thứ tự dừng hệ thống

Nhấn `Ctrl+C` tại terminal frontend và backend. Không xóa database nếu vẫn cần đối chiếu với video demo.

