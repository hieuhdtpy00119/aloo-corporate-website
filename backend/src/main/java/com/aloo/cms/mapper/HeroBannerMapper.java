package com.aloo.cms.mapper;

import com.aloo.cms.dto.HeroBannerRequest;
import com.aloo.cms.dto.HeroBannerResponse;
import com.aloo.cms.entity.HeroBanner;
import org.springframework.stereotype.Component;

@Component
public class HeroBannerMapper {

    public HeroBanner toEntity(HeroBannerRequest request) {
        HeroBanner banner = new HeroBanner();
        updateEntity(banner, request);
        return banner;
    }

    public void updateEntity(HeroBanner banner, HeroBannerRequest request) {
        banner.setTitle(MapperUtils.required(request.title()));
        banner.setSubtitle(MapperUtils.nullable(request.subtitle()));
        banner.setDescription(MapperUtils.nullable(request.description()));
        banner.setBackgroundImageUrl(MapperUtils.nullable(request.backgroundImageUrl()));
        banner.setProductImageUrl(MapperUtils.nullable(request.productImageUrl()));
        banner.setThumbnailImageUrl(MapperUtils.nullable(request.thumbnailImageUrl()));
        banner.setTone(MapperUtils.nullable(request.tone()) == null ? "light" : request.tone().trim().toLowerCase());
        banner.setSortOrder(request.sortOrder() == null ? 0 : request.sortOrder());
        banner.setStatus(MapperUtils.status(request.status(), "ACTIVE"));
    }

    public HeroBannerResponse toResponse(HeroBanner banner) {
        return new HeroBannerResponse(
                banner.getId(),
                banner.getTitle(),
                banner.getSubtitle(),
                banner.getDescription(),
                banner.getBackgroundImageUrl(),
                banner.getProductImageUrl(),
                banner.getThumbnailImageUrl(),
                banner.getTone(),
                banner.getSortOrder(),
                banner.getStatus(),
                banner.getCreatedAt(),
                banner.getUpdatedAt()
        );
    }
}
