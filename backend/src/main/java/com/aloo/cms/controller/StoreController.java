package com.aloo.cms.controller;

import com.aloo.cms.dto.StoreResponse;
import com.aloo.cms.service.StoreService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/stores")
@RequiredArgsConstructor
public class StoreController {

    private final StoreService storeService;

    @GetMapping
    public List<StoreResponse> findAll(
            @RequestParam(required = false) String province,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) Boolean featured
    ) {
        return storeService.findAll(province, status, featured);
    }

    @GetMapping("/featured")
    public List<StoreResponse> featured() {
        return storeService.findFeatured();
    }

    @GetMapping("/{slug}")
    public StoreResponse findBySlug(@PathVariable String slug) {
        return storeService.findBySlug(slug);
    }
}
