package com.aloo.cms.support;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.aloo.cms.entity.AdminUser;
import com.aloo.cms.entity.AuthProvider;
import org.junit.jupiter.api.Test;

class PasswordChangePolicyTest {

    @Test
    void requiresOtpForGoogleAccountsWithoutPassword() {
        AdminUser user = new AdminUser();
        user.setAuthProvider(AuthProvider.GOOGLE);

        assertTrue(PasswordChangePolicy.requiresOtpVerification(user));
        assertFalse(PasswordChangePolicy.requiresCurrentPassword(user));
    }

    @Test
    void masksEmailForDisplay() {
        assertEquals("hi***@gmail.com", PasswordChangePolicy.maskEmail("hieuhdtpy00119@gmail.com"));
    }
}
