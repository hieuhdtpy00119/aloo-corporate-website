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
    private final AuditLogService auditLogService;

    @Transactional(readOnly = true)
    public List<MenuPosterResponse> findAll() {
        return menuPosterRepository.findAll(Sort.by("sortOrder").ascending().and(Sort.by("id").ascending()))
                .stream()
                .map(menuPosterMapper::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<MenuPosterResponse> findActive() {
        return menuPosterRepository.findByStatusIgnoreCase(
                        "ACTIVE",
                        Sort.by("sortOrder").ascending().and(Sort.by("id").ascending())
                )
                .stream()
                .map(menuPosterMapper::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public MenuPosterResponse findById(Long id) {
        return menuPosterMapper.toResponse(getPoster(id));
    }

    @Transactional(readOnly = true)
    public MenuPosterResponse findActiveById(Long id) {
        MenuPoster poster = getPoster(id);
        if (poster.getStatus() == null || !"ACTIVE".equalsIgnoreCase(poster.getStatus())) {
            throw new ResourceNotFoundException("Menu poster not found");
        }
        return menuPosterMapper.toResponse(poster);
    }

    @Transactional
    public MenuPosterResponse create(MenuPosterRequest request) {
        String branchKey = slugify(request.branchKey());
        if (menuPosterRepository.existsByBranchKey(branchKey)) {
            throw new BadRequestException("Menu poster branch key is already used");
        }
        MenuPoster poster = menuPosterMapper.toEntity(request);
        MenuPosterResponse response = menuPosterMapper.toResponse(menuPosterRepository.save(poster));
        auditLogService.logCreated("MENU_POSTER", String.valueOf(response.id()), response.title(), response.branchKey());
        return response;
    }

    @Transactional
    public MenuPosterResponse update(Long id, MenuPosterRequest request) {
        MenuPoster poster = getPoster(id);
        String branchKey = slugify(request.branchKey());
        if (menuPosterRepository.existsByBranchKeyAndIdNot(branchKey, id)) {
            throw new BadRequestException("Menu poster branch key is already used");
        }
        menuPosterMapper.updateEntity(poster, request);
        MenuPosterResponse response = menuPosterMapper.toResponse(menuPosterRepository.save(poster));
        auditLogService.logUpdated("MENU_POSTER", String.valueOf(response.id()), response.title(), response.branchKey());
        return response;
    }

    @Transactional
    public void delete(Long id) {
        MenuPoster poster = getPoster(id);
        auditLogService.logDeleted("MENU_POSTER", String.valueOf(poster.getId()), poster.getTitle(), poster.getBranchKey());
        menuPosterRepository.delete(poster);
    }

    private MenuPoster getPoster(Long id) {
        return menuPosterRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Menu poster not found"));
    }

    private String slugify(String value) {
        return value.trim().toLowerCase(Locale.ROOT);
    }
}
