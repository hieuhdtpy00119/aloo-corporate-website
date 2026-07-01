package com.aloo.cms.service;

import com.aloo.cms.dto.FeaturedUpdateRequest;
import com.aloo.cms.dto.FeedbackRequest;
import com.aloo.cms.dto.FeedbackResponse;
import com.aloo.cms.entity.Feedback;
import com.aloo.cms.exception.ResourceNotFoundException;
import com.aloo.cms.mapper.FeedbackMapper;
import com.aloo.cms.repository.FeedbackRepository;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class FeedbackService {

    private final FeedbackRepository feedbackRepository;
    private final FeedbackMapper feedbackMapper;
    private final AuditLogService auditLogService;

    @Transactional(readOnly = true)
    public List<FeedbackResponse> findVisible() {
        return feedbackRepository.findByVisibleTrue(defaultSort())
                .stream()
                .map(feedbackMapper::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<FeedbackResponse> findAllForAdmin() {
        return feedbackRepository.findAll(defaultSort())
                .stream()
                .map(feedbackMapper::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public FeedbackResponse findByIdForAdmin(Long id) {
        return feedbackMapper.toResponse(getFeedback(id));
    }

    @Transactional
    public FeedbackResponse create(FeedbackRequest request) {
        Feedback feedback = feedbackMapper.toEntity(request);
        FeedbackResponse response = feedbackMapper.toResponse(feedbackRepository.save(feedback));
        auditLogService.logCreated("FEEDBACK", String.valueOf(response.id()), response.customerName(), String.valueOf(response.id()));
        return response;
    }

    @Transactional
    public FeedbackResponse update(Long id, FeedbackRequest request) {
        Feedback feedback = getFeedback(id);
        feedbackMapper.updateEntity(feedback, request);
        FeedbackResponse response = feedbackMapper.toResponse(feedbackRepository.save(feedback));
        auditLogService.logUpdated("FEEDBACK", String.valueOf(response.id()), response.customerName(), String.valueOf(response.id()));
        return response;
    }

    @Transactional
    public FeedbackResponse updateFeatured(Long id, FeaturedUpdateRequest request) {
        Feedback feedback = getFeedback(id);
        feedback.setVisible(Boolean.TRUE.equals(request.featured()));
        FeedbackResponse response = feedbackMapper.toResponse(feedbackRepository.save(feedback));
        auditLogService.logFeaturedChanged("FEEDBACK", String.valueOf(response.id()), response.customerName(), response.visible());
        return response;
    }

    @Transactional
    public void delete(Long id) {
        Feedback feedback = getFeedback(id);
        auditLogService.logDeleted("FEEDBACK", String.valueOf(feedback.getId()), feedback.getCustomerName(), String.valueOf(feedback.getId()));
        feedbackRepository.delete(feedback);
    }

    private Feedback getFeedback(Long id) {
        return feedbackRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Feedback not found"));
    }

    private Sort defaultSort() {
        return Sort.by("sortOrder").ascending().and(Sort.by("createdAt").descending());
    }
}
