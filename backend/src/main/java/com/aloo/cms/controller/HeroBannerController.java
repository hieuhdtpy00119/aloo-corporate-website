package com.aloo.cms.controller;

import com.aloo.cms.dto.HeroBannerRequest;
import com.aloo.cms.dto.HeroBannerResponse;
import com.aloo.cms.service.HeroBannerService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/hero-banners")
@RequiredArgsConstructor
public class HeroBannerController {

    private final HeroBannerService heroBannerService;

    @GetMapping
    public List<HeroBannerResponse> findAll() {
        return heroBannerService.findAll();
    }

    @GetMapping("/{id}")
    public HeroBannerResponse findById(@PathVariable Long id) {
        return heroBannerService.findById(id);
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN') and @adminScope.has('content')")
    public ResponseEntity<HeroBannerResponse> create(@Valid @RequestBody HeroBannerRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(heroBannerService.create(request));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN') and @adminScope.has('content')")
    public HeroBannerResponse update(@PathVariable Long id, @Valid @RequestBody HeroBannerRequest request) {
        return heroBannerService.update(id, request);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN') and @adminScope.has('content')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        heroBannerService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
