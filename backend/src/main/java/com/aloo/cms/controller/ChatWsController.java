package com.aloo.cms.controller;

import com.aloo.cms.dto.ChatAdminSendPayload;
import com.aloo.cms.dto.ChatVisitorSendPayload;
import com.aloo.cms.service.ChatService;
import jakarta.validation.Valid;
import java.security.Principal;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.stereotype.Controller;

@Controller
@RequiredArgsConstructor
public class ChatWsController {

    private final ChatService chatService;

    @MessageMapping("/chat.visitor.send")
    public void visitorSend(@Valid @Payload ChatVisitorSendPayload payload, StompHeaderAccessor accessor) {
        Long handshakeSessionId = null;
        if (accessor.getSessionAttributes() != null) {
            Object value = accessor.getSessionAttributes().get("chatSessionId");
            if (value instanceof Long sessionId) {
                handshakeSessionId = sessionId;
            }
        }
        if (handshakeSessionId == null) {
            throw new IllegalArgumentException("Chat WebSocket session is not authenticated");
        }
        chatService.handleVisitorMessage(payload, handshakeSessionId);
    }

    @MessageMapping("/chat.admin.send")
    public void adminSend(@Valid @Payload ChatAdminSendPayload payload, Principal principal) {
        if (principal == null) {
            throw new IllegalArgumentException("Admin authentication required");
        }
        chatService.handleAdminMessage(payload, principal.getName());
    }
}
