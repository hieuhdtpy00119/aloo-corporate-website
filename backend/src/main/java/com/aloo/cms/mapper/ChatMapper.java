package com.aloo.cms.mapper;

import com.aloo.cms.dto.ChatMessageResponse;
import com.aloo.cms.dto.ChatSessionResponse;
import com.aloo.cms.entity.ChatMessage;
import com.aloo.cms.entity.ChatSession;
import com.aloo.cms.repository.ChatMessageRepository;
import com.aloo.cms.support.TextEncodingSupport;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class ChatMapper {

    private final ChatMessageRepository chatMessageRepository;

    public ChatMessageResponse toMessageResponse(ChatMessage message, String senderName) {
        return new ChatMessageResponse(
                message.getId(),
                message.getSessionId(),
                message.getSenderType(),
                message.getSenderAdminId(),
                TextEncodingSupport.repairUtf8Mojibake(senderName),
                TextEncodingSupport.repairUtf8Mojibake(message.getBody()),
                message.getReadAt(),
                message.getCreatedAt()
        );
    }

    public ChatSessionResponse toSessionResponse(ChatSession session, List<ChatMessageResponse> messages) {
        return toSessionResponse(session, messages, session.getVisitorName());
    }

    public ChatSessionResponse toSessionResponse(
            ChatSession session,
            List<ChatMessageResponse> messages,
            String visitorName
    ) {
        long unreadCount = chatMessageRepository.countBySessionIdAndSenderTypeAndReadAtIsNull(
                session.getId(),
                ChatMessage.SENDER_VISITOR
        );
        return toSessionResponse(session, messages, unreadCount, visitorName);
    }

    public ChatSessionResponse toSessionResponse(ChatSession session, List<ChatMessageResponse> messages, long unreadCount) {
        return toSessionResponse(session, messages, unreadCount, session.getVisitorName());
    }

    public ChatSessionResponse toSessionResponse(
            ChatSession session,
            List<ChatMessageResponse> messages,
            long unreadCount,
            String visitorName
    ) {
        return toSessionResponse(session, messages, unreadCount, visitorName, true);
    }

    public ChatSessionResponse toSessionResponse(
            ChatSession session,
            List<ChatMessageResponse> messages,
            long unreadCount,
            String visitorName,
            boolean includeSessionToken
    ) {
        return new ChatSessionResponse(
                session.getId(),
                includeSessionToken ? session.getSessionToken() : null,
                TextEncodingSupport.repairUtf8Mojibake(visitorName),
                session.getVisitorPhone(),
                session.getStatus(),
                session.getAssignedAdminId(),
                session.getLastMessageAt(),
                session.getCreatedAt(),
                session.getUpdatedAt(),
                unreadCount,
                messages
        );
    }

    public ChatSessionResponse toSessionSummary(ChatSession session, long unreadCount) {
        return toSessionSummary(session, unreadCount, session.getVisitorName());
    }

    public ChatSessionResponse toSessionSummary(ChatSession session, long unreadCount, String visitorName) {
        // Admin inbox/list must never expose visitor session tokens.
        return toSessionResponse(session, List.of(), unreadCount, visitorName, false);
    }
}
