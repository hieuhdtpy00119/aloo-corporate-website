package com.aloo.cms.service;

import com.aloo.cms.dto.AuditLogPageResponse;
import com.aloo.cms.dto.AuditLogResponse;
import com.aloo.cms.entity.AuditLog;
import com.aloo.cms.repository.AuditLogRepository;
import com.aloo.cms.support.AuditLogSupport;
import java.time.LocalDateTime;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuditLogService {

    private final AuditLogRepository auditLogRepository;

    @Transactional(readOnly = true)
    public List<AuditLogResponse> findRecent() {
        return search(null, null, null, null, null, 0, 200).items();
    }

    @Transactional(readOnly = true)
    public AuditLogPageResponse search(
            String actor,
            String action,
            String entityType,
            LocalDateTime from,
            LocalDateTime to,
            int page,
            int size
    ) {
        int safePage = Math.max(page, 0);
        int safeSize = Math.min(Math.max(size, 1), 200);
        Specification<AuditLog> spec = Specification.where(null);

        if (actor != null && !actor.isBlank()) {
            String keyword = "%" + actor.trim().toLowerCase() + "%";
            spec = spec.and((root, query, cb) -> cb.like(cb.lower(root.get("actorEmail")), keyword));
        }
        if (action != null && !action.isBlank()) {
            String keyword = "%" + action.trim().toLowerCase() + "%";
            spec = spec.and((root, query, cb) -> cb.like(cb.lower(root.get("action")), keyword));
        }
        if (entityType != null && !entityType.isBlank()) {
            String keyword = "%" + entityType.trim().toLowerCase() + "%";
            spec = spec.and((root, query, cb) -> cb.like(cb.lower(root.get("entityType")), keyword));
        }
        if (from != null) {
            spec = spec.and((root, query, cb) -> cb.greaterThanOrEqualTo(root.get("createdAt"), from));
        }
        if (to != null) {
            spec = spec.and((root, query, cb) -> cb.lessThanOrEqualTo(root.get("createdAt"), to));
        }

        Page<AuditLog> result = auditLogRepository.findAll(
                spec,
                PageRequest.of(safePage, safeSize, Sort.by(Sort.Direction.DESC, "createdAt").and(Sort.by(Sort.Direction.DESC, "id")))
        );

        return new AuditLogPageResponse(
                result.getContent().stream().map(this::toResponse).toList(),
                result.getTotalElements(),
                result.getTotalPages(),
                result.getNumber(),
                result.getSize()
        );
    }

    @Transactional
    public void log(String action, String entityType, String entityId, String details) {
        AuditLog entry = new AuditLog();
        entry.setActorEmail(currentActorEmail());
        entry.setAction(action);
        entry.setEntityType(entityType);
        entry.setEntityId(entityId);
        entry.setDetails(details);
        auditLogRepository.save(entry);
    }

    @Transactional
    public void logCreated(String entityType, String entityId, String name, String reference) {
        log("CREATE_" + entityType, entityType, entityId, AuditLogSupport.created(entityType, name, reference));
    }

    @Transactional
    public void logUpdated(String entityType, String entityId, String name, String reference) {
        log("UPDATE_" + entityType, entityType, entityId, AuditLogSupport.updated(entityType, name, reference));
    }

    @Transactional
    public void logDeleted(String entityType, String entityId, String name, String reference) {
        log("DELETE_" + entityType, entityType, entityId, AuditLogSupport.deleted(entityType, name, reference));
    }

    @Transactional
    public void logStatusChanged(String entityType, String entityId, String name, String status) {
        log("UPDATE_" + entityType + "_STATUS", entityType, entityId, AuditLogSupport.statusChanged(entityType, name, status));
    }

    @Transactional
    public void logFeaturedChanged(String entityType, String entityId, String name, boolean featured) {
        log("UPDATE_" + entityType + "_FEATURED", entityType, entityId, AuditLogSupport.featuredChanged(entityType, name, featured));
    }

    @Transactional
    public void logUploaded(String fileName) {
        log("UPLOAD_FILE", "FILE", null, AuditLogSupport.uploaded(fileName));
    }

    private String currentActorEmail() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || authentication.getName() == null || authentication.getName().isBlank()) {
            return "system";
        }
        return authentication.getName();
    }

    private AuditLogResponse toResponse(AuditLog log) {
        return new AuditLogResponse(
                log.getId(),
                log.getActorEmail(),
                log.getAction(),
                log.getEntityType(),
                log.getEntityId(),
                log.getDetails(),
                log.getCreatedAt()
        );
    }
}
