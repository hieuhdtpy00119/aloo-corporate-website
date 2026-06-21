package com.aloo.cms.controller;

import com.aloo.cms.dto.AccountPasswordRequest;
import com.aloo.cms.dto.AccountStatusRequest;
import com.aloo.cms.dto.AccountUserRequest;
import com.aloo.cms.dto.AccountUserResponse;
import com.aloo.cms.service.AccountManagementService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/accounts")
@PreAuthorize("hasRole('ADMIN') and @adminScope.has('system')")
@RequiredArgsConstructor
public class AccountManagementController {

    private final AccountManagementService accountManagementService;

    @GetMapping("/admins")
    public List<AccountUserResponse> findAdminUsers() {
        return accountManagementService.findAdminUsers();
    }

    @PostMapping("/admins")
    public ResponseEntity<AccountUserResponse> createAdminUser(@Valid @RequestBody AccountUserRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(accountManagementService.createAdminUser(request));
    }

    @PutMapping("/admins/{id}")
    public AccountUserResponse updateAdminUser(@PathVariable Long id, @Valid @RequestBody AccountUserRequest request) {
        return accountManagementService.updateAdminUser(id, request);
    }

    @PatchMapping("/admins/{id}/status")
    public AccountUserResponse updateAdminStatus(@PathVariable Long id, @Valid @RequestBody AccountStatusRequest request) {
        return accountManagementService.updateAdminStatus(id, request);
    }

    @PutMapping("/admins/{id}/password")
    public ResponseEntity<Void> changeAdminPassword(@PathVariable Long id, @Valid @RequestBody AccountPasswordRequest request) {
        accountManagementService.changeAdminPassword(id, request);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/admins/{id}")
    public ResponseEntity<Void> deleteAdminUser(@PathVariable Long id) {
        accountManagementService.deleteAdminUser(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/customers")
    public List<AccountUserResponse> findCustomerUsers() {
        return accountManagementService.findCustomerUsers();
    }

    @PostMapping("/customers")
    public ResponseEntity<AccountUserResponse> createCustomerUser(@Valid @RequestBody AccountUserRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(accountManagementService.createCustomerUser(request));
    }

    @PutMapping("/customers/{id}")
    public AccountUserResponse updateCustomerUser(@PathVariable Long id, @Valid @RequestBody AccountUserRequest request) {
        return accountManagementService.updateCustomerUser(id, request);
    }

    @PatchMapping("/customers/{id}/status")
    public AccountUserResponse updateCustomerStatus(@PathVariable Long id, @Valid @RequestBody AccountStatusRequest request) {
        return accountManagementService.updateCustomerStatus(id, request);
    }

    @PutMapping("/customers/{id}/password")
    public ResponseEntity<Void> changeCustomerPassword(@PathVariable Long id, @Valid @RequestBody AccountPasswordRequest request) {
        accountManagementService.changeCustomerPassword(id, request);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/customers/{id}")
    public ResponseEntity<Void> deleteCustomerUser(@PathVariable Long id) {
        accountManagementService.deleteCustomerUser(id);
        return ResponseEntity.noContent().build();
    }
}