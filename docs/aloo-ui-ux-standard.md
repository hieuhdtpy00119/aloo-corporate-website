# ALOO UI/UX Standard

Tai lieu nay la bo quy chuan noi bo cho ALOO Franchise CMS. Muc tieu la giu giao dien dep, de dung, de quan ly va dong bo giua public website, admin CMS, frontend, backend va database.

## 1. Muc tieu san pham

- Public website phai tra loi nhanh: ALOO la gi, co san pham gi, mo hinh nhuong quyen ra sao, dang ky tu van o dau.
- Admin CMS phai giup thao tac nhanh: xem danh sach, loc, them, sua, an/hien, xoa va kiem tra trang thai.
- Moi du lieu public quan trong phai co nguon quan ly trong admin hoac duoc ghi ro la noi dung tinh.
- Khong tao module, bang database hoac API neu frontend chua co flow that.

## 2. Nguyen tac cau truc thong tin

| Nhom | Muc tieu | Trang public | Trang admin |
| --- | --- | --- | --- |
| San pham | Xem mon/menu va hinh anh thuc te | `/products`, trang chu | `/admin/products` |
| Menu poster | Quan ly anh menu theo chi nhanh/khu vuc | `/products` | `/admin/products` tab `Menu hien thi` |
| Bai viet | Doc cau chuyen, tin tuc, SEO | `/blog`, `/blog/:id` | `/admin/articles` |
| Dia diem | Tim cua hang va thong tin lien he | `/locations` | `/admin/locations` |
| Dang ky tu van | Thu lead nhuong quyen | `/consultation`, `/franchise` | `/admin/registrations` |
| Noi dung nhuong quyen | Trinh bay loi ich, chi phi, quy trinh | `/franchise`, `/process`, `/cost` | `/admin/franchise-content` |
| Tai khoan | Xem/sua thong tin, doi mat khau | `/profile`, `/change-password` | `/admin/profile` |

## 3. Nguyen tac public website

- Moi trang public chi nen co mot muc tieu chinh va toi da hai CTA ro rang.
- Hero phai co tin hieu thuong hieu/san pham trong viewport dau tien.
- Trang san pham uu tien hinh anh that, ten mon, mo ta ngan, danh muc va trang thai hien thi.
- Trang blog phai de quet khi co nhieu bai: bai moi noi bat, danh muc, tim kiem, danh sach gon, trang chi tiet ro.
- Trang nhuong quyen phai dan user theo luong: ly do chon ALOO -> mo hinh -> chi phi -> quy trinh -> form tu van.
- Footer khong duoc bien thanh noi dung chinh cua trang. Neu trang chi con header/footer la dang thieu content hoac API/route loi.

## 4. Nguyen tac admin CMS

- Admin la cong cu lam viec, khong phai landing page. Uu tien mat do thong tin vua du, thao tac nhanh, khong trang tri qua nhieu.
- Tat ca Data Table phai co: title, mo ta ngan, thanh tim kiem co label, filter co label, empty state, loading state, error state.
- Row trong bang uu tien mot dong. Text dai can gioi han bang ellipsis, mo chi tiet bang modal/trang detail.
- Cot hanh dong thong nhat thu tu: `Xem` -> `Sua` -> `Xoa` neu co day du, hoac `Sua` -> `Xoa` neu khong co detail.
- Trang thai phai hien thi tieng Viet trong UI. Backend van co the dung enum tieng Anh.
- Form phai co label that, placeholder chi la goi y. Khong de icon chen len text input.
- Upload anh phai co preview, fallback khi anh hong, va thong bao loi ro.

## 5. Design tokens

| Token | Gia tri | Cach dung |
| --- | --- | --- |
| Brand deep | `#122310` | text chinh, footer, admin sidebar |
| Brand green | `#2d5a27` | CTA chinh, active state |
| Brand light | `#e3f4da` | background nhe, active pill |
| Accent yellow | `#f9e49b` | nhan phu, warning nhe |
| Surface | `#ffffff` | card, modal, table |
| App background | `#f6f8f5` | admin background |
| Text muted | `#5f6f89` | mo ta, helper text |
| Border | `#dbe5d5` | input, card, table |

Spacing dung he 4px/8px:

- XS: `4px`
- SM: `8px`
- MD: `16px`
- LG: `24px`
- XL: `32px`
- 2XL: `48px`
- 3XL: `72px`

Border radius:

- Button/input: `14px - 16px`
- Card/admin panel: `18px - 24px`
- Khong long card trong card neu khong can modal/detail.

## 6. Typography

- Heading dung font display `Outfit`.
- Body dung `Inter`.
- Khong scale font theo viewport width.
- Khong dung letter-spacing am.
- Trong admin, heading trong panel khong duoc lon nhu hero public.
- Text trong table phai co gioi han dong de tranh day vo layout.

## 7. Component standard

### Page header

Moi trang nen co:

- Eyebrow ngan: vi du `He thong quan tri`, `ALOO Journal`
- Title ro: vi du `Quan ly san pham`
- Description mo ta ngu canh va nguon du lieu
- CTA nam ben phai neu co

Dung component `AlooPageHeader.vue` cho man hinh moi.

### Status badge

Dung component `AlooStatusBadge.vue` de chuyen enum sang tieng Viet:

- `ACTIVE` -> `Dang hoat dong`
- `INACTIVE` -> `Tam an`
- `DRAFT` -> `Ban nhap`
- `PENDING` -> `Cho duyet`
- `PUBLISHED` -> `Da xuat ban`
- `ARCHIVED` -> `Luu tru`
- `NEW` -> `Moi`
- `CONTACTED` -> `Da lien he`
- `COMPLETED` -> `Hoan tat`

### Form

- Field bat buoc phai co label.
- Error nam ngay duoi field.
- Submit button co loading va disabled khi dang gui.
- Sau khi submit thanh cong can co toast hoac message ro.

### Table

- Header viet hoa nhe, mau muted.
- Status can badge.
- Action button co kich thuoc thong nhat.
- Row height on dinh, khong de content lam row nhay.

## 8. Data va API consistency

Frontend dung camelCase:

- `fullName`
- `imageUrl`
- `createdAt`
- `updatedAt`

Backend DTO dung camelCase giong frontend.

Database dung snake_case:

- `full_name`
- `image_url`
- `created_at`
- `updated_at`

Khong tao hai nguon du lieu rieng cho cung mot noi dung. Neu admin sua/xoa/an mot item thi public phai doc cung API hoac store tu API do.

## 9. Loading, empty, error

Moi trang goi API phai co 3 trang thai:

- Loading: skeleton/spinner, khong de trang trang.
- Empty: noi ro chua co du lieu va CTA neu la admin.
- Error: noi ro loi va nut thu lai neu hop ly.

## 10. Checklist truoc khi merge

- [ ] Trang co muc tieu chinh ro rang.
- [ ] Admin va public doc cung nguon du lieu neu cung hien thi mot entity.
- [ ] Khong con mock rieng neu backend da co API.
- [ ] Form co label, validate, loading, success, error.
- [ ] Table khong bi chong chu, row khong vo layout.
- [ ] Status hien thi tieng Viet.
- [ ] Anh co fallback khi loi.
- [ ] Responsive desktop/mobile khong chong noi dung.
- [ ] `npm run test` pass.
- [ ] `npm run build` pass.
