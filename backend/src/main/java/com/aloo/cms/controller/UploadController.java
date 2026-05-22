package com.aloo.cms.controller;

import com.aloo.cms.dto.UploadResponse;
import com.aloo.cms.security.RateLimitService;
import com.aloo.cms.security.RequestClient;
import com.aloo.cms.service.UploadService;
import jakarta.servlet.http.HttpServletRequest;
import java.time.Duration;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/uploads")
@RequiredArgsConstructor
public class UploadController {

    private final UploadService uploadService;
    private final RateLimitService rateLimitService;

    @PostMapping(value = "/images", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public UploadResponse uploadImage(@RequestParam("file") MultipartFile file, HttpServletRequest request) {
        rateLimitService.check("admin-upload", RequestClient.ip(request), 40, Duration.ofMinutes(10));
        return uploadService.uploadImage(file);
    }
}
