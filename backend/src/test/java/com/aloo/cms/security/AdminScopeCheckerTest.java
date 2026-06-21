package com.aloo.cms.security;

import static org.assertj.core.api.Assertions.assertThat;

import com.aloo.cms.entity.AdminProfile;
import com.aloo.cms.entity.AdminUser;
import com.aloo.cms.entity.UserRole;
import com.aloo.cms.service.AdminPermissionService;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;

class AdminScopeCheckerTest {

    private final AdminScopeChecker checker = new AdminScopeChecker(new AdminPermissionService());

    @AfterEach
    void clearContext() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void grantsScopeForMatchingAdminProfile() {
        authenticate(admin(UserRole.ADMIN, AdminProfile.CONTENT));

        assertThat(checker.has("content")).isTrue();
        assertThat(checker.has("system")).isFalse();
    }

    @Test
    void deniesScopeForNonAdminUsers() {
        authenticate(admin(UserRole.USER, null));

        assertThat(checker.has("content")).isFalse();
    }

    private void authenticate(AdminUser user) {
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(new CustomUserDetails(user), null, new CustomUserDetails(user).getAuthorities())
        );
    }

    private AdminUser admin(UserRole role, AdminProfile profile) {
        AdminUser user = new AdminUser();
        user.setEmail("admin@aloo.vn");
        user.setPasswordHash("hash");
        user.setFullName("Admin");
        user.setRole(role);
        user.setAdminProfile(profile);
        user.setStatus("ACTIVE");
        return user;
    }
}
