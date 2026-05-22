package com.aloo.cms.security;

import jakarta.servlet.http.HttpServletRequest;

public final class RequestClient {

    private RequestClient() {
    }

    public static String key(HttpServletRequest request, String subject) {
        return ip(request) + ":" + (subject == null ? "" : subject);
    }

    public static String ip(HttpServletRequest request) {
        String forwardedFor = request.getHeader("X-Forwarded-For");
        if (forwardedFor != null && !forwardedFor.isBlank()) {
            return forwardedFor.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }
}
