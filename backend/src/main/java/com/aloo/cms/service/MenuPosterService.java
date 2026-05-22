package com.aloo.cms.service;

import com.aloo.cms.dto.MenuPosterRequest;
import com.aloo.cms.dto.MenuPosterResponse;
import com.aloo.cms.entity.MenuPoster;
import com.aloo.cms.exception.BadRequestException;
import com.aloo.cms.exception.ResourceNotFoundException;
import com.aloo.cms.mapper.MenuPosterMapper;
import com.aloo.cms.repository.MenuPosterRepository;
import java.util.List;
import java.util.Locale;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class MenuPosterService {

    private final MenuPosterRepository menuPosterRepository;
    private final MenuPosterMapper menuPosterMapper;

    @Transactional(readOnly = true)
    public List<MenuPosterResponse> findAll() {
        return menuPosterRepository.findAll(Sort.by("sortOrder").ascending().and(Sort.by("id").ascending()))
                .stream()
                .map(menuPosterMapper::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public MenuPosterResponse findById(Long id) {
        return menuPosterMapper.toResponse(getPoster(id));
    }

    @Transactional
    public MenuPosterResponse create(MenuPosterRequest request) {
        String branchKey = slugify(request.branchKey());
        if (menuPosterRepository.existsByBranchKey(branchKey)) {
            throw new BadRequestException("Menu poster branch key is already used");
        }
        MenuPoster poster = menuPosterMapper.toEntity(request);
        return menuPosterMapper.toResponse(menuPosterRepository.save(poster));
    }

    @Transactional
    public MenuPosterResponse update(Long id, MenuPosterRequest request) {
        MenuPoster poster = getPoster(id);
        String branchKey = slugify(request.branchKey());
        if (menuPosterRepository.existsByBranchKeyAndIdNot(branchKey, id)) {
            throw new BadRequestException("Menu poster branch key is already used");
        }
        menuPosterMapper.updateEntity(poster, request);
        return menuPosterMapper.toResponse(menuPosterRepository.save(poster));
    }

    @Transactional
    public void delete(Long id) {
        menuPosterRepository.delete(getPoster(id));
    }

    private MenuPoster getPoster(Long id) {
        return menuPosterRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Menu poster not found"));
    }

    private String slugify(String value) {
        return value.trim().toLowerCase(Locale.ROOT);
    }
}
