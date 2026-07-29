from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "api" / "ALOO-CMS.postman_collection.json"


GROUPS = {
    "Auth": [
        ("POST", "/api/auth/login"),
        ("GET", "/oauth2/authorization/google"),
        ("GET", "/api/auth/me"),
        ("PUT", "/api/auth/profile"),
        ("POST", "/api/auth/password-change/request-otp"),
        ("PUT", "/api/auth/change-password"),
        ("POST", "/api/auth/profile/avatar"),
    ],
    "Public - Products and Content": [
        ("GET", "/api/products"), ("GET", "/api/products/slug/{{productSlug}}"),
        ("GET", "/api/products/{{productId}}"),
        ("GET", "/api/products/{{productId}}/reviews"),
        ("GET", "/api/products/{{productId}}/reviews/mine"),
        ("POST", "/api/products/{{productId}}/reviews"),
        ("GET", "/api/posts"), ("GET", "/api/posts/{{postId}}"),
        ("GET", "/api/posts/slug/{{postSlug}}"),
        ("GET", "/api/categories"),
        ("GET", "/api/stores"), ("GET", "/api/stores/featured"),
        ("GET", "/api/stores/{{storeSlug}}"),
        ("GET", "/api/franchise-contents"), ("GET", "/api/home-sections?activeOnly=true"),
        ("GET", "/api/brand-timelines?activeOnly=true"),
        ("GET", "/api/hero-banners"), ("GET", "/api/menu-posters"),
        ("GET", "/api/testimonials"),
    ],
    "Public - CRM and Chat": [
        ("POST", "/api/franchise-registrations"),
        ("POST", "/api/contact-messages"),
        ("POST", "/api/chat/sessions"),
        ("POST", "/api/chat/sessions/account"),
        ("GET", "/api/chat/sessions/mine"),
    ],
    "Admin - Content": [
        ("POST", "/api/products"), ("PUT", "/api/products/{{productId}}"),
        ("DELETE", "/api/products/{{productId}}"),
        ("POST", "/api/posts"), ("PUT", "/api/posts/{{postId}}"),
        ("DELETE", "/api/posts/{{postId}}"),
        ("POST", "/api/categories"), ("PUT", "/api/categories/{{categoryId}}"),
        ("DELETE", "/api/categories/{{categoryId}}"),
        ("GET", "/api/home-sections/{{homeSectionId}}"),
        ("POST", "/api/home-sections"), ("PUT", "/api/home-sections/{{homeSectionId}}"),
        ("DELETE", "/api/home-sections/{{homeSectionId}}"),
        ("GET", "/api/brand-timelines/{{timelineId}}"),
        ("POST", "/api/brand-timelines"), ("PUT", "/api/brand-timelines/{{timelineId}}"),
        ("DELETE", "/api/brand-timelines/{{timelineId}}"),
        ("POST", "/api/franchise-contents"),
        ("PUT", "/api/franchise-contents/{{franchiseContentId}}"),
        ("DELETE", "/api/franchise-contents/{{franchiseContentId}}"),
        ("GET", "/api/hero-banners/{{heroBannerId}}"),
        ("POST", "/api/hero-banners"), ("PUT", "/api/hero-banners/{{heroBannerId}}"),
        ("DELETE", "/api/hero-banners/{{heroBannerId}}"),
        ("GET", "/api/menu-posters/{{menuPosterId}}"),
        ("POST", "/api/menu-posters"), ("PUT", "/api/menu-posters/{{menuPosterId}}"),
        ("DELETE", "/api/menu-posters/{{menuPosterId}}"),
        ("POST", "/api/uploads/images"),
    ],
    "Admin - CRM and Stores": [
        ("GET", "/api/franchise-registrations"),
        ("GET", "/api/franchise-registrations/{{leadId}}"),
        ("PATCH", "/api/franchise-registrations/{{leadId}}/status"),
        ("DELETE", "/api/franchise-registrations/{{leadId}}"),
        ("GET", "/api/contact-messages"), ("GET", "/api/contact-messages/{{contactId}}"),
        ("PATCH", "/api/contact-messages/{{contactId}}/status"),
        ("DELETE", "/api/contact-messages/{{contactId}}"),
        ("GET", "/api/admin/testimonials"), ("GET", "/api/admin/testimonials/{{testimonialId}}"),
        ("POST", "/api/admin/testimonials"), ("PUT", "/api/admin/testimonials/{{testimonialId}}"),
        ("PATCH", "/api/admin/testimonials/{{testimonialId}}/visible"),
        ("DELETE", "/api/admin/testimonials/{{testimonialId}}"),
        ("GET", "/api/admin/product-reviews"),
        ("PATCH", "/api/admin/product-reviews/{{reviewId}}/status"),
        ("DELETE", "/api/admin/product-reviews/{{reviewId}}"),
        ("GET", "/api/admin/stores"), ("POST", "/api/admin/stores"),
        ("PUT", "/api/admin/stores/{{storeId}}"), ("DELETE", "/api/admin/stores/{{storeId}}"),
        ("GET", "/api/admin/chat/sessions"),
        ("GET", "/api/admin/chat/sessions/{{chatSessionId}}"),
        ("PATCH", "/api/admin/chat/sessions/{{chatSessionId}}/status"),
        ("POST", "/api/admin/chat/sessions/{{chatSessionId}}/read"),
    ],
    "Admin - System": [
        ("GET", "/api/accounts"), ("GET", "/api/accounts/admin-email-whitelist"),
        ("GET", "/api/accounts/admins"), ("POST", "/api/accounts/admins"),
        ("PUT", "/api/accounts/admins/{{adminId}}"),
        ("PATCH", "/api/accounts/admins/{{adminId}}/status"),
        ("PUT", "/api/accounts/admins/{{adminId}}/password"),
        ("PATCH", "/api/accounts/admins/{{adminId}}/demote"),
        ("DELETE", "/api/accounts/admins/{{adminId}}"),
        ("GET", "/api/accounts/customers"), ("POST", "/api/accounts/customers"),
        ("PUT", "/api/accounts/customers/{{customerId}}"),
        ("PATCH", "/api/accounts/customers/{{customerId}}/status"),
        ("PUT", "/api/accounts/customers/{{customerId}}/password"),
        ("PATCH", "/api/accounts/customers/{{customerId}}/promote"),
        ("DELETE", "/api/accounts/customers/{{customerId}}"),
        ("GET", "/api/admin/audit-logs"),
    ],
}


def body_for(method: str, path: str):
    if method in {"GET", "DELETE"}:
        return None
    if path.endswith("/login"):
        return {"email": "{{adminEmail}}", "password": "{{adminPassword}}"}
    if path == "/api/auth/profile":
        return {"fullName": "ALOO Demo User", "phone": "0901234567"}
    if "request-otp" in path:
        return {"currentPassword": "{{adminPassword}}"}
    if "change-password" in path:
        return {"currentPassword": "{{adminPassword}}", "newPassword": "StrongPass1!", "otp": ""}
    if path == "/api/franchise-registrations":
        return {"fullName": "Lead Postman", "phone": "0900123456", "email": "lead@example.com", "province": "TP.HCM", "expectedBudget": 300000000, "note": "Cần tư vấn"}
    if path == "/api/contact-messages":
        return {"fullName": "Khách Postman", "phone": "0900111222", "email": "contact@example.com", "subject": "Tư vấn", "message": "Vui lòng liên hệ"}
    if path == "/api/chat/sessions":
        return {"visitorName": "Khách Postman", "visitorPhone": "0900111222"}
    if path.endswith("/reviews"):
        return {"rating": 5, "content": "Sản phẩm ngon và phục vụ tốt."}
    if path.endswith("/status"):
        return {"status": "IN_PROGRESS"}
    if path.endswith("/visible"):
        return {"visible": True}
    if path.endswith("/password"):
        return {"newPassword": "StrongPass1!"}
    if path.endswith("/promote"):
        return {"adminProfile": "CONTENT", "reason": "Phân công quản trị nội dung"}
    if path.endswith("/demote"):
        return {"reason": "Điều chuyển vai trò"}
    if "/accounts/admins" in path:
        return {"email": "new-admin@example.com", "fullName": "New Admin", "phone": "0900000001", "adminProfile": "CONTENT", "password": "StrongPass1!"}
    if "/accounts/customers" in path:
        return {"email": "new-user@example.com", "fullName": "New User", "phone": "0900000002", "password": "StrongPass1!"}
    if "/products" in path:
        return {"name": "Kem bơ Postman", "slug": "kem-bo-postman", "price": 0, "description": "Mẫu API", "status": "ACTIVE", "featured": False, "sortOrder": 99}
    if "/posts" in path:
        return {"title": "Bài viết Postman", "slug": "bai-viet-postman", "excerpt": "Mẫu API", "content": "<p>Nội dung mẫu</p>", "status": "DRAFT"}
    if "/categories" in path:
        return {"name": "Danh mục Postman", "slug": "danh-muc-postman", "type": "ARTICLE", "status": "ACTIVE", "sortOrder": 99, "languageCode": "vi"}
    if "/stores" in path:
        return {"storeCode": "POSTMAN-01", "name": "ALOO Postman", "slug": "aloo-postman", "address": "TP.HCM", "province": "TP.HCM", "storeType": "STANDARD", "status": "ACTIVE", "featured": False, "displayOrder": 99}
    if "testimonials" in path:
        return {"customerName": "Khách hàng Postman", "content": "Trải nghiệm tốt", "rating": 5, "visible": True, "sortOrder": 99}
    if "brand-timelines" in path:
        return {"timelineYear": "2026", "title": "Mốc Postman", "description": "Mẫu API", "sortOrder": 99, "status": "ACTIVE"}
    if "home-sections" in path:
        return {"sectionKey": "postman-section", "type": "CONTENT", "title": "Section Postman", "sortOrder": 99, "status": "ACTIVE"}
    if "franchise-contents" in path:
        return {"sectionKey": "postman-content", "title": "Nội dung Postman", "content": "Mẫu API", "sortOrder": 99, "status": "ACTIVE"}
    if "hero-banners" in path:
        return {"title": "Hero Postman", "tone": "LIGHT", "sortOrder": 99, "status": "ACTIVE"}
    if "menu-posters" in path:
        return {"branchKey": "postman", "title": "Menu Postman", "imageUrl": "/menu-poster.jpg", "sortOrder": 99, "status": "ACTIVE"}
    return {}


def make_request(method: str, path: str):
    clean_path, _, query = path.partition("?")
    raw = "{{baseUrl}}" + clean_path + (("?" + query) if query else "")
    request = {
        "method": method,
        "header": [{"key": "Accept", "value": "application/json"}],
        "url": {"raw": raw, "host": ["{{baseUrl}}"], "path": clean_path.strip("/").split("/")},
    }
    if query:
        request["url"]["query"] = [{"key": pair.split("=", 1)[0], "value": pair.split("=", 1)[1]} for pair in query.split("&")]
    if path == "/api/auth/profile/avatar" or path == "/api/uploads/images":
        request["body"] = {"mode": "formdata", "formdata": [{"key": "file", "type": "file", "src": ""}]}
    else:
        body = body_for(method, clean_path)
        if body is not None:
            request["header"].append({"key": "Content-Type", "value": "application/json"})
            request["body"] = {"mode": "raw", "raw": json.dumps(body, ensure_ascii=False, indent=2), "options": {"raw": {"language": "json"}}}
    item = {"name": f"{method} {clean_path}", "request": request, "response": []}
    if path == "/api/auth/login":
        item["event"] = [{"listen": "test", "script": {"type": "text/javascript", "exec": [
            "const body = pm.response.json();",
            "if (body.token) pm.collectionVariables.set('token', body.token);",
        ]}}]
    return item


def main():
    collection = {
        "info": {
            "_postman_id": "8f0ef2f4-8dcb-4c4f-bc0e-aloo20260722",
            "name": "ALOO Corporate Website & Franchise CMS",
            "description": "Generated from Spring controllers on 22/07/2026. Login saves the JWT to collection variable token. WebSocket endpoint is ws://localhost:8080/ws; STOMP destinations are /app/chat.visitor.send and /app/chat.admin.send.",
            "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json",
        },
        "auth": {"type": "bearer", "bearer": [{"key": "token", "value": "{{token}}", "type": "string"}]},
        "event": [],
        "variable": [
            {"key": "baseUrl", "value": "http://localhost:8080"},
            {"key": "wsUrl", "value": "ws://localhost:8080/ws"},
            {"key": "token", "value": ""},
            {"key": "adminEmail", "value": "admin@aloo.vn"},
            {"key": "adminPassword", "value": "123456", "type": "secret"},
            {"key": "productId", "value": "1"}, {"key": "productSlug", "value": "kem-bo"},
            {"key": "postId", "value": "1"}, {"key": "postSlug", "value": "cau-chuyen-aloo"},
            {"key": "categoryId", "value": "1"}, {"key": "storeId", "value": "1"},
            {"key": "storeSlug", "value": "aloo-demo"}, {"key": "reviewId", "value": "1"},
            {"key": "leadId", "value": "1"}, {"key": "contactId", "value": "1"},
            {"key": "testimonialId", "value": "1"}, {"key": "chatSessionId", "value": "1"},
            {"key": "adminId", "value": "1"}, {"key": "customerId", "value": "3"},
            {"key": "homeSectionId", "value": "1"}, {"key": "timelineId", "value": "1"},
            {"key": "franchiseContentId", "value": "1"}, {"key": "heroBannerId", "value": "1"},
            {"key": "menuPosterId", "value": "1"},
        ],
        "item": [{"name": group, "item": [make_request(method, path) for method, path in endpoints]} for group, endpoints in GROUPS.items()],
    }
    # Login and OAuth authorization entry point must not inherit bearer auth.
    collection["item"][0]["item"][0]["request"]["auth"] = {"type": "noauth"}
    collection["item"][0]["item"][1]["request"]["auth"] = {"type": "noauth"}
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text(json.dumps(collection, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"Generated {sum(len(v) for v in GROUPS.values())} requests: {OUTPUT}")


if __name__ == "__main__":
    main()
