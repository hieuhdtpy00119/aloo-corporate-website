package com.aloo.cms.service;

import com.aloo.cms.dto.HeroBannerRequest;
import com.aloo.cms.dto.HeroBannerResponse;
import com.aloo.cms.entity.HeroBanner;
import com.aloo.cms.exception.ResourceNotFoundException;
import com.aloo.cms.mapper.HeroBannerMapper;
import com.aloo.cms.repository.HeroBannerRepository;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class HeroBannerService {

    private final HeroBannerRepository heroBannerRepository;
    private final HeroBannerMapper heroBannerMapper;

    @Transactional(readOnly = true)
    public List<HeroBannerResponse> findAll() {
        return heroBannerRepository.findAll(Sort.by("sortOrder").ascending().and(Sort.by("id").ascending()))
                .stream()
                .map(heroBannerMapper::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public HeroBannerResponse findById(Long id) {
        return heroBannerMapper.toResponse(getBanner(id));
    }

    @Transactional
    public HeroBannerResponse create(HeroBannerRequest request) {
        HeroBanner banner = heroBannerMapper.toEntity(request);
        return heroBannerMapper.toResponse(heroBannerRepository.save(banner));
    }

    @Transactional
    public HeroBannerResponse update(Long id, HeroBannerRequest request) {
        HeroBanner banner = getBanner(id);
        heroBannerMapper.updateEntity(banner, request);
        return heroBannerMapper.toResponse(heroBannerRepository.save(banner));
    }

    @Transactional
    public void delete(Long id) {
        heroBannerRepository.delete(getBanner(id));
    }

    private HeroBanner getBanner(Long id) {
        return heroBannerRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Hero banner not found"));
    }
}
