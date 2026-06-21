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

    @Transactional(readOnly = true)
    public List<FranchiseContentResponse> findAll() {
        Sort sort = Sort.by(Sort.Direction.ASC, "sortOrder").and(Sort.by(Sort.Direction.ASC, "id"));
        return franchiseContentRepository.findAll(sort)
                .stream()
                .map(franchiseContentMapper::toResponse)
                .toList();
    }

    @Transactional
    public FranchiseContentResponse update(Long id, FranchiseContentRequest request) {
        FranchiseContent content = franchiseContentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Franchise content not found"));
        franchiseContentMapper.updateEntity(content, request);
        return franchiseContentMapper.toResponse(franchiseContentRepository.save(content));
    }

    public FranchiseContentResponse create(FranchiseContentRequest request) {
        FranchiseContent content = new FranchiseContent();
        franchiseContentMapper.updateEntity(content, request);
        return franchiseContentMapper.toResponse(franchiseContentRepository.save(content));
    }

    public void delete(Long id) {
        if (!franchiseContentRepository.existsById(id)) {
            throw new ResourceNotFoundException("Franchise content not found");
        }
        franchiseContentRepository.deleteById(id);
    }
}
