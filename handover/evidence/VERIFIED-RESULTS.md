# KẾT QUẢ ĐÃ XÁC MINH

Thời điểm chạy gần nhất: 24/07/2026 (Asia/Saigon).

| Lệnh | Kết quả |
|---|---|
| `cd frontend; npm test -- --run` | Pass — 27 test files, 84 tests |
| `cd frontend; npm run build` | Pass — Vite 8.0.12, 1,980 modules transformed |
| `cd backend; mvn -q test` | Pass — 12 suites, 39 tests, 0 failures/errors/skipped |
| `npm run e2e -- --project=chromium --reporter=list` với SQL Server local + hai server | Pass — 8/8 test |

Build frontend tạo bundle chính khoảng 1,471.56 kB (gzip 427.08 kB) và phát cảnh báo chunk vượt 500 kB.

E2E desktop đã chạy với SQL Server local, backend và frontend hoạt động. Cả 8 test đều pass trong lần xác nhận cuối; xem `PLAYWRIGHT-DESKTOP-8-8-2026-07-24.log`. Kết quả này không thay thế kiểm thử production hoặc đa trình duyệt.
