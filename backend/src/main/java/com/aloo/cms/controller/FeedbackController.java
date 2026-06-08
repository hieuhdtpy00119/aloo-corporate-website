package com.aloo.cms.controller;

import com.aloo.cms.dto.FeedbackResponse;
import com.aloo.cms.service.FeedbackService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/testimonials")
@RequiredArgsConstructor
public class FeedbackController {

    private final FeedbackService feedbackService;

    @GetMapping
    public List<FeedbackResponse> visible() {
        return feedbackService.findVisible();
    }
}
