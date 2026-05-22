package com.aloo.cms.controller;

import com.aloo.cms.dto.FranchiseRegistrationRequest;
import com.aloo.cms.dto.FranchiseRegistrationResponse;
import com.aloo.cms.dto.RegistrationStatusUpdateRequest;
import com.aloo.cms.service.FranchiseRegistrationService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/franchise-registrations")
@RequiredArgsConstructor
public class FranchiseRegistrationController {

    private final FranchiseRegistrationService registrationService;

    @PostMapping
    public ResponseEntity<FranchiseRegistrationResponse> create(
            @Valid @RequestBody FranchiseRegistrationRequest request
    ) {
        return ResponseEntity.status(HttpStatus.CREATED).body(registrationService.create(request));
    }

    @GetMapping
    public List<FranchiseRegistrationResponse> findAll() {
        return registrationService.findAll();
    }

    @GetMapping("/{id}")
    public FranchiseRegistrationResponse findById(@PathVariable Long id) {
        return registrationService.findById(id);
    }

    @PatchMapping("/{id}/status")
    public FranchiseRegistrationResponse updateStatus(
            @PathVariable Long id,
            @Valid @RequestBody RegistrationStatusUpdateRequest request
    ) {
        return registrationService.updateStatus(id, request);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        registrationService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
