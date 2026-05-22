package com.aloo.cms.mapper;

import com.aloo.cms.dto.FranchiseContentRequest;
import com.aloo.cms.dto.FranchiseContentResponse;
import com.aloo.cms.entity.FranchiseContent;
import org.springframework.stereotype.Component;

@Component
public class FranchiseContentMapper {

    public void updateEntity(FranchiseContent content, FranchiseContentRequest request) {
        content.setSectionKey(MapperUtils.required(request.sectionKey()));
        content.setTitle(MapperUtils.required(request.title()));
        content.setContent(MapperUtils.nullable(request.content()));
        content.setAmount(MapperUtils.nullable(request.amount()));
        content.setNote(MapperUtils.nullable(request.note()));
        content.setSortOrder(request.sortOrder());
        content.setStatus(MapperUtils.status(request.status(), "ACTIVE"));
    }

    public FranchiseContentResponse toResponse(FranchiseContent content) {
        return new FranchiseContentResponse(
                content.getId(),
                content.getSectionKey(),
                content.getTitle(),
                content.getContent(),
                content.getAmount(),
                content.getNote(),
                content.getSortOrder(),
                content.getStatus()
        );
    }
}
