package com.aloo.cms.controller;

import com.aloo.cms.dto.AuthResponse;
import com.aloo.cms.dto.ChangePasswordRequest;
import com.aloo.cms.dto.LoginRequest;
import com.aloo.cms.dto.UpdateProfileRequest;
import com.aloo.cms.dto.UserResponse;
import com.aloo.cms.security.RateLimitService;
import com.aloo.cms.security.RequestClient;
import com.aloo.cms.service.AuthService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import java.time.Duration;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
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

    @PutMapping("/change-password")
    public ResponseEntity<Void> changePassword(
            Authentication authentication,
            @Valid @RequestBody ChangePasswordRequest request
    ) {
        authService.changePassword(authentication, request);
        return ResponseEntity.noContent().build();
    }
}
