package com.aloo.cms.security;

import com.aloo.cms.entity.AdminUser;
import com.aloo.cms.entity.UserRole;
import com.aloo.cms.service.AdminPermissionService;
import java.util.Arrays;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

@Component("adminScope")
@RequiredArgsConstructor
public class AdminScopeChecker {

    private final AdminPermissionService adminPermissionService;

    public boolean has(String scope) {
        AdminUser user = currentAdminUser();
        if (user == null || user.getRole() != UserRole.ADMIN) {
            return false;
        }
        return adminPermissionService.resolveScopes(user).contains(scope);
    }

    public boolean hasAny(String... scopes) {
        AdminUser user = currentAdminUser();
        if (user == null || user.getRole() != UserRole.ADMIN) {
            return false;
        }
        List<String> granted = adminPermissionService.resolveScopes(user);
        return Arrays.stream(scopes).anyMatch(granted::contains);
    }

    private AdminUser currentAdminUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !(authentication.getPrincipal() instanceof CustomUserDetails principal)) {
            return null;
        }
        return principal.getUser();
    }
}
