package com.aloo.cms.service;

import com.aloo.cms.dto.AuthResponse;
import com.aloo.cms.dto.ChangePasswordRequest;
import com.aloo.cms.dto.ChangePasswordResponse;
import com.aloo.cms.dto.LoginRequest;
import com.aloo.cms.dto.PasswordChangeOtpResponse;
import com.aloo.cms.dto.UpdateProfileRequest;
import com.aloo.cms.dto.UserResponse;
import com.aloo.cms.entity.AdminUser;
import com.aloo.cms.entity.AuthProvider;
import com.aloo.cms.exception.BadRequestException;
import com.aloo.cms.exception.ResourceNotFoundException;
import com.aloo.cms.mapper.UserMapper;
import com.aloo.cms.repository.AdminUserRepository;
import com.aloo.cms.security.CustomUserDetails;
import com.aloo.cms.security.JwtService;
import com.aloo.cms.support.PasswordChangePolicy;
import com.aloo.cms.support.PasswordPolicySupport;
import java.time.LocalDateTime;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final AdminUserRepository adminUserRepository;
    private final JwtService jwtService;
    private final PasswordEncoder passwordEncoder;
    private final UserMapper userMapper;
    private final AuditLogService auditLogService;
    private final ChatService chatService;
    private final MailNotificationService mailNotificationService;
    private final PasswordChangeOtpService passwordChangeOtpService;

    @Transactional
    public AuthResponse login(LoginRequest request) {
        String email = request.email().trim().toLowerCase();
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(email, request.password())
        );

        AdminUser user = ((CustomUserDetails) authentication.getPrincipal()).getUser();
        user.setLastLoginAt(LocalDateTime.now());
        if (user.getAuthProvider() != AuthProvider.GOOGLE) {
            user.setAuthProvider(AuthProvider.LOCAL);
        }
        adminUserRepository.save(user);
        String token = jwtService.generateToken(user);
        return AuthResponse.bearer(token, userMapper.toResponse(user));
    }

    @Transactional(readOnly = true)
    public UserResponse me(Authentication authentication) {
        return userMapper.toResponse(currentUser(authentication));
    }

    @Transactional
    public UserResponse updateProfile(Authentication authentication, UpdateProfileRequest request) {
        AdminUser user = currentUser(authentication);

        String priorPhone = user.getPhone();
        String priorEmail = user.getEmail();

        user.setFullName(request.fullName().trim());
        if (user.getAuthProvider() != AuthProvider.GOOGLE) {
            String normalizedEmail = request.email().trim().toLowerCase();
            if (!user.getEmail().equalsIgnoreCase(normalizedEmail)
                    && adminUserRepository.existsByEmailIgnoreCase(normalizedEmail)) {
                throw new BadRequestException("Email is already used");
            }
            user.setEmail(normalizedEmail);
        }
        user.setPhone(nullable(request.phone()));
        if (request.avatarUrl() != null) {
            user.setAvatarUrl(nullable(request.avatarUrl()));
        }
        AdminUser saved = adminUserRepository.save(user);
        chatService.syncVisitorSessionsForUser(saved, priorPhone, priorEmail);
        UserResponse response = userMapper.toResponse(saved);
        auditLogService.logUpdated("ADMIN_PROFILE", String.valueOf(user.getId()), user.getEmail(), user.getEmail());
        return response;
    }

    @Transactional
    public PasswordChangeOtpResponse requestPasswordChangeOtp(Authentication authentication) {
        AdminUser user = currentUser(authentication);
        return passwordChangeOtpService.requestOtp(user);
    }

    @Transactional
    public ChangePasswordResponse changePassword(Authentication authentication, ChangePasswordRequest request) {
        AdminUser user = currentUser(authentication);
        String newPassword = request.newPassword();
        PasswordPolicySupport.validateStrongPassword(newPassword);

        if (PasswordChangePolicy.requiresCurrentPassword(user)) {
            String currentPassword = request.currentPassword() == null ? "" : request.currentPassword().trim();
            if (!StringUtils.hasText(currentPassword)) {
                throw new BadRequestException("Current password is required");
            }
            if (!passwordEncoder.matches(currentPassword, user.getPasswordHash())) {
                throw new BadRequestException("Current password is incorrect");
            }
            if (passwordEncoder.matches(newPassword, user.getPasswordHash())) {
                throw new BadRequestException("New password must be different from current password");
            }
        } else if (PasswordChangePolicy.requiresOtpVerification(user)) {
            if (!passwordChangeOtpService.isOtpRequired(user)) {
                throw new BadRequestException(
                        "Email verification is required to set a password for Google accounts. Configure mail or sign in again."
                );
            }
            passwordChangeOtpService.verifyAndConsume(user.getId(), request.otp());
        }

        LocalDateTime changedAt = LocalDateTime.now();
        user.setPasswordHash(passwordEncoder.encode(newPassword));
        user.setPasswordSetAt(changedAt);
        user.setSecurityVersion(nextSecurityVersion(user));
        adminUserRepository.save(user);
        auditLogService.log(
                "CHANGE_OWN_PASSWORD",
                "ADMIN_PROFILE",
                String.valueOf(user.getId()),
                "Changed own password for " + user.getEmail()
        );
        boolean emailSent = mailNotificationService.sendPasswordChangedNotification(user, changedAt);
        return new ChangePasswordResponse(changedAt, emailSent);
    }

    private AdminUser currentUser(Authentication authentication) {
        if (authentication == null || !(authentication.getPrincipal() instanceof CustomUserDetails principal)) {
            throw new ResourceNotFoundException("Authenticated admin user not found");
        }

        Long userId = principal.getUser().getId();
        return adminUserRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Authenticated admin user not found"));
    }

    private String nullable(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private long nextSecurityVersion(AdminUser user) {
        return (user.getSecurityVersion() == null ? 0L : user.getSecurityVersion()) + 1L;
    }
}
