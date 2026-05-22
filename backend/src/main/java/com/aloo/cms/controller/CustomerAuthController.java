package com.aloo.cms.controller;

import com.aloo.cms.dto.AuthResponse;
import com.aloo.cms.dto.ChangePasswordRequest;
import com.aloo.cms.dto.LoginRequest;
import com.aloo.cms.dto.UpdateProfileRequest;
import com.aloo.cms.dto.UploadResponse;
import com.aloo.cms.dto.UserResponse;
import com.aloo.cms.security.RateLimitService;
import com.aloo.cms.security.RequestClient;
import com.aloo.cms.service.CustomerAuthService;
import com.aloo.cms.service.UploadService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import java.time.Duration;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/user-auth")
@RequiredArgsConstructor
public class CustomerAuthController {

    private final CustomerAuthService customerAuthService;
    private final UploadService uploadService;
    private final RateLimitService rateLimitService;

    @PostMapping("/login")
    public AuthResponse login(@Valid @RequestBody LoginRequest request, HttpServletRequest httpRequest) {
        rateLimitService.check("user-login", RequestClient.key(httpRequest, request.email()), 10, Duration.ofMinutes(15));
        return customerAuthService.login(request);
    }

    @GetMapping("/me")
    public UserResponse me(@RequestHeader("Authorization") String authorizationHeader) {
        return customerAuthService.me(authorizationHeader);
    }

    @PutMapping("/profile")
    public UserResponse updateProfile(
            @RequestHeader("Authorization") String authorizationHeader,
            @Valid @RequestBody UpdateProfileRequest request
    ) {
        return customerAuthService.updateProfile(authorizationHeader, request);
    }

    @PutMapping("/change-password")
    public ResponseEntity<Void> changePassword(
            @RequestHeader("Authorization") String authorizationHeader,
            @Valid @RequestBody ChangePasswordRequest request
    ) {
        customerAuthService.changePassword(authorizationHeader, request);
        return ResponseEntity.noContent().build();
    }

    @PostMapping(value = "/uploads/images", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public UploadResponse uploadImage(
            @RequestHeader("Authorization") String authorizationHeader,
            HttpServletRequest httpRequest,
            @RequestParam("file") MultipartFile file
    ) {
        rateLimitService.check("user-upload", RequestClient.ip(httpRequest), 30, Duration.ofMinutes(10));
        customerAuthService.currentUser(authorizationHeader);
        return uploadService.uploadImage(file);
    }
}
