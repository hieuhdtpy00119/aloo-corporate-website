package com.aloo.cms.mapper;

import com.aloo.cms.dto.FeedbackRequest;
import com.aloo.cms.dto.FeedbackResponse;
import com.aloo.cms.entity.Feedback;
import org.springframework.stereotype.Component;

@Component
public class FeedbackMapper {

    public Feedback toEntity(FeedbackRequest request) {
        Feedback feedback = new Feedback();
        updateEntity(feedback, request);
        return feedback;
    }

    public void updateEntity(Feedback feedback, FeedbackRequest request) {
        feedback.setCustomerName(MapperUtils.required(request.customerName()));
        feedback.setAvatarUrl(MapperUtils.nullable(request.avatarUrl()));
        feedback.setRating(request.rating());
        feedback.setContent(MapperUtils.required(request.content()));
        feedback.setStoreName(MapperUtils.nullable(request.storeName()));
        feedback.setVisible(request.visible() == null || Boolean.TRUE.equals(request.visible()));
        feedback.setSortOrder(request.sortOrder() == null ? 0 : request.sortOrder());
    }

    public FeedbackResponse toResponse(Feedback feedback) {
        return new FeedbackResponse(
                feedback.getId(),
                feedback.getCustomerName(),
                feedback.getAvatarUrl(),
                feedback.getStoreName(),
                feedback.getRating(),
                feedback.getContent(),
                feedback.getVisible(),
                feedback.getSortOrder(),
                feedback.getCreatedAt(),
                feedback.getUpdatedAt()
        );
    }
}
