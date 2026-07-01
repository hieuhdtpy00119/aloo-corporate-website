package com.aloo.cms.support;

import com.aloo.cms.entity.AdminUser;
import com.aloo.cms.entity.AuthProvider;

public final class PasswordChangePolicy {

    private PasswordChangePolicy() {
    }

    public static boolean requiresCurrentPassword(AdminUser user) {
        if (user.getPasswordSetAt() != null) {
            return true;
        }
        AuthProvider provider = user.getAuthProvider();
        return provider == null || provider == AuthProvider.LOCAL;
    }

    public static boolean requiresOtpVerification(AdminUser user) {
        if (user.getPasswordSetAt() != null) {
            return false;
        }
        return user.getAuthProvider() == AuthProvider.GOOGLE;
    }

    public static String maskEmail(String email) {
        if (email == null || email.isBlank()) {
            return "";
        }
        String normalized = email.trim();
        int at = normalized.indexOf('@');
        if (at <= 0) {
            return normalized;
        }
        String local = normalized.substring(0, at);
        String domain = normalized.substring(at);
        if (local.length() <= 2) {
            return local.charAt(0) + "***" + domain;
        }
        return local.substring(0, 2) + "***" + domain;
    }
}
