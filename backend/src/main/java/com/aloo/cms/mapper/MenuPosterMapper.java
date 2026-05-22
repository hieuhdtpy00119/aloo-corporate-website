package com.aloo.cms.mapper;

import com.aloo.cms.dto.MenuPosterRequest;
import com.aloo.cms.dto.MenuPosterResponse;
import com.aloo.cms.entity.MenuPoster;
import org.springframework.stereotype.Component;

@Component
public class MenuPosterMapper {

    public MenuPoster toEntity(MenuPosterRequest request) {
        MenuPoster poster = new MenuPoster();
        updateEntity(poster, request);
        return poster;
    }

    public void updateEntity(MenuPoster poster, MenuPosterRequest request) {
        poster.setBranchKey(MapperUtils.slug(request.branchKey()));
        poster.setTitle(MapperUtils.required(request.title()));
        poster.setSubtitle(MapperUtils.nullable(request.subtitle()));
        poster.setImageUrl(MapperUtils.nullable(request.imageUrl()));
        poster.setAltText(MapperUtils.nullable(request.altText()));
        poster.setSortOrder(request.sortOrder() == null ? 0 : request.sortOrder());
        poster.setStatus(MapperUtils.status(request.status(), "ACTIVE"));
    }

    public MenuPosterResponse toResponse(MenuPoster poster) {
        return new MenuPosterResponse(
                poster.getId(),
                poster.getBranchKey(),
                poster.getTitle(),
                poster.getSubtitle(),
                poster.getImageUrl(),
                poster.getAltText(),
                poster.getSortOrder(),
                poster.getStatus(),
                poster.getCreatedAt(),
                poster.getUpdatedAt()
        );
    }
}
