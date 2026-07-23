# KẾT QUẢ ĐÃ XÁC MINH

Thời điểm chạy: 22/07/2026 (Asia/Saigon).

| Lệnh | Kết quả |
|---|---|
| `cd frontend; npm test -- --run` | Pass — 27 test files, 84 tests |
| `cd frontend; npm run build` | Pass — Vite 8.0.12, 1,980 modules transformed |
| `cd backend; mvn -q test` | Pass — 12 suites, 39 tests, 0 failures/errors/skipped |

Build frontend tạo bundle chính khoảng 1,471.56 kB (gzip 427.08 kB) và phát cảnh báo chunk vượt 500 kB.

E2E tích hợp thật chưa chạy trong lượt này; không đánh dấu pass cho đến khi có SQL Server demo và hai server hoạt động.
