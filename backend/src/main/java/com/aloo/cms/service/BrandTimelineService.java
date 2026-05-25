package com.aloo.cms.service;

import com.aloo.cms.dto.BrandTimelineRequest;
import com.aloo.cms.dto.BrandTimelineResponse;
import com.aloo.cms.entity.BrandTimeline;
import com.aloo.cms.exception.ResourceNotFoundException;
import com.aloo.cms.mapper.BrandTimelineMapper;
import com.aloo.cms.repository.BrandTimelineRepository;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class BrandTimelineService {

    private final BrandTimelineRepository brandTimelineRepository;
    private final BrandTimelineMapper brandTimelineMapper;

    @Transactional(readOnly = true)
    public List<BrandTimelineResponse> findAll() {
        return brandTimelineRepository.findAll(defaultSort()).stream()
                .map(brandTimelineMapper::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<BrandTimelineResponse> findActive() {
        return brandTimelineRepository.findAllByStatusIgnoreCase("ACTIVE", defaultSort()).stream()
                .map(brandTimelineMapper::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public BrandTimelineResponse findById(Long id) {
        return brandTimelineMapper.toResponse(getItem(id));
    }

    @Transactional
    public BrandTimelineResponse create(BrandTimelineRequest request) {
        return brandTimelineMapper.toResponse(brandTimelineRepository.save(brandTimelineMapper.toEntity(request)));
    }

    @Transactional
    public BrandTimelineResponse update(Long id, BrandTimelineRequest request) {
        BrandTimeline item = getItem(id);
        brandTimelineMapper.updateEntity(item, request);
        return brandTimelineMapper.toResponse(brandTimelineRepository.save(item));
    }

    @Transactional
    public void delete(Long id) {
        brandTimelineRepository.delete(getItem(id));
    }

    private BrandTimeline getItem(Long id) {
        return brandTimelineRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Brand timeline item not found"));
    }

    private Sort defaultSort() {
        return Sort.by("sortOrder").ascending().and(Sort.by("id").ascending());
    }
}
