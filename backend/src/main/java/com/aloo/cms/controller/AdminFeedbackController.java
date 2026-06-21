package com.aloo.cms.controller;

import com.aloo.cms.dto.FeaturedUpdateRequest;
import com.aloo.cms.dto.FeedbackRequest;
import com.aloo.cms.dto.FeedbackResponse;
import com.aloo.cms.service.FeedbackService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/testimonials")
@PreAuthorize("hasRole('ADMIN') and @adminScope.has('crm')")
@RequiredArgsConstructor
public class AdminFeedbackController {

    private final FeedbackService feedbackService;

    @GetMapping
    public List<FeedbackResponse> findAll() {
        return feedbackService.findAllForAdmin();
    }

    @GetMapping("/{id}")
    public FeedbackResponse findById(@PathVariable Long id) {
        return feedbackService.findByIdForAdmin(id);
    }

    @PostMapping
    public ResponseEntity<FeedbackResponse> create(@Valid @RequestBody FeedbackRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(feedbackService.create(request));
    }

    @PutMapping("/{id}")
    public FeedbackResponse update(@PathVariable Long id, @Valid @RequestBody FeedbackRequest request) {
        return feedbackService.update(id, request);
    }

    @PatchMapping("/{id}/visible")
    public FeedbackResponse updateVisible(@PathVariable Long id, @Valid @RequestBody FeaturedUpdateRequest request) {
        return feedbackService.updateFeatured(id, request);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        feedbackService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
