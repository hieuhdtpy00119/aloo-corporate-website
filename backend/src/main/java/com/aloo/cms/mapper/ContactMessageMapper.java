package com.aloo.cms.mapper;

import com.aloo.cms.dto.ContactMessageRequest;
import com.aloo.cms.dto.ContactMessageResponse;
import com.aloo.cms.entity.ContactMessage;
import org.springframework.stereotype.Component;

@Component
public class ContactMessageMapper {

    public ContactMessage toEntity(ContactMessageRequest request) {
        ContactMessage message = new ContactMessage();
        updateEntity(message, request);
        return message;
    }

    public void updateEntity(ContactMessage message, ContactMessageRequest request) {
        message.setFullName(MapperUtils.required(request.fullName()));
        message.setEmail(MapperUtils.nullable(request.email()));
        message.setPhone(MapperUtils.required(request.phone()));
        message.setSubject(MapperUtils.nullable(request.subject()));
        message.setMessage(MapperUtils.required(request.message()));
        message.setStatus(MapperUtils.status(request.status(), "NEW"));
    }

    public ContactMessageResponse toResponse(ContactMessage message) {
        return new ContactMessageResponse(
                message.getId(),
                message.getFullName(),
                message.getEmail(),
                message.getPhone(),
                message.getSubject(),
                message.getMessage(),
                message.getStatus(),
                message.getCreatedAt(),
                message.getUpdatedAt()
        );
    }
}
