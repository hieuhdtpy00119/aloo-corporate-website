package com.aloo.cms.service;

import com.aloo.cms.dto.ContactMessageRequest;
import com.aloo.cms.dto.ContactMessageResponse;
import com.aloo.cms.dto.RegistrationStatusUpdateRequest;
import com.aloo.cms.entity.ContactMessage;
import com.aloo.cms.exception.ResourceNotFoundException;
import com.aloo.cms.mapper.ContactMessageMapper;
import com.aloo.cms.repository.ContactMessageRepository;
import java.util.List;
import java.util.Locale;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class ContactMessageService {

    private final ContactMessageRepository contactMessageRepository;
    private final ContactMessageMapper contactMessageMapper;
    private final AuditLogService auditLogService;

    @Transactional
    public ContactMessageResponse create(ContactMessageRequest request) {
        return contactMessageMapper.toResponse(contactMessageRepository.save(contactMessageMapper.toEntity(request)));
    }

    @Transactional(readOnly = true)
    public List<ContactMessageResponse> findAll() {
        return contactMessageRepository.findAll(Sort.by(Sort.Direction.DESC, "createdAt"))
                .stream()
                .map(contactMessageMapper::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public ContactMessageResponse findById(Long id) {
        return contactMessageMapper.toResponse(getMessage(id));
    }

    @Transactional
    public ContactMessageResponse updateStatus(Long id, RegistrationStatusUpdateRequest request) {
        ContactMessage message = getMessage(id);
        message.setStatus(request.status().trim().toUpperCase(Locale.ROOT));
        ContactMessageResponse response = contactMessageMapper.toResponse(contactMessageRepository.save(message));
        auditLogService.logStatusChanged(
                "CONTACT_MESSAGE",
                String.valueOf(response.id()),
                response.fullName(),
                response.status()
        );
        return response;
    }

    @Transactional
    public void delete(Long id) {
        ContactMessage message = getMessage(id);
        auditLogService.logDeleted(
                "CONTACT_MESSAGE",
                String.valueOf(message.getId()),
                message.getFullName(),
                message.getEmail()
        );
        contactMessageRepository.delete(message);
    }

    private ContactMessage getMessage(Long id) {
        return contactMessageRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Contact message not found"));
    }
}
