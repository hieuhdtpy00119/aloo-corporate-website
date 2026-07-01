package com.aloo.cms.controller;

import com.aloo.cms.dto.AuthResponse;
import com.aloo.cms.dto.ChangePasswordRequest;
import com.aloo.cms.dto.ChangePasswordResponse;
import com.aloo.cms.dto.LoginRequest;
import com.aloo.cms.dto.PasswordChangeOtpResponse;
import com.aloo.cms.dto.UpdateProfileRequest;
import com.aloo.cms.dto.UploadResponse;
import com.aloo.cms.dto.UserResponse;
import com.aloo.cms.security.RateLimitService;
import com.aloo.cms.security.RequestClient;
import com.aloo.cms.service.AuthService;
import com.aloo.cms.service.UploadService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import java.time.Duration;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    private final UploadService uploadService;
    private final RateLimitService rateLimitService;

    @PostMapping("/login")
    public AuthResponse login(@Valid @RequestBody LoginRequest request, HttpServletRequest httpRequest) {
        rateLimitService.check("admin-login", RequestClient.key(httpRequest, request.email()), 8, Duration.ofMinutes(15));
        return authService.login(request);
    }

    @GetMapping("/me")
    public UserResponse me(Authentication authentication) {
        return authService.me(authentication);
    }

    @PutMapping("/profile")
    public UserResponse updateProfile(
            Authentication authentication,
            @Valid @RequestBody UpdateProfileRequest request
    ) {
        return authService.updateProfile(authentication, request);
    }

    @PostMapping("/password-change/request-otp")
    public PasswordChangeOtpResponse requestPasswordChangeOtp(
            Authentication authentication,
            HttpServletRequest httpRequest
    ) {
        rateLimitService.check(
                "password-change-otp-request",
                RequestClient.ip(httpRequest),
                10,
                Duration.ofMinutes(15)
        );
        return authService.requestPasswordChangeOtp(authentication);
    }

    @PutMapping("/change-password")
    public ChangePasswordResponse changePassword(
            Authentication authentication,
            @Valid @RequestBody ChangePasswordRequest request
    ) {
        return authService.changePassword(authentication, request);
    }

    @PostMapping(value = "/profile/avatar", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public UploadResponse uploadProfileAvatar(
            @RequestParam("file") MultipartFile file,
            HttpServletRequest httpRequest
    ) {
        rateLimitService.check("profile-avatar-upload", RequestClient.ip(httpRequest), 20, Duration.ofMinutes(10));
        return uploadService.uploadImage(file);
    }
}
