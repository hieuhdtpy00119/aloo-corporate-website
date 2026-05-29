package com.aloo.cms.mapper;

import com.aloo.cms.dto.HomeSectionRequest;
import com.aloo.cms.dto.HomeSectionResponse;
import com.aloo.cms.entity.HomeSection;
import org.springframework.stereotype.Component;

@Component
public class HomeSectionMapper {

    public HomeSection toEntity(HomeSectionRequest request) {
        HomeSection section = new HomeSection();
        updateEntity(section, request);
        return section;
    }

    public void updateEntity(HomeSection section, HomeSectionRequest request) {
        section.setSectionKey(MapperUtils.required(request.sectionKey()));
        section.setType(MapperUtils.nullable(request.type()) == null ? "FEATURED_CARD" : request.type().trim().toUpperCase());
        section.setTitle(MapperUtils.required(request.title()));
        section.setSubtitle(MapperUtils.nullable(request.subtitle()));
        section.setDescription(MapperUtils.nullable(request.description()));
        section.setImageUrl(MapperUtils.nullable(request.imageUrl()));
        section.setButtonText(MapperUtils.nullable(request.buttonText()));
        section.setButtonLink(MapperUtils.nullable(request.buttonLink()));
        section.setBadge(MapperUtils.nullable(request.badge()));
        section.setSortOrder(request.sortOrder() == null ? 0 : request.sortOrder());
        section.setStatus(MapperUtils.status(request.status(), "ACTIVE"));
    }

    public HomeSectionResponse toResponse(HomeSection section) {
        return new HomeSectionResponse(
                section.getId(),
                section.getSectionKey(),
                section.getType(),
                section.getTitle(),
                section.getSubtitle(),
                section.getDescription(),
                section.getImageUrl(),
                section.getButtonText(),
                section.getButtonLink(),
                section.getBadge(),
                section.getSortOrder(),
                section.getStatus(),
                section.getCreatedAt(),
                section.getUpdatedAt()
        );
    }
}
