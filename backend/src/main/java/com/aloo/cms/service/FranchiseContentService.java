package com.aloo.cms.service;

import com.aloo.cms.dto.FranchiseContentRequest;
import com.aloo.cms.dto.FranchiseContentResponse;
import com.aloo.cms.entity.FranchiseContent;
import com.aloo.cms.exception.ResourceNotFoundException;
import com.aloo.cms.mapper.FranchiseContentMapper;
import com.aloo.cms.repository.FranchiseContentRepository;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class FranchiseContentService {

    private final FranchiseContentRepository franchiseContentRepository;
    private final FranchiseContentMapper franchiseContentMapper;
    private final AuditLogService auditLogService;

    @Transactional(readOnly = true)
    public List<FranchiseContentResponse> findAll() {
        Sort sort = Sort.by(Sort.Direction.ASC, "sortOrder").and(Sort.by(Sort.Direction.ASC, "id"));
        return franchiseContentRepository.findAll(sort)
                .stream()
                .map(franchiseContentMapper::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<FranchiseContentResponse> findActive() {
        Sort sort = Sort.by(Sort.Direction.ASC, "sortOrder").and(Sort.by(Sort.Direction.ASC, "id"));
        return franchiseContentRepository.findByStatusIgnoreCase("ACTIVE", sort)
                .stream()
                .map(franchiseContentMapper::toResponse)
                .toList();
    }

    @Transactional
    public FranchiseContentResponse update(Long id, FranchiseContentRequest request) {
        FranchiseContent content = franchiseContentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Franchise content not found"));
        franchiseContentMapper.updateEntity(content, request);
        FranchiseContentResponse response = franchiseContentMapper.toResponse(franchiseContentRepository.save(content));
        auditLogService.logUpdated("FRANCHISE_CONTENT", String.valueOf(response.id()), label(response), response.sectionKey());
        return response;
    }

    @Transactional
    public FranchiseContentResponse create(FranchiseContentRequest request) {
        FranchiseContent content = new FranchiseContent();
        franchiseContentMapper.updateEntity(content, request);
        FranchiseContentResponse response = franchiseContentMapper.toResponse(franchiseContentRepository.save(content));
        auditLogService.logCreated("FRANCHISE_CONTENT", String.valueOf(response.id()), label(response), response.sectionKey());
        return response;
    }

    @Transactional
    public void delete(Long id) {
        FranchiseContent content = franchiseContentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Franchise content not found"));
        FranchiseContentResponse response = franchiseContentMapper.toResponse(content);
        auditLogService.logDeleted("FRANCHISE_CONTENT", String.valueOf(content.getId()), label(response), response.sectionKey());
        franchiseContentRepository.delete(content);
    }

    private String label(FranchiseContentResponse response) {
        if (response.title() != null && !response.title().isBlank()) {
            return response.title();
        }
        return response.sectionKey();
    }
}
