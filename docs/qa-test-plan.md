# ALOO Franchise CMS QA Test Plan

## 1. Backend API Test Cases

| Module | Endpoint | Happy path | Edge case | Error/security case |
| --- | --- | --- | --- | --- |
| Auth | `POST /api/auth/login` | Valid `admin@aloo.vn / 123456` returns JWT and user DTO | Missing email/password, invalid email | Wrong password returns `401`; response must not expose `passwordHash` |
| Auth | `GET /api/auth/me` | Valid Bearer token returns current admin | Expired JWT | Missing/invalid token returns `401` |
| Auth | `PUT /api/auth/profile` | Valid token updates name/phone/avatar | Empty or too-long fields | Missing token `401`; non-admin `403` |
| Auth | `PUT /api/auth/change-password` | Correct old password changes BCrypt hash | Short/new mismatch/current password wrong | Missing token `401`; invalid body `400` |
| Products | `GET /api/products` | Public list returns array | Empty database returns `[]` | Unexpected service exception returns sanitized `500` |
| Products | `GET /api/products/{id}` | Existing id returns DTO | Large/non-existing id | Missing product returns `404` |
| Products | `POST /api/products` | Admin creates product | Missing `name`/`slug`, negative price | Missing/expired token `401`; duplicate slug `400` |
| Products | `PUT /api/products/{id}` | Admin updates product | Invalid category id | Missing product `404`; missing token `401` |
| Products | `DELETE /api/products/{id}` | Admin deletes product | Delete already deleted id | Missing product `404`; missing token `401` |
| Posts | `/api/posts` CRUD | Admin CRUD, public GET and GET slug | Missing title/slug/content | Missing token on mutation `401`; unknown id `404` |
| Categories | `/api/categories` CRUD | Admin CRUD, public GET | Duplicate slug/type mismatch | Mutation without token `401` |
| Registrations | `POST /api/franchise-registrations` | Public lead is saved | Missing `fullName`, `phone`, `province`; bad phone/email | Bad validation `400`; Telegram removed so no external failure |
| Registrations | `GET/PATCH/DELETE /api/franchise-registrations` | Admin lists, changes status, deletes | Invalid status string | Missing token `401`; unknown id `404` |
| Locations | `/api/locations` CRUD | Admin CRUD, public GET | Missing name/address/province | Mutation without token `401` |
| Franchise content | `/api/franchise-contents` | Public GET, admin PUT | Invalid section/status | PUT without token `401`; unknown id `404` |
| Uploads | `POST /api/uploads/images` | Admin uploads allowed image | Oversized file, empty file | Missing token `401`; invalid MIME `400` |

Implemented backend tests:

- `ApiSecurityIntegrationTest`: MockMvc API/security/JWT/CORS/validation smoke tests.
- `JwtServiceTest`: JWT valid, mismatched user, expired token.
- `ProductServiceTest`: service duplicate slug and create behavior.
- `FranchiseRegistrationServiceTest`: lead create/status/not-found behavior.
- `ProductRepositoryDataJpaTest`: JPA repository save/find/slug lookup.
- `SqlServerJpaConnectionIT`: optional real SQL Server smoke test, enabled only with `RUN_SQLSERVER_IT=true`.

## 2. Frontend Test Cases

| Area | Test cases |
| --- | --- |
| Axios | Uses `VITE_API_URL` fallback; attaches admin/user JWT; does not overwrite explicit Authorization; clears token on `401` |
| Router | `/admin/*` redirects to `/admin/login` without admin token; allows with admin token; `/profile` redirects to `/login` without user token |
| Public form | Consultation form maps UI fields to backend DTO: `fullName`, `phone`, `email`, `province`, `expectedBudget`, `note` |
| Admin table | Data rows render in one line, status badge renders, actions render |
| E2E auth | Login admin through `/admin/login` with real backend |
| E2E CRUD | Create/update/delete product through admin UI |
| E2E lead | Submit public consultation form and verify lead appears in admin |
| Responsive | Playwright runs desktop Chromium and mobile Chrome profile |

Implemented frontend tests:

- `src/services/api.spec.js`
- `src/router/index.spec.js`
- `src/components/public/ConsultationForm.spec.js`
- `src/components/admin/DataTable.spec.js`
- `tests/e2e/aloo-flows.spec.js`

## 3. Integration Checks

| Check | Expected result |
| --- | --- |
| CORS | `Origin: http://localhost:5173` can call backend `8080` with Authorization and Content-Type |
| JWT flow | Login returns token, FE stores it in `localStorage.admin_token`, later requests send `Authorization: Bearer <token>` |
| Expired token | Backend returns `401`, FE clears token and redirects protected pages to login |
| Base URL | `frontend/.env` uses `VITE_API_URL=http://localhost:8080/api` |
| Field mapping | FE camelCase payload maps to backend DTO camelCase, database remains snake_case |

## 4. Commands

Backend unit/integration tests:

```bash
cd backend
mvn test
```

Optional real SQL Server JPA smoke test:

```bash
cd backend
set RUN_SQLSERVER_IT=true
set DB_PASSWORD=123456
mvn -Dtest=SqlServerJpaConnectionIT test
```

Frontend component/router/service tests:

```bash
cd frontend
npm install
npm run test
```

E2E tests, with backend running on `8080`:

```bash
cd frontend
npm run e2e
```

## 5. Common Risks For This Stack

- JWT secret shorter than 32 bytes breaks HS256 signing.
- CORS allowing `*` with credentials is invalid and unsafe.
- Frontend token key mismatch: `admin_token` vs `user_token`.
- Backend validation returns field errors but frontend only displays generic message.
- JPA tests against H2 cannot fully replace SQL Server behavior for `nvarchar(max)`, identity, collation and date precision.
- E2E CRUD tests need a clean or disposable database because they create/delete real rows.
