# ALOO Franchise CMS

Repository này tách rõ frontend và backend:

```text
aloo-corporate-website/
├─ frontend/   # Vue 3 + Vite
└─ backend/    # Spring Boot + PostgreSQL
```

## Frontend

```powershell
cd frontend
npm install
npm run dev
```

Frontend chạy tại:

```text
http://localhost:5173
```

## Backend

```powershell
cd backend
$env:DB_PASSWORD="<your_sql_server_password>"
$env:JWT_SECRET="change-this-to-a-long-random-secret-at-least-32-characters"
$env:RATE_LIMIT_BACKEND="memory"
mvn spring-boot:run -Dspring-boot.run.profiles=local
```

Backend chạy tại:

```text
http://localhost:8080/api
```

Script database chính:

```text
backend/database/aloo_franchise_cms.sql
backend/database/aloo_franchise_cms_sample_data.sql  # dữ liệu mẫu local/demo
```

## Đăng nhập Google

Để bật đăng nhập bằng Google, tạo OAuth Client trong Google Cloud Console với loại **Web application**.

Authorized JavaScript origins:

```text
http://localhost:5173
```

Authorized redirect URIs:

```text
http://localhost:8080/login/oauth2/code/google
```

Sau đó chạy backend với các biến môi trường:

```powershell
$env:GOOGLE_CLIENT_ID="your-google-client-id.apps.googleusercontent.com"
$env:GOOGLE_CLIENT_SECRET="your-google-client-secret"
$env:OAUTH2_REDIRECT_URI="http://localhost:5173/oauth/callback"
```

Có thể copy `.env.example` thành `.env` để lưu cấu hình local. File `.env` đang được `.gitignore`, không commit secret thật lên Git.
