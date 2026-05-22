package com.aloo.cms.controller;

import com.aloo.cms.dto.FranchiseContentRequest;
import com.aloo.cms.dto.FranchiseContentResponse;
import com.aloo.cms.service.FranchiseContentService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/franchise-contents")
@RequiredArgsConstructor
public class FranchiseContentController {

    private final FranchiseContentService franchiseContentService;

    @GetMapping
    public List<FranchiseContentResponse> findAll() {
        return franchiseContentService.findAll();
    }

    @PutMapping("/{id}")
    public FranchiseContentResponse update(
            @PathVariable Long id,
            @Valid @RequestBody FranchiseContentRequest request
    ) {
        return franchiseContentService.update(id, request);
    }
}
