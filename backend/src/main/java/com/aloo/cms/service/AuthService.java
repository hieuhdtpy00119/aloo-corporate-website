package com.aloo.cms.service;

import com.aloo.cms.dto.AuthResponse;
import com.aloo.cms.dto.ChangePasswordRequest;
import com.aloo.cms.dto.LoginRequest;
import com.aloo.cms.dto.UpdateProfileRequest;
import com.aloo.cms.dto.UserResponse;
import com.aloo.cms.entity.AdminUser;
import com.aloo.cms.exception.BadRequestException;
import com.aloo.cms.exception.ResourceNotFoundException;
import com.aloo.cms.mapper.UserMapper;
import com.aloo.cms.repository.AdminUserRepository;
import com.aloo.cms.security.CustomUserDetails;
import com.aloo.cms.security.JwtService;
import java.time.LocalDateTime;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final AdminUserRepository adminUserRepository;
    private final JwtService jwtService;
    private final PasswordEncoder passwordEncoder;
    private final UserMapper userMapper;

    @Transactional
    public AuthResponse login(LoginRequest request) {
        String email = request.email().trim().toLowerCase();
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(email, request.password())
        );

        AdminUser user = ((CustomUserDetails) authentication.getPrincipal()).getUser();
        user.setLastLoginAt(LocalDateTime.now());
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
        String normalizedEmail = request.email().trim().toLowerCase();

        if (!user.getEmail().equalsIgnoreCase(normalizedEmail)
                && adminUserRepository.existsByEmailIgnoreCase(normalizedEmail)) {
            throw new BadRequestException("Email is already used");
        }

        user.setFullName(request.fullName().trim());
        user.setEmail(normalizedEmail);
        user.setPhone(nullable(request.phone()));
        user.setAvatarUrl(nullable(request.avatarUrl()));
        return userMapper.toResponse(adminUserRepository.save(user));
    }

    @Transactional
    public void changePassword(Authentication authentication, ChangePasswordRequest request) {
        AdminUser user = currentUser(authentication);

        if (!passwordEncoder.matches(request.currentPassword(), user.getPasswordHash())) {
            throw new BadRequestException("Current password is incorrect");
        }

        user.setPasswordHash(passwordEncoder.encode(request.newPassword()));
        adminUserRepository.save(user);
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
}
