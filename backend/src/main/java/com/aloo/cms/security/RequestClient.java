package com.aloo.cms.security;

import jakarta.servlet.http.HttpServletRequest;

/**
 * Resolves client identity for rate limiting.
 * Prefer {@link HttpServletRequest#getRemoteAddr()} so spoofable
 * {@code X-Forwarded-For} headers are ignored unless the reverse proxy
 * rewrites the remote address via Spring's forwarded-header strategy.
 */
public final class RequestClient {

    private RequestClient() {
    }

    public static String key(HttpServletRequest request, String subject) {
        return ip(request) + ":" + (subject == null ? "" : subject);
    }

    public static String ip(HttpServletRequest request) {
        return request.getRemoteAddr() == null ? "unknown" : request.getRemoteAddr();
    }
}
