package com.aloo.cms.service;

import com.aloo.cms.dto.AuthResponse;
import com.aloo.cms.dto.ChangePasswordRequest;
import com.aloo.cms.dto.LoginRequest;
import com.aloo.cms.dto.UpdateProfileRequest;
import com.aloo.cms.dto.UserResponse;
import com.aloo.cms.entity.CustomerUser;
import com.aloo.cms.exception.BadRequestException;
import com.aloo.cms.mapper.UserMapper;
import com.aloo.cms.repository.CustomerUserRepository;
import com.aloo.cms.security.JwtService;
import java.time.LocalDateTime;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class CustomerAuthService {

    private static final String BEARER_PREFIX = "Bearer ";

    private final CustomerUserRepository customerUserRepository;
    private final JwtService jwtService;
    private final PasswordEncoder passwordEncoder;
    private final UserMapper userMapper;

    @Transactional
    public AuthResponse login(LoginRequest request) {
        String email = request.email().trim().toLowerCase();
        CustomerUser user = customerUserRepository.findByEmailIgnoreCase(email)
                .orElseThrow(() -> new BadCredentialsException("Email or password is incorrect"));

        if (!passwordEncoder.matches(request.password(), user.getPasswordHash())) {
            throw new BadCredentialsException("Email or password is incorrect");
        }
        if (!"ACTIVE".equalsIgnoreCase(user.getStatus())) {
            throw new BadRequestException("User account is inactive");
        }

        user.setLastLoginAt(LocalDateTime.now());
        customerUserRepository.save(user);
        String token = jwtService.generateToken(user.getEmail(), user.getRole());
        return AuthResponse.bearer(token, userMapper.toResponse(user));
    }

    @Transactional(readOnly = true)
    public UserResponse me(String authorizationHeader) {
        return userMapper.toResponse(currentUser(authorizationHeader));
    }

    @Transactional
    public UserResponse updateProfile(String authorizationHeader, UpdateProfileRequest request) {
        CustomerUser user = currentUser(authorizationHeader);
        String normalizedEmail = request.email().trim().toLowerCase();

        if (!user.getEmail().equalsIgnoreCase(normalizedEmail)
                && customerUserRepository.existsByEmailIgnoreCase(normalizedEmail)) {
            throw new BadRequestException("Email is already used");
        }

        user.setFullName(request.fullName().trim());
        user.setEmail(normalizedEmail);
        user.setPhone(nullable(request.phone()));
        user.setAvatarUrl(nullable(request.avatarUrl()));
        return userMapper.toResponse(customerUserRepository.save(user));
    }

    @Transactional
    public void changePassword(String authorizationHeader, ChangePasswordRequest request) {
        CustomerUser user = currentUser(authorizationHeader);

        if (!passwordEncoder.matches(request.currentPassword(), user.getPasswordHash())) {
            throw new BadRequestException("Current password is incorrect");
        }

        user.setPasswordHash(passwordEncoder.encode(request.newPassword()));
        customerUserRepository.save(user);
    }

    public CustomerUser currentUser(String authorizationHeader) {
        String token = tokenFrom(authorizationHeader);
        String email = jwtService.extractEmail(token);
        CustomerUser user = customerUserRepository.findByEmailIgnoreCase(email)
                .orElseThrow(() -> new BadCredentialsException("Invalid user token"));

        if (!jwtService.isTokenValidForEmail(token, user.getEmail())) {
            throw new BadCredentialsException("Invalid user token");
        }
        if (!"ACTIVE".equalsIgnoreCase(user.getStatus())) {
            throw new BadRequestException("User account is inactive");
        }

        return user;
    }

    private String tokenFrom(String authorizationHeader) {
        if (authorizationHeader == null || !authorizationHeader.startsWith(BEARER_PREFIX)) {
            throw new BadCredentialsException("Missing user token");
        }
        return authorizationHeader.substring(BEARER_PREFIX.length());
    }

    private String nullable(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
