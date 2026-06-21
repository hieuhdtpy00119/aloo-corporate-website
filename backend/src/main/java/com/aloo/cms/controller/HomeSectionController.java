package com.aloo.cms.controller;

import com.aloo.cms.dto.HomeSectionRequest;
import com.aloo.cms.dto.HomeSectionResponse;
import com.aloo.cms.service.HomeSectionService;
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
@RequestMapping("/api/home-sections")
@RequiredArgsConstructor
public class HomeSectionController {

    private final HomeSectionService homeSectionService;

    @GetMapping
    public List<HomeSectionResponse> findAll(@RequestParam(defaultValue = "false") boolean activeOnly) {
        return homeSectionService.findAll(activeOnly);
    }

    @GetMapping("/{id}")
    public HomeSectionResponse findById(@PathVariable Long id) {
        return homeSectionService.findById(id);
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN') and @adminScope.has('content')")
    public ResponseEntity<HomeSectionResponse> create(@Valid @RequestBody HomeSectionRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(homeSectionService.create(request));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN') and @adminScope.has('content')")
    public HomeSectionResponse update(@PathVariable Long id, @Valid @RequestBody HomeSectionRequest request) {
        return homeSectionService.update(id, request);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN') and @adminScope.has('content')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        homeSectionService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
