package com.aloo.cms.security;

import com.aloo.cms.dto.AuthResponse;
import com.aloo.cms.entity.AdminUser;
import com.aloo.cms.entity.AuthProvider;
import com.aloo.cms.entity.UserRole;
import com.aloo.cms.exception.BadRequestException;
import com.aloo.cms.mapper.UserMapper;
import com.aloo.cms.repository.AdminUserRepository;
import java.time.LocalDateTime;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class GoogleOAuthLoginService {

    private final AdminUserRepository adminUserRepository;
    private final JwtService jwtService;
    private final PasswordEncoder passwordEncoder;
    private final UserMapper userMapper;

    @Transactional
    public AuthResponse login(OAuth2User principal) {
        String email = required(principal.getAttribute("email"), "Google account does not provide an email")
                .trim()
                .toLowerCase();
        String fullName = nullable(principal.getAttribute("name"));
        String avatarUrl = nullable(principal.getAttribute("picture"));

        AdminUser user = adminUserRepository.findByEmailIgnoreCase(email)
                .map(existing -> updateGoogleProfile(existing, fullName, avatarUrl))
                .orElseGet(() -> createUser(email, fullName, avatarUrl));

        if (!"ACTIVE".equalsIgnoreCase(user.getStatus())) {
            throw new BadRequestException("Account is inactive");
        }

        user.setLastLoginAt(LocalDateTime.now());
        AdminUser saved = adminUserRepository.save(user);
        return AuthResponse.bearer(jwtService.generateToken(saved), userMapper.toResponse(saved));
    }

    private AdminUser createUser(String email, String fullName, String avatarUrl) {
        AdminUser user = new AdminUser();
        user.setEmail(email);
        user.setFullName(fullName == null ? email : fullName);
        user.setAvatarUrl(avatarUrl);
        user.setRole(UserRole.USER);
        user.setStatus("ACTIVE");
        user.setAuthProvider(AuthProvider.GOOGLE);
        user.setPasswordHash(passwordEncoder.encode(UUID.randomUUID().toString()));
        return user;
    }

    private AdminUser updateGoogleProfile(AdminUser user, String fullName, String avatarUrl) {
        user.setAuthProvider(AuthProvider.GOOGLE);
        if (shouldSyncGoogleAvatar(user.getAvatarUrl(), avatarUrl)) {
            user.setAvatarUrl(avatarUrl);
        }
        return user;
    }

    private boolean shouldSyncGoogleAvatar(String currentAvatar, String googleAvatar) {
        if (googleAvatar == null || googleAvatar.isBlank()) {
            return false;
        }
        if (currentAvatar == null || currentAvatar.isBlank()) {
            return true;
        }
        return currentAvatar.contains("googleusercontent.com");
    }

    private String required(Object value, String message) {
        String normalized = nullable(value);
        if (normalized == null) {
            throw new BadRequestException(message);
        }
        return normalized;
    }

    private String nullable(Object value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.toString().trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
