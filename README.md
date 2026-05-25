# ALOO Franchise CMS

Repository này tách rõ frontend và backend:

```text
aloo-corporate-website/
├─ frontend/   # Vue 3 + Vite
└─ backend/    # Spring Boot + SQL Server
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
