package com.aloo.cms.controller;

import com.aloo.cms.dto.FranchiseContentRequest;
import com.aloo.cms.dto.FranchiseContentResponse;
import com.aloo.cms.security.AdminScopeChecker;
import com.aloo.cms.service.FranchiseContentService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/franchise-contents")
@RequiredArgsConstructor
public class FranchiseContentController {

    private final FranchiseContentService franchiseContentService;
    private final AdminScopeChecker adminScopeChecker;

    @GetMapping
    public List<FranchiseContentResponse> findAll() {
        if (adminScopeChecker.has("content")) {
            return franchiseContentService.findAll();
        }
        return franchiseContentService.findActive();
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasRole('ADMIN') and @adminScope.has('content')")
    public FranchiseContentResponse create(@Valid @RequestBody FranchiseContentRequest request) {
        return franchiseContentService.create(request);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN') and @adminScope.has('content')")
    public FranchiseContentResponse update(
            @PathVariable Long id,
            @Valid @RequestBody FranchiseContentRequest request
    ) {
        return franchiseContentService.update(id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @PreAuthorize("hasRole('ADMIN') and @adminScope.has('content')")
    public void delete(@PathVariable Long id) {
        franchiseContentService.delete(id);
    }
}
