from pathlib import Path

from docx import Document
from docx.enum.section import WD_SECTION
from docx.enum.table import WD_CELL_VERTICAL_ALIGNMENT, WD_ROW_HEIGHT_RULE, WD_TABLE_ALIGNMENT
from docx.enum.text import WD_ALIGN_PARAGRAPH, WD_BREAK
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Cm, Inches, Pt, RGBColor


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "handover" / "output"
OUTPUT.mkdir(parents=True, exist_ok=True)
DOCX_PATH = OUTPUT / "ALOO-Bien-ban-nghiem-thu-va-ban-giao-2026-07-29.docx"
LOGO_PATH = ROOT / "frontend" / "public" / "logo-aloo.png"

BLUE = "2E74B5"
DARK_BLUE = "1F4D78"
GREEN = "4D8C2B"
DARK = "243238"
MUTED = "5E6A71"
LIGHT = "F2F4F7"
PALE_GREEN = "EDF6E8"
WHITE = "FFFFFF"
TABLE_WIDTH_DXA = 9360
TABLE_INDENT_DXA = 120


def set_cell_shading(cell, fill):
    tc_pr = cell._tc.get_or_add_tcPr()
    shd = tc_pr.find(qn("w:shd"))
    if shd is None:
        shd = OxmlElement("w:shd")
        tc_pr.append(shd)
    shd.set(qn("w:fill"), fill)


def set_cell_margins(cell, top=80, bottom=80, start=120, end=120):
    tc = cell._tc
    tc_pr = tc.get_or_add_tcPr()
    tc_mar = tc_pr.first_child_found_in("w:tcMar")
    if tc_mar is None:
        tc_mar = OxmlElement("w:tcMar")
        tc_pr.append(tc_mar)
    for key, value in (("top", top), ("bottom", bottom), ("start", start), ("end", end)):
        node = tc_mar.find(qn(f"w:{key}"))
        if node is None:
            node = OxmlElement(f"w:{key}")
            tc_mar.append(node)
        node.set(qn("w:w"), str(value))
        node.set(qn("w:type"), "dxa")


def set_cell_width(cell, width_dxa):
    tc_pr = cell._tc.get_or_add_tcPr()
    tc_w = tc_pr.find(qn("w:tcW"))
    if tc_w is None:
        tc_w = OxmlElement("w:tcW")
        tc_pr.append(tc_w)
    tc_w.set(qn("w:w"), str(width_dxa))
    tc_w.set(qn("w:type"), "dxa")


def set_table_geometry(table, widths):
    if sum(widths) != TABLE_WIDTH_DXA:
        raise ValueError(f"Table widths must sum to {TABLE_WIDTH_DXA}: {widths}")
    table.alignment = WD_TABLE_ALIGNMENT.LEFT
    table.autofit = False
    tbl_pr = table._tbl.tblPr
    tbl_w = tbl_pr.find(qn("w:tblW"))
    if tbl_w is None:
        tbl_w = OxmlElement("w:tblW")
        tbl_pr.append(tbl_w)
    tbl_w.set(qn("w:w"), str(TABLE_WIDTH_DXA))
    tbl_w.set(qn("w:type"), "dxa")

    tbl_ind = tbl_pr.find(qn("w:tblInd"))
    if tbl_ind is None:
        tbl_ind = OxmlElement("w:tblInd")
        tbl_pr.append(tbl_ind)
    tbl_ind.set(qn("w:w"), str(TABLE_INDENT_DXA))
    tbl_ind.set(qn("w:type"), "dxa")

    layout = tbl_pr.find(qn("w:tblLayout"))
    if layout is None:
        layout = OxmlElement("w:tblLayout")
        tbl_pr.append(layout)
    layout.set(qn("w:type"), "fixed")

    grid = table._tbl.tblGrid
    for child in list(grid):
        grid.remove(child)
    for width in widths:
        grid_col = OxmlElement("w:gridCol")
        grid_col.set(qn("w:w"), str(width))
        grid.append(grid_col)

    for row in table.rows:
        cant_split = OxmlElement("w:cantSplit")
        row._tr.get_or_add_trPr().append(cant_split)
        for idx, cell in enumerate(row.cells):
            set_cell_width(cell, widths[idx])
            set_cell_margins(cell)
            cell.vertical_alignment = WD_CELL_VERTICAL_ALIGNMENT.CENTER


def repeat_table_header(row):
    tr_pr = row._tr.get_or_add_trPr()
    tbl_header = OxmlElement("w:tblHeader")
    tbl_header.set(qn("w:val"), "true")
    tr_pr.append(tbl_header)


def set_repeat_on_each_page(paragraph):
    p_pr = paragraph._p.get_or_add_pPr()
    keep_next = OxmlElement("w:keepNext")
    p_pr.append(keep_next)


def add_page_number(paragraph):
    paragraph.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    run = paragraph.add_run("Trang ")
    run.font.size = Pt(9)
    run.font.color.rgb = RGBColor.from_string(MUTED)
    fld_char1 = OxmlElement("w:fldChar")
    fld_char1.set(qn("w:fldCharType"), "begin")
    instr_text = OxmlElement("w:instrText")
    instr_text.set(qn("xml:space"), "preserve")
    instr_text.text = " PAGE "
    fld_char2 = OxmlElement("w:fldChar")
    fld_char2.set(qn("w:fldCharType"), "end")
    run._r.append(fld_char1)
    run._r.append(instr_text)
    run._r.append(fld_char2)


def style_run(run, *, size=None, bold=None, color=None, font="Calibri", italic=None):
    run.font.name = font
    run._element.rPr.rFonts.set(qn("w:eastAsia"), font)
    if size is not None:
        run.font.size = Pt(size)
    if bold is not None:
        run.bold = bold
    if color:
        run.font.color.rgb = RGBColor.from_string(color)
    if italic is not None:
        run.italic = italic


def add_text(paragraph, text, *, bold=False, color=DARK, size=11, italic=False):
    run = paragraph.add_run(text)
    style_run(run, size=size, bold=bold, color=color, italic=italic)
    return run


def set_paragraph_spacing(paragraph, before=0, after=6, line=1.10):
    fmt = paragraph.paragraph_format
    fmt.space_before = Pt(before)
    fmt.space_after = Pt(after)
    fmt.line_spacing = line


def add_body(doc, text="", *, bold_prefix=None, after=6, align=WD_ALIGN_PARAGRAPH.LEFT):
    p = doc.add_paragraph()
    p.alignment = align
    set_paragraph_spacing(p, after=after)
    if bold_prefix and text.startswith(bold_prefix):
        add_text(p, bold_prefix, bold=True)
        add_text(p, text[len(bold_prefix):])
    else:
        add_text(p, text)
    return p


def add_bullet(doc, text, level=0):
    style = "List Bullet" if level == 0 else "List Bullet 2"
    p = doc.add_paragraph(style=style)
    add_text(p, text)
    p.paragraph_format.left_indent = Inches(0.5 if level == 0 else 0.75)
    p.paragraph_format.first_line_indent = Inches(-0.25)
    set_paragraph_spacing(p, after=8, line=1.167)
    return p


def add_heading(doc, text, level=1):
    p = doc.add_heading(text, level=level)
    set_repeat_on_each_page(p)
    return p


def add_status_callout(doc, title, lines):
    table = doc.add_table(rows=1, cols=1)
    table.style = "Table Grid"
    set_table_geometry(table, [TABLE_WIDTH_DXA])
    cell = table.cell(0, 0)
    set_cell_shading(cell, PALE_GREEN)
    p = cell.paragraphs[0]
    set_paragraph_spacing(p, after=4)
    add_text(p, title, bold=True, color=GREEN, size=12)
    for line in lines:
        bp = cell.add_paragraph(style="List Bullet")
        bp.paragraph_format.left_indent = Inches(0.38)
        bp.paragraph_format.first_line_indent = Inches(-0.2)
        set_paragraph_spacing(bp, after=4, line=1.05)
        add_text(bp, line, size=10.5)
    doc.add_paragraph().paragraph_format.space_after = Pt(0)


def add_key_value_table(doc, rows):
    table = doc.add_table(rows=len(rows), cols=2)
    table.style = "Table Grid"
    set_table_geometry(table, [2700, 6660])
    for idx, (label, value) in enumerate(rows):
        set_cell_shading(table.cell(idx, 0), LIGHT)
        p0 = table.cell(idx, 0).paragraphs[0]
        p1 = table.cell(idx, 1).paragraphs[0]
        set_paragraph_spacing(p0, after=0)
        set_paragraph_spacing(p1, after=0)
        add_text(p0, label, bold=True, color=DARK_BLUE, size=10)
        add_text(p1, value, size=10)
    return table


def add_matrix_table(doc, headers, rows, widths, header_fill=BLUE):
    table = doc.add_table(rows=1, cols=len(headers))
    table.style = "Table Grid"
    set_table_geometry(table, widths)
    repeat_table_header(table.rows[0])
    for idx, header in enumerate(headers):
        set_cell_shading(table.cell(0, idx), header_fill)
        p = table.cell(0, idx).paragraphs[0]
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        set_paragraph_spacing(p, after=0)
        add_text(p, header, bold=True, color=WHITE, size=9.5)
    for row in rows:
        cells = table.add_row().cells
        for idx, value in enumerate(row):
            set_cell_width(cells[idx], widths[idx])
            set_cell_margins(cells[idx])
            cells[idx].vertical_alignment = WD_CELL_VERTICAL_ALIGNMENT.CENTER
            p = cells[idx].paragraphs[0]
            p.alignment = WD_ALIGN_PARAGRAPH.CENTER if idx == 1 and len(headers) > 2 else WD_ALIGN_PARAGRAPH.LEFT
            set_paragraph_spacing(p, after=0)
            color = GREEN if str(value).startswith("ĐẠT") else DARK
            add_text(p, str(value), bold=str(value).startswith("ĐẠT"), color=color, size=9.3)
    return table


def add_header_footer(section, first_page=False):
    section.different_first_page_header_footer = first_page
    header = section.header
    hp = header.paragraphs[0]
    hp.alignment = WD_ALIGN_PARAGRAPH.LEFT
    if LOGO_PATH.exists():
        hp.add_run().add_picture(str(LOGO_PATH), width=Cm(1.7))
    add_text(hp, "   ALOO — HỒ SƠ NGHIỆM THU & BÀN GIAO", bold=True, color=DARK_BLUE, size=9)
    hp.paragraph_format.space_after = Pt(0)

    footer = section.footer
    fp = footer.paragraphs[0]
    add_page_number(fp)
    border_p = OxmlElement("w:pBdr")
    bottom = OxmlElement("w:top")
    bottom.set(qn("w:val"), "single")
    bottom.set(qn("w:sz"), "4")
    bottom.set(qn("w:space"), "4")
    bottom.set(qn("w:color"), "D9DEE3")
    border_p.append(bottom)
    fp._p.get_or_add_pPr().append(border_p)


doc = Document()
section = doc.sections[0]
section.page_width = Cm(21)
section.page_height = Cm(29.7)
section.top_margin = Cm(1.8)
section.bottom_margin = Cm(1.7)
section.left_margin = Cm(2.245)
section.right_margin = Cm(2.245)
section.header_distance = Cm(0.7)
section.footer_distance = Cm(0.7)
add_header_footer(section, first_page=True)

styles = doc.styles
normal = styles["Normal"]
normal.font.name = "Calibri"
normal._element.rPr.rFonts.set(qn("w:eastAsia"), "Calibri")
normal.font.size = Pt(11)
normal.font.color.rgb = RGBColor.from_string(DARK)
normal.paragraph_format.space_after = Pt(6)
normal.paragraph_format.line_spacing = 1.10

heading_specs = {
    "Heading 1": (16, BLUE, 16, 8),
    "Heading 2": (13, BLUE, 12, 6),
    "Heading 3": (12, DARK_BLUE, 8, 4),
}
for name, (size, color, before, after) in heading_specs.items():
    style = styles[name]
    style.font.name = "Calibri"
    style._element.rPr.rFonts.set(qn("w:eastAsia"), "Calibri")
    style.font.size = Pt(size)
    style.font.bold = True
    style.font.color.rgb = RGBColor.from_string(color)
    style.paragraph_format.space_before = Pt(before)
    style.paragraph_format.space_after = Pt(after)
    style.paragraph_format.keep_with_next = True

for style_name in ("List Bullet", "List Bullet 2"):
    style = styles[style_name]
    style.font.name = "Calibri"
    style._element.rPr.rFonts.set(qn("w:eastAsia"), "Calibri")
    style.font.size = Pt(11)

props = doc.core_properties
props.title = "Biên bản nghiệm thu và bàn giao ALOO — 29/07/2026"
props.subject = "Nghiệm thu kỹ thuật local và bàn giao website ALOO Corporate Website & Franchise CMS"
props.author = "Huỳnh Đoàn Trung Hiếu"
props.keywords = "ALOO, nghiệm thu, bàn giao, PostgreSQL, website, CMS"

# Cover
p = doc.add_paragraph()
p.alignment = WD_ALIGN_PARAGRAPH.CENTER
p.paragraph_format.space_before = Pt(44)
if LOGO_PATH.exists():
    p.add_run().add_picture(str(LOGO_PATH), width=Cm(5.2))

p = doc.add_paragraph()
p.alignment = WD_ALIGN_PARAGRAPH.CENTER
p.paragraph_format.space_before = Pt(28)
p.paragraph_format.space_after = Pt(8)
add_text(p, "BIÊN BẢN NGHIỆM THU\nVÀ BÀN GIAO WEBSITE", bold=True, color=DARK_BLUE, size=24)

p = doc.add_paragraph()
p.alignment = WD_ALIGN_PARAGRAPH.CENTER
p.paragraph_format.space_after = Pt(28)
add_text(p, "ALOO Corporate Website & Franchise CMS", bold=True, color=GREEN, size=15)

cover_table = doc.add_table(rows=5, cols=2)
cover_table.style = "Table Grid"
set_table_geometry(cover_table, [2800, 6560])
cover_rows = [
    ("Ngày nghiệm thu", "29/07/2026"),
    ("Môi trường", "Local — Vue/Vite :5173 · Spring Boot :8080 · PostgreSQL 17.10"),
    ("Người bàn giao", "Huỳnh Đoàn Trung Hiếu"),
    ("Đại diện bên nhận", "____________________________________________"),
    ("Phiên bản tài liệu", "1.0 — Phát hành để ký nghiệm thu"),
]
for idx, (label, value) in enumerate(cover_rows):
    set_cell_shading(cover_table.cell(idx, 0), LIGHT)
    add_text(cover_table.cell(idx, 0).paragraphs[0], label, bold=True, color=DARK_BLUE, size=10)
    add_text(cover_table.cell(idx, 1).paragraphs[0], value, size=10)
    for cell in cover_table.rows[idx].cells:
        set_paragraph_spacing(cell.paragraphs[0], after=0)

p = doc.add_paragraph()
p.alignment = WD_ALIGN_PARAGRAPH.CENTER
p.paragraph_format.space_before = Pt(34)
add_text(p, "Tài liệu kiểm soát — không ghi credential thật trong biên bản", italic=True, color=MUTED, size=9.5)

doc.add_page_break()

# Page 2
add_heading(doc, "1. Thông tin và mục đích nghiệm thu", 1)
add_key_value_table(
    doc,
    [
        ("Tên dự án", "ALOO Corporate Website & Franchise CMS"),
        ("Ngày nghiệm thu", "29/07/2026"),
        ("Phạm vi xác minh", "Mã nguồn, chức năng local, PostgreSQL, dữ liệu CMS, ảnh, kiểm thử tự động và tài liệu vận hành"),
        ("Snapshot Git", "Branch agent/aloo-cms-handover-update · commit nền adf37d4 · working tree còn thay đổi chưa commit"),
        ("Kết luận phạm vi", "Đạt nghiệm thu kỹ thuật local; production cần biên bản xác minh riêng sau triển khai"),
    ],
)
add_body(
    doc,
    "Biên bản này xác nhận tình trạng kỹ thuật và các hạng mục được chuyển giao tại thời điểm nghiệm thu. "
    "Credential thật, khóa API, mật khẩu và quyền sở hữu dịch vụ phải được chuyển qua password manager hoặc kênh bí mật riêng.",
    after=8,
)
add_status_callout(
    doc,
    "KẾT LUẬN TÓM TẮT: ĐẠT TRÊN MÔI TRƯỜNG LOCAL",
    [
        "Frontend 87/87 test đạt; backend 40/40 test đạt; production build thành công.",
        "PostgreSQL 17.10 hoạt động, Flyway xác nhận 8 migration thành công.",
        "API home-sections trả HTTP 200; trình duyệt không còn ảnh tải lỗi hoặc lỗi console liên quan.",
        "Các cấu hình production chưa có bằng chứng trên môi trường đích được tách thành điều kiện trước go-live.",
    ],
)

add_heading(doc, "2. Thành phần hệ thống", 1)
add_matrix_table(
    doc,
    ["Tầng", "Công nghệ", "Vai trò"],
    [
        ("Frontend", "Vue 3.5 · Vite 8 · Pinia · Router · Tailwind", "Website công khai, tài khoản và CMS quản trị"),
        ("Backend", "Java 21 · Spring Boot 3.3.5 · Maven", "REST API, JWT/RBAC, nghiệp vụ và WebSocket"),
        ("Dữ liệu", "PostgreSQL 17.10 · JPA · Flyway", "Dữ liệu CMS/CRM và quản lý schema"),
        ("Lưu trữ ảnh", "Filesystem qua UPLOAD_DIR", "Ảnh upload được phục vụ tại /uploads/**"),
        ("Tích hợp", "Google OAuth · SMTP · Redis (tùy chọn)", "Đăng nhập, email và rate limiting"),
    ],
    [1550, 3400, 4410],
)

doc.add_page_break()

# Page 3
add_heading(doc, "3. Phạm vi chức năng bàn giao", 1)
add_heading(doc, "3.1. Website công khai và tài khoản", 2)
for item in [
    "Trang chủ, giới thiệu thương hiệu, sản phẩm/menu, cửa hàng, nhượng quyền, blog, liên hệ và đăng ký tư vấn.",
    "Đăng nhập local/Google OAuth callback, hồ sơ người dùng, avatar và đổi mật khẩu/OTP.",
    "Đánh giá sản phẩm, tìm kiếm/lọc nội dung, chia sẻ bài viết và hiển thị đa ngôn ngữ VI/EN.",
    "Live chat gần thời gian thực bằng REST và STOMP/WebSocket.",
]:
    add_bullet(doc, item)

add_heading(doc, "3.2. CMS quản trị", 2)
add_matrix_table(
    doc,
    ["Nhóm", "Module bàn giao"],
    [
        ("Content", "Home Sections, Brand Timeline, Products/Menu, Franchise Content, Articles/SEO"),
        ("Stores", "Cửa hàng, gallery, giờ mở cửa, tiện ích và menu poster"),
        ("CRM", "Feedback, Product Reviews, Leads, Contact Messages và Live Chat"),
        ("System", "Accounts, phân quyền FULL/CONTENT/STORES/CRM/SYSTEM và Audit Logs"),
        ("Profile/Upload", "Hồ sơ quản trị, avatar, bảo mật và upload ảnh có kiểm soát"),
    ],
    [1900, 7460],
)

add_heading(doc, "3.3. Hạng mục vật lý/số được chuyển giao", 2)
for item in [
    "Mã nguồn frontend và backend, cấu hình mẫu không chứa secret, test tự động và lịch sử Git.",
    "Database PostgreSQL aloo_cms, 8 migration Flyway và dữ liệu CMS hiện hành.",
    "Kho ảnh uploads/ cùng tài nguyên tĩnh frontend/public/.",
    "Postman collection, hướng dẫn cài đặt/vận hành, checklist, known issues và bằng chứng kiểm thử.",
    "DOCX/PDF biên bản ký nghiệm thu ngày 29/07/2026.",
]:
    add_bullet(doc, item)

doc.add_page_break()

# Page 4
add_heading(doc, "4. Hiện trạng dữ liệu và nội dung", 1)
add_matrix_table(
    doc,
    ["Nhóm dữ liệu", "Số lượng", "Trạng thái xác minh"],
    [
        ("Sản phẩm", "69", "ĐẠT — API truy xuất thành công"),
        ("Bài blog", "20", "ĐẠT — 20/20 ở trạng thái PUBLISHED"),
        ("Cửa hàng", "5", "ĐẠT — API truy xuất thành công"),
        ("Tài khoản", "6", "ĐẠT — dữ liệu hiện có trong PostgreSQL"),
        ("Nội dung nhượng quyền", "24", "ĐẠT — dữ liệu hiện có trong PostgreSQL"),
        ("Home section", "3", "ĐẠT — API HTTP 200, đủ 3 section"),
        ("Flyway migration", "8", "ĐẠT — validate và migrate thành công"),
        ("Kho ảnh cấp dự án", "110 tệp", "ĐẠT local — phục vụ qua /uploads/**"),
    ],
    [3100, 1400, 4860],
)

add_heading(doc, "5. Kết quả kiểm thử nghiệm thu", 1)
add_matrix_table(
    doc,
    ["Hạng mục", "Kết quả", "Chi tiết"],
    [
        ("Frontend unit test", "ĐẠT", "27 test file · 87/87 test"),
        ("Frontend production build", "ĐẠT", "Vite 8.0.12 · 1.981 module"),
        ("Backend Maven test", "ĐẠT", "13 suite · 40/40 test · 0 lỗi · 0 bỏ qua"),
        ("PostgreSQL/Flyway", "ĐẠT", "PostgreSQL 17.10 · 8 migration"),
        ("API nội dung chính", "ĐẠT", "home-sections, products, posts, stores"),
        ("Ảnh trang chủ", "ĐẠT", "16 ảnh · 0 ảnh hoàn tất nhưng kích thước 0 · 0 lỗi console liên quan"),
    ],
    [2850, 1300, 5210],
)
add_body(
    doc,
    "Ghi chú hiệu năng: bundle JavaScript chính 1,488.91 kB (gzip 432.56 kB) và có cảnh báo vượt 500 kB. "
    "Cảnh báo này không làm build thất bại nhưng cần được theo dõi trong kế hoạch tối ưu.",
    after=0,
)

doc.add_page_break()

# Page 5
add_heading(doc, "6. Sự cố đã khắc phục trong ngày nghiệm thu", 1)
add_matrix_table(
    doc,
    ["Sự cố", "Nguyên nhân", "Xử lý và xác minh"],
    [
        (
            "GET /api/home-sections trả 400",
            "HomeSection.description còn @Lob; Hibernate đọc PostgreSQL text như Large Object OID.",
            "Gỡ @Lob, giữ columnDefinition=text, thêm kiểm thử hồi quy; API trả HTTP 200.",
        ),
        (
            "Ảnh /uploads trả 404",
            "Backend chạy trong backend/ trong khi 110 ảnh nằm ở uploads/ cấp dự án.",
            "Local dùng UPLOAD_DIR=../uploads; URL ảnh trả HTTP 200; kiểm tra trình duyệt không còn ảnh lỗi.",
        ),
    ],
    [2400, 3300, 3660],
)

add_heading(doc, "7. Hướng dẫn vận hành rút gọn", 1)
add_heading(doc, "7.1. Backend và PostgreSQL", 2)
for item in [
    "Cấu hình DB_URL=jdbc:postgresql://<host>:5432/aloo_cms, DB_USERNAME, DB_PASSWORD và JWT_SECRET.",
    "Khi chạy local từ backend/, đặt UPLOAD_DIR=../uploads; production dùng đường dẫn volume tuyệt đối/bền vững.",
    "Chạy: cd backend; mvn spring-boot:run -Dspring-boot.run.profiles=local.",
    "Flyway là nguồn quản lý schema; không sửa migration đã áp dụng.",
]:
    add_bullet(doc, item)

add_heading(doc, "7.2. Frontend và kiểm tra", 2)
for item in [
    "Chạy: cd frontend; npm install; npm run dev.",
    "Kiểm thử: npm test -- --run; npm run build; tại backend chạy mvn test.",
    "Kiểm tra API: /api/home-sections?activeOnly=true, /api/products, /api/posts và /api/stores.",
]:
    add_bullet(doc, item)

doc.add_page_break()

# Page 6
add_heading(doc, "8. Điều kiện trước go-live và trách nhiệm tiếp nhận", 1)
add_matrix_table(
    doc,
    ["Mục", "Trạng thái", "Hành động bắt buộc"],
    [
        ("Snapshot Git cuối", "Chưa hoàn tất", "Review diff, commit có chủ đích, push và ghi SHA cuối vào biên bản."),
        ("Credential production", "Chưa bàn giao trong file", "Chuyển qua password manager/kênh bí mật; kiểm tra quyền sở hữu."),
        ("Backup/restore", "Chưa có bằng chứng production", "Backup PostgreSQL và volume ảnh; thử phục hồi trước go-live."),
        ("Domain/HTTPS/proxy", "Chưa xác minh", "Cấu hình TLS, CORS, WebSocket và timeout trên domain thật."),
        ("OAuth/SMTP/Redis", "Chưa xác minh", "Kiểm tra redirect URI, whitelist, gửi mail và rate limiting."),
        ("Tài khoản demo", "Còn dùng local", "Đổi/vô hiệu hóa trước khi môi trường có internet."),
        ("Media", "Cần rà soát", "Xác nhận quyền thương mại và metadata ảnh AI."),
        ("Đa trình duyệt", "Chưa đủ bằng chứng", "Smoke test Chrome, Edge và thiết bị di động thật."),
    ],
    [2400, 2100, 4860],
)

add_heading(doc, "9. Kiểm soát bàn giao", 1)
for item in [
    "Bên nhận kiểm tra đủ mã nguồn, dữ liệu, kho ảnh và tài liệu trước khi ký.",
    "Hai bên thống nhất người sở hữu repository, domain, hosting, database, email và tài khoản tích hợp.",
    "Mọi thay đổi sau thời điểm ký cần có issue/change request hoặc biên bản bổ sung.",
    "SQL Server cũ chỉ giữ làm nguồn đối chiếu/rollback đến khi backup PostgreSQL và phục hồi thử được xác nhận.",
]:
    add_bullet(doc, item)

add_status_callout(
    doc,
    "PHẠM VI KHÔNG ĐƯỢC HIỂU LÀ ĐÃ NGHIỆM THU",
    [
        "Các cấu hình và tích hợp production chưa có bằng chứng trên môi trường đích.",
        "Hiệu năng tải thực tế, SLA, chống chịu tải và bảo mật xâm nhập chuyên sâu.",
        "Quyền sở hữu dịch vụ/credential nếu chưa được đại diện bên nhận xác nhận bằng kênh riêng.",
    ],
)

doc.add_page_break()

# Page 7
add_heading(doc, "10. Kết luận và xác nhận", 1)
add_body(
    doc,
    "Hai bên xác nhận hệ thống đạt nghiệm thu kỹ thuật trên môi trường local ngày 29/07/2026 đối với phạm vi, "
    "dữ liệu và kết quả kiểm thử nêu trong biên bản. Các hạng mục production chưa có bằng chứng được ghi nhận là "
    "điều kiện trước go-live và cần xác minh riêng trên môi trường đích.",
    after=10,
)

add_heading(doc, "10.1. Lựa chọn xác nhận", 2)
for option in [
    "☐ Đồng ý nghiệm thu và nhận bàn giao theo hiện trạng nêu trên.",
    "☐ Đồng ý có điều kiện. Nội dung bổ sung: _________________________________________________",
    "☐ Chưa đồng ý. Lý do: _________________________________________________________________",
]:
    p = doc.add_paragraph()
    set_paragraph_spacing(p, after=9)
    add_text(p, option, size=11)

add_heading(doc, "10.2. Ý kiến bổ sung", 2)
for _ in range(4):
    p = doc.add_paragraph("________________________________________________________________________________")
    set_paragraph_spacing(p, after=8)
    for run in p.runs:
        style_run(run, color="7C878D", size=10)

add_heading(doc, "10.3. Chữ ký", 2)
sig = doc.add_table(rows=1, cols=2)
sig.style = "Table Grid"
set_table_geometry(sig, [4680, 4680])
for idx, title in enumerate(("BÊN BÀN GIAO", "BÊN NHẬN BÀN GIAO")):
    cell = sig.cell(0, idx)
    set_cell_shading(cell, LIGHT)
    p = cell.paragraphs[0]
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    set_paragraph_spacing(p, after=8)
    add_text(p, title, bold=True, color=DARK_BLUE, size=11)
    lines = [
        "Họ tên: Huỳnh Đoàn Trung Hiếu" if idx == 0 else "Họ tên: ______________________________",
        "Chức vụ: ___________________________",
        "",
        "",
        "",
        "Ký, ghi rõ họ tên",
        "Ngày: ____/____/2026",
    ]
    for line in lines:
        lp = cell.add_paragraph()
        lp.alignment = WD_ALIGN_PARAGRAPH.CENTER
        set_paragraph_spacing(lp, after=6)
        add_text(lp, line or " ", size=10)

add_body(
    doc,
    "Tài liệu tham chiếu: handover/INSTALLATION.md · handover/CHECKLIST.md · "
    "handover/KNOWN-ISSUES.md · handover/evidence/VERIFIED-RESULTS.md",
    after=0,
    align=WD_ALIGN_PARAGRAPH.CENTER,
)
last_p = doc.paragraphs[-1]
for run in last_p.runs:
    style_run(run, color=MUTED, size=8.5, italic=True)

doc.save(DOCX_PATH)
print(DOCX_PATH)
