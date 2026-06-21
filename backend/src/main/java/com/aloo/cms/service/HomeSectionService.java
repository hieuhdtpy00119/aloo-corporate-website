package com.aloo.cms.service;

import com.aloo.cms.dto.HomeSectionRequest;
import com.aloo.cms.dto.HomeSectionResponse;
import com.aloo.cms.entity.HomeSection;
import com.aloo.cms.exception.BadRequestException;
import com.aloo.cms.exception.ResourceNotFoundException;
import com.aloo.cms.mapper.HomeSectionMapper;
import com.aloo.cms.repository.HomeSectionRepository;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class HomeSectionService {

    private final HomeSectionRepository homeSectionRepository;
    private final HomeSectionMapper homeSectionMapper;

    @Transactional(readOnly = true)
    public List<HomeSectionResponse> findAll(boolean activeOnly) {
        Sort sort = Sort.by("sortOrder").ascending().and(Sort.by("id").ascending());
        List<HomeSection> sections = activeOnly
                ? homeSectionRepository.findByStatus("ACTIVE", sort)
                : homeSectionRepository.findAll(sort);
        return sections.stream().map(homeSectionMapper::toResponse).toList();
    }

    @Transactional(readOnly = true)
    public HomeSectionResponse findById(Long id) {
        return homeSectionMapper.toResponse(getSection(id));
    }

    @Transactional
    public HomeSectionResponse create(HomeSectionRequest request) {
        assertUniqueSectionKey(request.sectionKey(), null);
        HomeSection section = homeSectionMapper.toEntity(request);
        return homeSectionMapper.toResponse(homeSectionRepository.save(section));
    }

    @Transactional
    public HomeSectionResponse update(Long id, HomeSectionRequest request) {
        HomeSection section = getSection(id);
        if (!section.getSectionKey().equals(request.sectionKey())) {
            throw new BadRequestException("Section key cannot be changed");
        }
        assertUniqueSectionKey(request.sectionKey(), id);
        homeSectionMapper.updateEntity(section, request);
        return homeSectionMapper.toResponse(homeSectionRepository.save(section));
    }

    @Transactional
    public void delete(Long id) {
        homeSectionRepository.delete(getSection(id));
    }

    private HomeSection getSection(Long id) {
        return homeSectionRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Home section not found"));
    }

    private void assertUniqueSectionKey(String sectionKey, Long excludeId) {
        boolean exists = excludeId == null
                ? homeSectionRepository.existsBySectionKey(sectionKey)
                : homeSectionRepository.existsBySectionKeyAndIdNot(sectionKey, excludeId);
        if (exists) {
            throw new BadRequestException("Section key is already used");
        }
    }
}
