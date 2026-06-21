package com.aloo.cms.controller;

import com.aloo.cms.dto.StoreRequest;
import com.aloo.cms.dto.StoreResponse;
import com.aloo.cms.service.StoreService;
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
@RequestMapping("/api/admin/stores")
@PreAuthorize("hasRole('ADMIN') and @adminScope.has('stores')")
@RequiredArgsConstructor
public class AdminStoreController {

    private final StoreService storeService;

    @GetMapping
    public List<StoreResponse> findAll(
            @RequestParam(required = false) String province,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) Boolean featured
    ) {
        return storeService.findAll(province, status, featured);
    }

    @PostMapping
    public ResponseEntity<StoreResponse> create(@Valid @RequestBody StoreRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(storeService.create(request));
    }

    @PutMapping("/{id}")
    public StoreResponse update(@PathVariable Long id, @Valid @RequestBody StoreRequest request) {
        return storeService.update(id, request);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        storeService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
