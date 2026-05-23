package com.aloo.cms.security;

import static org.assertj.core.api.Assertions.assertThat;

import com.aloo.cms.entity.AdminUser;
import com.aloo.cms.entity.UserRole;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

class JwtServiceTest {

    @Test
    void generatedTokenIsValidForMatchingAdminUser() {
        JwtService jwtService = jwtService(3_600_000);
        AdminUser admin = admin("admin@aloo.vn");
        String token = jwtService.generateToken(admin);

        assertThat(jwtService.extractEmail(token)).isEqualTo("admin@aloo.vn");
        assertThat(jwtService.isTokenValid(token, new CustomUserDetails(admin))).isTrue();
        assertThat(jwtService.isTokenValidForEmail(token, "admin@aloo.vn")).isTrue();
    }

    @Test
    void tokenIsInvalidForDifferentUserOrExpiredToken() {
        JwtService validService = jwtService(3_600_000);
        String token = validService.generateToken(admin("admin@aloo.vn"));

        assertThat(validService.isTokenValid(token, new CustomUserDetails(admin("other@aloo.vn")))).isFalse();

        JwtService expiredService = jwtService(-1_000);
        String expiredToken = expiredService.generateToken(admin("admin@aloo.vn"));
        assertThat(expiredService.isTokenValidForEmail(expiredToken, "admin@aloo.vn")).isFalse();
    }

    private JwtService jwtService(long expirationMs) {
        JwtService service = new JwtService();
        ReflectionTestUtils.setField(
                service,
                "jwtSecret",
                "ALOO_Franchise_CMS_Test_Secret_Key_At_Least_32_Chars"
        );
        ReflectionTestUtils.setField(service, "jwtExpirationMs", expirationMs);
        return service;
    }

    private AdminUser admin(String email) {
        AdminUser user = new AdminUser();
        user.setEmail(email);
        user.setPasswordHash("$2a$10$7EqJtq98hPqEX7fNZaFWoOFBKDBQawXp0N17DkT5dOblGm5UQzN9e");
        user.setFullName("ALOO Admin");
        user.setRole(UserRole.ADMIN);
        user.setStatus("ACTIVE");
        return user;
    }
}
