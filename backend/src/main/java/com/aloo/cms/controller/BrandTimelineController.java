package com.aloo.cms.controller;

import com.aloo.cms.dto.BrandTimelineRequest;
import com.aloo.cms.dto.BrandTimelineResponse;
import com.aloo.cms.service.BrandTimelineService;
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
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/brand-timelines")
@RequiredArgsConstructor
public class BrandTimelineController {

    private final BrandTimelineService brandTimelineService;

    @GetMapping
    public List<BrandTimelineResponse> findAll(@RequestParam(defaultValue = "false") boolean activeOnly) {
        return activeOnly ? brandTimelineService.findActive() : brandTimelineService.findAll();
    }

    @GetMapping("/{id}")
    public BrandTimelineResponse findById(@PathVariable Long id) {
        return brandTimelineService.findById(id);
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN') and @adminScope.has('content')")
    public ResponseEntity<BrandTimelineResponse> create(@Valid @RequestBody BrandTimelineRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(brandTimelineService.create(request));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN') and @adminScope.has('content')")
    public BrandTimelineResponse update(@PathVariable Long id, @Valid @RequestBody BrandTimelineRequest request) {
        return brandTimelineService.update(id, request);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN') and @adminScope.has('content')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        brandTimelineService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
