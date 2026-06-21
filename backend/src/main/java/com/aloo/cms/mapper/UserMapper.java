package com.aloo.cms.mapper;

import com.aloo.cms.dto.AccountUserResponse;
import com.aloo.cms.dto.UserResponse;
import com.aloo.cms.entity.AdminProfile;
import com.aloo.cms.entity.AdminUser;
import com.aloo.cms.entity.UserRole;
import com.aloo.cms.service.AdminPermissionService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class UserMapper {

    private final AdminPermissionService adminPermissionService;

    public UserResponse toResponse(AdminUser user) {
        return new UserResponse(
                user.getId(),
                user.getEmail(),
                user.getFullName(),
                user.getPhone(),
                user.getAvatarUrl(),
                user.getRole().name(),
                resolveAdminProfile(user),
                adminPermissionService.resolveScopes(user),
                user.getStatus(),
                user.getLastLoginAt(),
                user.getCreatedAt(),
                user.getUpdatedAt()
        );
    }

    public AccountUserResponse toAccountResponse(AdminUser user) {
        return new AccountUserResponse(
                user.getId(),
                user.getEmail(),
                user.getFullName(),
                user.getPhone(),
                user.getAvatarUrl(),
                user.getRole().name(),
                resolveAdminProfile(user),
                adminPermissionService.resolveScopes(user),
                user.getStatus(),
                user.getLastLoginAt(),
                user.getCreatedAt(),
                user.getUpdatedAt()
        );
    }

    private String resolveAdminProfile(AdminUser user) {
        if (user.getRole() != UserRole.ADMIN) {
            return null;
        }
        AdminProfile profile = user.getAdminProfile() == null ? AdminProfile.FULL : user.getAdminProfile();
        return profile.name();
    }
}
