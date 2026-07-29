package com.aloo.cms.service;

import com.aloo.cms.entity.AdminProfile;
import com.aloo.cms.entity.AdminUser;
import com.aloo.cms.entity.UserRole;
import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class AdminPermissionService {

    public AdminProfile resolveProfile(AdminUser user) {
        if (user.getRole() != UserRole.ADMIN) {
            return null;
        }
        return user.getAdminProfile() == null ? AdminProfile.CONTENT : user.getAdminProfile();
    }

    public List<String> resolveScopes(AdminUser user) {
        AdminProfile profile = resolveProfile(user);
        if (profile == null) {
            return List.of();
        }
        return profile.scopes();
    }
}
