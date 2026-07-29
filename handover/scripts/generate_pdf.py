from __future__ import annotations

from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (
    Flowable, Image, KeepTogether, PageBreak, Paragraph, SimpleDocTemplate,
    Spacer, Table, TableStyle,
)


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "output" / "ALOO-Tai-lieu-ban-giao.pdf"
REPO = ROOT.parent

GREEN = colors.HexColor("#1D4D35")
LIGHT_GREEN = colors.HexColor("#EAF4EE")
RED = colors.HexColor("#D9292A")
GOLD = colors.HexColor("#E0A12B")
INK = colors.HexColor("#1F2933")
MUTED = colors.HexColor("#607080")
LINE = colors.HexColor("#D9E2DF")


def register_fonts():
    candidates = [
        ("Arial", r"C:\Windows\Fonts\arial.ttf", r"C:\Windows\Fonts\arialbd.ttf", r"C:\Windows\Fonts\ariali.ttf"),
        ("DejaVu", "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", "/usr/share/fonts/truetype/dejavu/DejaVuSans-Oblique.ttf"),
    ]
    for family, regular, bold, italic in candidates:
        if Path(regular).exists() and Path(bold).exists():
            pdfmetrics.registerFont(TTFont(family, regular))
            pdfmetrics.registerFont(TTFont(f"{family}-Bold", bold))
            if Path(italic).exists():
                pdfmetrics.registerFont(TTFont(f"{family}-Italic", italic))
            pdfmetrics.registerFontFamily(family, normal=family, bold=f"{family}-Bold", italic=f"{family}-Italic" if Path(italic).exists() else family)
            return family
    return "Helvetica"


FONT = register_fonts()
FONT_BOLD = f"{FONT}-Bold" if FONT != "Helvetica" else "Helvetica-Bold"


styles = getSampleStyleSheet()
TITLE = ParagraphStyle("TitleVN", parent=styles["Title"], fontName=FONT_BOLD, fontSize=24, leading=29, textColor=GREEN, alignment=TA_CENTER, spaceAfter=8)
SUBTITLE = ParagraphStyle("SubtitleVN", parent=styles["Normal"], fontName=FONT, fontSize=11, leading=16, textColor=MUTED, alignment=TA_CENTER)
H1 = ParagraphStyle("H1VN", parent=styles["Heading1"], fontName=FONT_BOLD, fontSize=16, leading=20, textColor=GREEN, spaceBefore=8, spaceAfter=8, keepWithNext=True)
H2 = ParagraphStyle("H2VN", parent=styles["Heading2"], fontName=FONT_BOLD, fontSize=12.5, leading=16, textColor=RED, spaceBefore=7, spaceAfter=5, keepWithNext=True)
BODY = ParagraphStyle("BodyVN", parent=styles["BodyText"], fontName=FONT, fontSize=9.3, leading=13.2, textColor=INK, spaceAfter=5)
SMALL = ParagraphStyle("SmallVN", parent=BODY, fontSize=8, leading=10.5, textColor=MUTED)
BULLET = ParagraphStyle("BulletVN", parent=BODY, leftIndent=12, firstLineIndent=-7, bulletIndent=3, spaceAfter=3)
CELL = ParagraphStyle("CellVN", parent=BODY, fontSize=7.7, leading=10, spaceAfter=0)
CELL_BOLD = ParagraphStyle("CellBoldVN", parent=CELL, fontName=FONT_BOLD, textColor=colors.white)
CALLOUT = ParagraphStyle("CalloutVN", parent=BODY, fontName=FONT_BOLD, fontSize=10, leading=14, textColor=GREEN, leftIndent=8, rightIndent=8, spaceAfter=0)


def p(text, style=BODY):
    return Paragraph(text, style)


def bullet(text):
    return Paragraph("• " + text, BULLET)


def table(headers, rows, widths=None, repeat=1):
    data = [[p(h, CELL_BOLD) for h in headers]] + [[p(str(v), CELL) for v in row] for row in rows]
    t = Table(data, colWidths=widths, repeatRows=repeat, hAlign="LEFT", splitByRow=1)
    t.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), GREEN),
        ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
        ("GRID", (0, 0), (-1, -1), 0.35, LINE),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("LEFTPADDING", (0, 0), (-1, -1), 5),
        ("RIGHTPADDING", (0, 0), (-1, -1), 5),
        ("TOPPADDING", (0, 0), (-1, -1), 4),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
        ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, colors.HexColor("#F7FAF8")]),
    ]))
    return t


class ArchitectureFlow(Flowable):
    def __init__(self, width=170*mm, height=45*mm):
        super().__init__()
        self.width, self.height = width, height

    def draw(self):
        c = self.canv
        boxes = [
            (0, 21, 28, 14, "User / Admin", LIGHT_GREEN),
            (36, 21, 28, 14, "Vue 3 UI", colors.HexColor("#E8F0FE")),
            (72, 21, 31, 14, "Spring Security\n+ Controller", colors.HexColor("#FFF2E5")),
            (111, 21, 25, 14, "Service", colors.HexColor("#FFF7D6")),
            (144, 21, 26, 14, "SQL Server", colors.HexColor("#EEE9FA")),
            (72, 0, 31, 12, "WebSocket\nLive Chat", colors.HexColor("#FCEBEC")),
            (111, 0, 59, 12, "OAuth / SMTP / Redis / Upload", colors.HexColor("#F3F4F6")),
        ]
        for x, y, w, h, label, fill in boxes:
            c.setFillColor(fill); c.setStrokeColor(GREEN); c.setLineWidth(0.8)
            c.roundRect(x*mm, y*mm, w*mm, h*mm, 2*mm, fill=1, stroke=1)
            c.setFillColor(INK); c.setFont(FONT_BOLD, 7.5)
            lines = label.split("\n")
            for i, line in enumerate(lines):
                c.drawCentredString((x+w/2)*mm, (y+h/2+1.5-i*3.2)*mm, line)
        c.setStrokeColor(GREEN); c.setFillColor(GREEN)
        for x1, x2 in [(28, 36), (64, 72), (103, 111), (136, 144)]:
            y = 28*mm; c.line(x1*mm, y, (x2-1.5)*mm, y)
            c.line((x2-1.5)*mm, y, (x2-3)*mm, y+1.2*mm); c.line((x2-1.5)*mm, y, (x2-3)*mm, y-1.2*mm)
        c.line(87.5*mm, 21*mm, 87.5*mm, 12*mm)
        c.line(126*mm, 21*mm, 126*mm, 12*mm)


def header_footer(canvas, doc):
    canvas.saveState()
    canvas.setStrokeColor(LINE); canvas.setLineWidth(0.5)
    canvas.line(20*mm, 18*mm, 190*mm, 18*mm)
    canvas.setFont(FONT, 7.5); canvas.setFillColor(MUTED)
    canvas.drawString(20*mm, 11*mm, "ALOO Corporate Website & Franchise CMS — Tài liệu bàn giao 24/07/2026")
    canvas.drawRightString(190*mm, 11*mm, f"Trang {doc.page}")
    canvas.restoreState()


def add_section(story, title, paragraphs=(), bullets=()):
    story.append(p(title, H1))
    for text in paragraphs: story.append(p(text))
    for text in bullets: story.append(bullet(text))


def build():
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    doc = SimpleDocTemplate(str(OUTPUT), pagesize=A4, rightMargin=20*mm, leftMargin=20*mm, topMargin=18*mm, bottomMargin=24*mm, title="Tài liệu bàn giao ALOO", author="ALOO Project")
    story = []
    logo = REPO / "frontend" / "public" / "logo-aloo.png"
    if logo.exists():
        img = Image(str(logo), width=32*mm, height=32*mm)
        img.hAlign = "CENTER"; story += [Spacer(1, 7*mm), img, Spacer(1, 4*mm)]
    story += [p("TÀI LIỆU BÀN GIAO DỰ ÁN", TITLE), p("ALOO Corporate Website & Franchise CMS", TITLE), Spacer(1, 3*mm), p("Kiến trúc · Tính năng · Cài đặt · Database · API · Nghiệm thu", SUBTITLE), Spacer(1, 8*mm)]
    story.append(Table([[p("PHIÊN BẢN", CELL_BOLD), p("24/07/2026", CELL)], [p("NGUỒN ĐỐI CHIẾU", CELL_BOLD), p("Router frontend, Spring controllers, schema SQL, media source, test và lịch sử Git", CELL)], [p("KẾT QUẢ KIỂM TRA", CELL_BOLD), p("Frontend 84/84 pass · Backend 39/39 pass · Build production pass · Playwright desktop 8/8 pass", CELL)]], colWidths=[42*mm, 116*mm], style=TableStyle([("BACKGROUND",(0,0),(0,-1),GREEN),("GRID",(0,0),(-1,-1),0.4,LINE),("VALIGN",(0,0),(-1,-1),"MIDDLE"),("LEFTPADDING",(0,0),(-1,-1),7),("RIGHTPADDING",(0,0),(-1,-1),7),("TOPPADDING",(0,0),(-1,-1),7),("BOTTOMPADDING",(0,0),(-1,-1),7)])))
    story += [Spacer(1, 9*mm), Table([[p("Mục tiêu", CALLOUT)]], colWidths=[158*mm], style=TableStyle([("BACKGROUND",(0,0),(-1,-1),LIGHT_GREEN),("BOX",(0,0),(-1,-1),1,GREEN),("LEFTPADDING",(0,0),(-1,-1),10),("RIGHTPADDING",(0,0),(-1,-1),10),("TOPPADDING",(0,0),(-1,-1),8),("BOTTOMPADDING",(0,0),(-1,-1),8)])), p("Giúp người nhận hiểu hệ thống, dựng môi trường, import dữ liệu, kiểm thử API và tiếp tục bảo trì mà không phụ thuộc vào trao đổi miệng.", BODY), PageBreak()]

    add_section(story, "1. Kiến trúc và luồng hoạt động", ["Hệ thống gồm Vue SPA, Spring Boot REST API, SQL Server và kênh WebSocket cho live chat. JWT xác thực cả user/admin; admin được giới hạn theo scope."])
    story += [Spacer(1, 3*mm), ArchitectureFlow(), Spacer(1, 3*mm)]
    for text in ["1) Người dùng thao tác trên Vue; Axios gửi REST JSON tới backend.", "2) Spring Security xác thực JWT, role và admin scope trước khi controller xử lý.", "3) Service thực thi nghiệp vụ; JPA repository đọc/ghi SQL Server; Flyway quản lý migration.", "4) Backend trả JSON; frontend cập nhật Pinia/UI. Live chat dùng STOMP/WebSocket để đẩy tin nhắn.", "5) Google OAuth, SMTP và Redis là tích hợp tùy chọn; upload mặc định lưu filesystem."]:
        story.append(bullet(text))
    story += [p("2. Công nghệ", H1), table(["Tầng", "Công nghệ"], [("Frontend", "Vue 3.5, Vite 8, Router 5, Pinia 3, Tailwind 4, Axios, Tiptap; cleanup cache PWA cũ"), ("Backend", "Java 21, Spring Boot 3.3.5, Maven, Security, JWT, WebSocket"), ("Data", "SQL Server, JPA/Hibernate, Flyway; H2 cho test"), ("Tích hợp", "Google OAuth2, SMTP, Redis rate limit, local upload"), ("Kiểm thử", "Vitest, Vue Test Utils, Playwright, JUnit/Spring Test")], [39*mm, 119*mm]), PageBreak()]

    story.append(p("3. Danh sách tính năng — Public/User", H1))
    public_rows = [
        ("Website", "Trang chủ, gallery media thương hiệu, VI/EN, responsive, 404", "/, /about"),
        ("Sản phẩm", "Danh sách/danh mục, hero mới, menu poster, chi tiết/review", "/products"),
        ("Cửa hàng", "Tìm/lọc; chi tiết có gallery và menu poster", "/locations"),
        ("Nhượng quyền", "Nội dung/quy trình/chi phí và form lead", "/franchise, /consultation"),
        ("Blog", "Mục lục, thời gian đọc, chia sẻ/in, bài liên quan", "/blog"),
        ("Liên hệ", "Gửi contact message", "/contact"),
        ("Live chat", "Tạo/gắn phiên, gửi nhận realtime", "Chat widget"),
        ("Tài khoản", "Login local/Google, profile/avatar, password/OTP", "/login, /account"),
    ]
    story += [table(["Nhóm", "Tính năng", "Route"], public_rows, [31*mm, 88*mm, 39*mm]), Spacer(1, 6*mm), p("4. Danh sách tính năng — Admin CMS", H1)]
    admin_rows = [
        ("Dashboard", "KPI và truy cập nhanh"), ("Content", "Home/timeline/products/franchise/articles/categories; CRUD menu poster + upload"),
        ("Stores", "CRUD cửa hàng, gallery, giờ mở cửa, tiện ích, poster"),
        ("CRM", "Feedback, product review, franchise lead, contact message, live chat"),
        ("System", "Accounts, nâng/hạ role, trạng thái, password, audit logs"),
        ("Profile", "Hồ sơ, avatar, bảo mật, OTP/đổi mật khẩu"),
        ("Security", "FULL/CONTENT/STORES/CRM/SYSTEM scopes; JWT; rate limit"),
        ("Admin UX", "Tìm kiếm, lọc và phân trang mở rộng trên các danh sách CMS/CRM"),
    ]
    story += [table(["Scope/module", "Tính năng"], admin_rows, [42*mm, 116*mm]), PageBreak()]

    story.append(p("5. Báo cáo đóng góp cá nhân", H1))
    story.append(p("Lịch sử Git hiện có 28 commit, đều mang tên Trung Hi hoặc Huỳnh Đoàn Trung Hiếu. Git author không tự chứng minh người viết từng dòng; bảng dưới đây được xác nhận theo phạm vi công việc và bằng chứng hiện có trong repo."))
    contribution_rows = [
        ("Public Vue UI + account flow", "Git/router/views/tests", "Trực tiếp phát triển"),
        ("Admin CMS + RBAC UI", "Git/views/components", "Trực tiếp phát triển"),
        ("Spring REST/security/services", "Git/controllers/services/tests", "Trực tiếp phát triển"),
        ("SQL schema/seed/migrations", "Git/SQL", "Phát triển/điều chỉnh"),
        ("Vue/Spring/Tiptap/Axios/Tailwind/JWT", "Dependency manifests", "Framework/thư viện"),
        ("Media trong frontend/public", "Ảnh Drive có SOURCES.md; ảnh AI chưa có metadata", "Xác nhận quyền sử dụng"),
        ("Proposal/báo cáo cũ", "Tệp tài liệu", "Kế thừa/tham khảo"),
    ]
    story += [
        table(["Phạm vi", "Bằng chứng", "Phân loại"], contribution_rows, [57*mm, 55*mm, 46*mm]),
        Spacer(1, 4*mm),
        p("Xác nhận của người bàn giao", H2),
        p("Tôi, <b>Huỳnh Đoàn Trung Hiếu</b>, xác nhận:", BODY),
        bullet("Các phần Public Vue UI, Admin CMS, Spring REST API và database nêu trên là phần tôi trực tiếp phát triển hoặc điều chỉnh trong phạm vi dự án, theo lịch sử Git và mã nguồn hiện có."),
        bullet("Vue, Spring Boot, Tiptap, Axios, Tailwind, JWT và các dependency khác là framework/thư viện có sẵn; tôi không tuyên bố quyền tác giả đối với các thư viện này."),
        bullet("Proposal, báo cáo cũ và các tài nguyên do bên khác cung cấp được phân loại là kế thừa/tham khảo."),
        bullet("Công cụ AI có thể đã được dùng để hỗ trợ rà soát mã, kiểm thử và soạn tài liệu; tôi chịu trách nhiệm kiểm tra, tích hợp và kết quả bàn giao cuối cùng."),
        bullet("Xác nhận này không thay thế giấy phép hoặc bằng chứng quyền sử dụng media. Ba ảnh hero AI vẫn cần bổ sung công cụ/model, prompt, ngày tạo và xác nhận quyền thương mại trước nghiệm thu."),
        p("<b>Ngày xác nhận:</b> 23/07/2026", BODY),
        p("<b>Chữ ký người bàn giao:</b> ______________________________", BODY),
        Spacer(1, 5*mm),
    ]
    story.append(p("6. Database và API", H1))
    for text in ["Schema khởi tạo mới: database/aloo_franchise_cms.sql.", "Dữ liệu demo: database/aloo_franchise_cms_sample_data.sql; tài khoản mẫu đều dùng 123456 và chỉ dành cho local/demo.", "Nâng cấp sau khởi tạo phải dùng Flyway trong backend/src/main/resources/db/migration.", "Postman: api/ALOO-CMS.postman_collection.json; Login tự lưu JWT vào biến token; collection bao phủ toàn bộ REST mappings hiện có."]:
        story.append(bullet(text))
    story += [PageBreak(), p("7. Cài đặt nhanh", H1)]
    setup_rows = [
        ("Yêu cầu", "Node >=22.11, Java 21, Maven 3.9+, SQL Server, Git"),
        ("DB 1", "sqlcmd -S localhost -E -C -i handover/database/aloo_franchise_cms.sql"),
        ("DB 2", "sqlcmd -S localhost -E -C -i handover/database/aloo_franchise_cms_sample_data.sql"),
        ("Backend", "Set DB_*, JWT_SECRET, CORS_*; cd backend; mvn spring-boot:run"),
        ("Frontend", "cd frontend; copy .env.example .env; npm install; npm run dev"),
        ("Test", "npm test; npm run build; mvn test; npm run e2e (khi hai server đang chạy)"),
    ]
    story += [table(["Bước", "Lệnh/nội dung"], setup_rows, [32*mm, 126*mm]), Spacer(1, 5*mm), p("8. Tài khoản test", H1), table(["Vai trò", "Email", "Mật khẩu", "Scope"], [("Admin", "admin@aloo.vn", "123456", "FULL"), ("Admin", "content@aloo.vn", "123456", "CONTENT"), ("User", "user@aloo.vn", "123456", "USER"), ("User", "khachhang@aloo.vn", "123456", "USER")], [30*mm, 62*mm, 31*mm, 35*mm]), p("Không sử dụng các mật khẩu này trên production. Không đưa reset_admin_password.sql vào gói triển khai.", SMALL)]

    story += [Spacer(1, 5*mm), p("9. Dịch vụ và tài nguyên bên thứ ba", H1), table(["Dịch vụ/tài nguyên", "Hiện trạng", "Cách bàn giao"], [("Google OAuth", "Có, tùy chọn", "Invite Google Cloud + secret manager"), ("SMTP", "Có, tùy chọn", "Mailbox/app password qua password manager"), ("Redis", "Có, tùy chọn", "Endpoint/password qua secret manager"), ("SQL Server", "Bắt buộc", "Tách migration/runtime users"), ("Upload", "Local filesystem", "Volume, quyền ghi, backup"), ("Media Google Drive", "Có SOURCES.md", "Xác nhận quyền sử dụng của khách hàng"), ("Ảnh hero AI", "Chưa có metadata", "Bổ sung công cụ/prompt/quyền thương mại"), ("Firebase/AWS/Cloudinary/Payment", "Không thấy SDK", "Không áp dụng theo dependency hiện tại")], [38*mm, 40*mm, 80*mm]), PageBreak()]

    story.append(p("10. Kết quả kiểm thử và tồn đọng", H1))
    story += [table(["Kiểm tra", "Kết quả", "Ghi chú"], [("Frontend Vitest", "84/84 pass", "27 test files"), ("Frontend build", "Pass", "JS ~1.472 MB; gzip 427 kB"), ("Backend Maven", "39/39 pass", "12 suites"), ("Playwright desktop", "8/8 pass", "Chromium + SQL Server demo; log 24/07/2026")], [50*mm, 35*mm, 73*mm]), Spacer(1, 5*mm)]
    for text in ["Tối ưu bundle bằng route lazy-loading/code splitting.", "Service worker hiện chỉ dọn worker/cache PWA cũ; không hỗ trợ offline.", "Playwright desktop đã đạt 8/8 trên SQL Server demo; vẫn cần smoke test đa trình duyệt và production.", "Kiểm chứng OAuth, SMTP, Redis, upload và WebSocket sau reverse proxy production.", "Dọn cảnh báo Redis/JPA repository scanning và H2 dialect trong test.", "Ảnh Drive có bảng nguồn; ảnh hero AI cần metadata và xác nhận quyền.", "Review working tree, commit và push có chủ đích; hiện chưa thể xác nhận code mới nhất đã lên remote."]:
        story.append(bullet(text))

    story += [p("11. Video và nghiệm thu", H1)]
    for text in ["Quay single-take 12–18 phút theo video/KICH-BAN-DEMO.md.", "Bắt buộc chứng minh dữ liệu User tạo xuất hiện trong Admin.", "Không để secret production/token/cửa sổ nhạy cảm xuất hiện.", "Điền repo/branch/SHA, link video và người bàn giao trong CHECKLIST.md.", "Nén thư mục handover sau khi bổ sung video và quyền dịch vụ."]:
        story.append(bullet(text))
    story += [Spacer(1, 8*mm), Table([[p("KẾT LUẬN", CELL_BOLD)], [p("Source hiện có đủ frontend, backend, database, API collection, test và dữ liệu demo để bàn giao kỹ thuật. Xác nhận đóng góp cá nhân đã được bổ sung. Video thật, credential/quyền production, quyền sử dụng media và commit/push cập nhật tài liệu mới nhất vẫn phải được chủ dự án hoàn tất.", BODY)]], colWidths=[158*mm], style=TableStyle([("BACKGROUND",(0,0),(-1,0),GREEN),("BOX",(0,0),(-1,-1),0.8,GREEN),("LEFTPADDING",(0,0),(-1,-1),8),("RIGHTPADDING",(0,0),(-1,-1),8),("TOPPADDING",(0,0),(-1,-1),8),("BOTTOMPADDING",(0,0),(-1,-1),8)]))]
    doc.build(story, onFirstPage=header_footer, onLaterPages=header_footer)
    print(OUTPUT)


if __name__ == "__main__":
    build()
