package com.aloo.cms.mapper;

import com.aloo.cms.dto.BrandTimelineRequest;
import com.aloo.cms.dto.BrandTimelineResponse;
import com.aloo.cms.entity.BrandTimeline;
import org.springframework.stereotype.Component;

@Component
public class BrandTimelineMapper {

    public BrandTimeline toEntity(BrandTimelineRequest request) {
        BrandTimeline item = new BrandTimeline();
        updateEntity(item, request);
        return item;
    }

    public void updateEntity(BrandTimeline item, BrandTimelineRequest request) {
        item.setYear(MapperUtils.required(request.year()));
        item.setTitle(MapperUtils.required(request.title()));
        item.setDescription(MapperUtils.nullable(request.description()));
        item.setImageUrl(MapperUtils.nullable(request.imageUrl()));
        item.setSortOrder(request.sortOrder() == null ? 0 : request.sortOrder());
        item.setStatus(MapperUtils.status(request.status(), "ACTIVE"));
    }

    public BrandTimelineResponse toResponse(BrandTimeline item) {
        return new BrandTimelineResponse(
                item.getId(),
                item.getYear(),
                item.getTitle(),
                item.getDescription(),
                item.getImageUrl(),
                item.getSortOrder(),
                item.getStatus(),
                item.getCreatedAt(),
                item.getUpdatedAt()
        );
    }
}
