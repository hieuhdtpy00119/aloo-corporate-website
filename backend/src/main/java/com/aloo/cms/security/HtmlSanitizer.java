package com.aloo.cms.security;

import java.util.regex.Pattern;

public final class HtmlSanitizer {

    private static final Pattern DANGEROUS_ELEMENTS = Pattern.compile(
            "(?is)<\\s*(script|style|iframe|object|embed|meta|link|base|form|input|button|textarea|select|option)\\b[^>]*>.*?<\\s*/\\s*\\1\\s*>"
    );
    private static final Pattern SELF_CLOSING_DANGEROUS_ELEMENTS = Pattern.compile(
            "(?is)<\\s*(script|style|iframe|object|embed|meta|link|base|form|input|button|textarea|select|option)\\b[^>]*?/?>"
    );
    private static final Pattern EVENT_HANDLER_ATTRIBUTES = Pattern.compile(
            "(?is)\\s+on[a-z0-9_-]+\\s*=\\s*(\"[^\"]*\"|'[^']*'|[^\\s>]+)"
    );
    private static final Pattern DANGEROUS_URLS = Pattern.compile(
            "(?is)\\s+(href|src)\\s*=\\s*(\"\\s*(javascript:|data:text/html)[^\"]*\"|'\\s*(javascript:|data:text/html)[^']*'|\\s*(javascript:|data:text/html)[^\\s>]+)"
    );

    private HtmlSanitizer() {
    }

    public static String sanitize(String html) {
        if (html == null || html.isBlank()) {
            return html;
        }

        String sanitized = DANGEROUS_ELEMENTS.matcher(html).replaceAll("");
        sanitized = SELF_CLOSING_DANGEROUS_ELEMENTS.matcher(sanitized).replaceAll("");
        sanitized = EVENT_HANDLER_ATTRIBUTES.matcher(sanitized).replaceAll("");
        sanitized = DANGEROUS_URLS.matcher(sanitized).replaceAll("");
        return sanitized;
    }
}
