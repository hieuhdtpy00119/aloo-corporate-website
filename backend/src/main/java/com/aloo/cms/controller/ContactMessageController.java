package com.aloo.cms.controller;

import com.aloo.cms.dto.ContactMessageRequest;
import com.aloo.cms.dto.ContactMessageResponse;
import com.aloo.cms.dto.RegistrationStatusUpdateRequest;
import com.aloo.cms.service.ContactMessageService;
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
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/contact-messages")
@RequiredArgsConstructor
public class ContactMessageController {

    private final ContactMessageService contactMessageService;

    @PostMapping
    public ResponseEntity<ContactMessageResponse> create(@Valid @RequestBody ContactMessageRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(contactMessageService.create(request));
    }

    @GetMapping
    @PreAuthorize("hasRole('ADMIN') and @adminScope.has('crm')")
    public List<ContactMessageResponse> findAll() {
        return contactMessageService.findAll();
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN') and @adminScope.has('crm')")
    public ContactMessageResponse findById(@PathVariable Long id) {
        return contactMessageService.findById(id);
    }

    @PatchMapping("/{id}/status")
    @PreAuthorize("hasRole('ADMIN') and @adminScope.has('crm')")
    public ContactMessageResponse updateStatus(@PathVariable Long id, @Valid @RequestBody RegistrationStatusUpdateRequest request) {
        return contactMessageService.updateStatus(id, request);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN') and @adminScope.has('crm')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        contactMessageService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
