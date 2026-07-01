package com.aloo.cms.controller;

import com.aloo.cms.dto.ChatSessionResponse;
import com.aloo.cms.dto.ChatSessionStatusUpdateRequest;
import com.aloo.cms.service.ChatService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/chat")
@RequiredArgsConstructor
public class AdminChatController {

    private final ChatService chatService;

    @GetMapping("/sessions")
    @PreAuthorize("hasRole('ADMIN') and @adminScope.has('crm')")
    public List<ChatSessionResponse> findSessions() {
        return chatService.findAllSessions();
    }

    @GetMapping("/sessions/{id}")
    @PreAuthorize("hasRole('ADMIN') and @adminScope.has('crm')")
    public ChatSessionResponse findSession(@PathVariable Long id) {
        return chatService.findSessionById(id);
    }

    @PatchMapping("/sessions/{id}/status")
    @PreAuthorize("hasRole('ADMIN') and @adminScope.has('crm')")
    public ChatSessionResponse updateStatus(
            @PathVariable Long id,
            @Valid @RequestBody ChatSessionStatusUpdateRequest request
    ) {
        return chatService.updateStatus(id, request);
    }

    @PostMapping("/sessions/{id}/read")
    @PreAuthorize("hasRole('ADMIN') and @adminScope.has('crm')")
    public void markRead(@PathVariable Long id) {
        chatService.markVisitorMessagesRead(id);
    }
}
