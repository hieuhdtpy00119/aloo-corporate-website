package com.aloo.cms.service;

import com.aloo.cms.dto.ChatAdminSendPayload;
import com.aloo.cms.dto.ChatMessageResponse;
import com.aloo.cms.dto.ChatSessionCreateRequest;
import com.aloo.cms.dto.ChatSessionResponse;
import com.aloo.cms.dto.ChatSessionStatusUpdateRequest;
import com.aloo.cms.dto.ChatVisitorSendPayload;
import com.aloo.cms.entity.AdminUser;
import com.aloo.cms.entity.ChatMessage;
import com.aloo.cms.entity.ChatSession;
import com.aloo.cms.exception.BadRequestException;
import com.aloo.cms.exception.ResourceNotFoundException;
import com.aloo.cms.mapper.ChatMapper;
import com.aloo.cms.repository.AdminUserRepository;
import com.aloo.cms.repository.ChatMessageRepository;
import com.aloo.cms.repository.ChatSessionRepository;
import com.aloo.cms.support.TextEncodingSupport;
import java.time.LocalDateTime;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Sort;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import jakarta.annotation.PostConstruct;

@Service
@RequiredArgsConstructor
public class ChatService {

    public static final String SESSION_TOPIC_PREFIX = "/topic/chat/session.";
    public static final String ADMIN_INBOX_TOPIC = "/topic/admin/chat/inbox";

    private final ChatSessionRepository chatSessionRepository;
    private final ChatMessageRepository chatMessageRepository;
    private final AdminUserRepository adminUserRepository;
    private final ChatMapper chatMapper;
    private final SimpMessagingTemplate messagingTemplate;

    @Value("${app.chat.auto.enabled:true}")
    private boolean autoMessagesEnabled;

    @Value("${app.chat.auto.sender-name:ALOO Tư vấn}")
    private String autoSenderName;

    @Value("${app.chat.auto.welcome-message:}")
    private String welcomeMessage;

    @Value("${app.chat.auto.received-message:}")
    private String receivedMessage;

    @PostConstruct
    void normalizeAutoMessageEncoding() {
        autoSenderName = TextEncodingSupport.repairUtf8Mojibake(autoSenderName);
        welcomeMessage = TextEncodingSupport.repairUtf8Mojibake(welcomeMessage);
        receivedMessage = TextEncodingSupport.repairUtf8Mojibake(receivedMessage);
    }

    @Transactional
    public ChatSessionResponse createSession(ChatSessionCreateRequest request) {
        ChatSession session = new ChatSession();
        session.setSessionToken(UUID.randomUUID().toString().replace("-", ""));
        session.setVisitorName(request.fullName().trim());
        session.setVisitorPhone(request.phone().trim());
        session.setStatus(ChatSession.STATUS_OPEN);
        ChatSession saved = chatSessionRepository.save(session);

        List<ChatMessageResponse> messages = List.of();
        if (autoMessagesEnabled && StringUtils.hasText(welcomeMessage)) {
            messages = List.of(sendAutomatedMessage(saved, welcomeMessage.trim()));
        }

        ChatSessionResponse response = chatMapper.toSessionResponse(saved, messages);
        publishInboxEvent("SESSION_CREATED", response);
        return response;
    }

    @Transactional
    public ChatSessionResponse createSessionForAuthenticatedUser(String email) {
        AdminUser user = adminUserRepository.findByEmailIgnoreCase(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        String fullName = StringUtils.hasText(user.getFullName()) ? user.getFullName().trim() : user.getEmail();
        String contactKey = StringUtils.hasText(user.getPhone())
                ? user.getPhone().trim()
                : user.getEmail().trim().toLowerCase();

        return chatSessionRepository
                .findFirstByVisitorPhoneIgnoreCaseAndStatusInOrderByUpdatedAtDesc(
                        contactKey,
                        List.of(ChatSession.STATUS_OPEN, ChatSession.STATUS_ACTIVE)
                )
                .map(session -> {
                    applyVisitorProfile(session, fullName, contactKey);
                    chatSessionRepository.save(session);
                    return toSessionWithMessages(session, false, true);
                })
                .orElseGet(() -> createSession(new ChatSessionCreateRequest(fullName, contactKey)));
    }

    @Transactional
    public void syncVisitorSessionsForUser(AdminUser user, String priorPhone, String priorEmail) {
        String fullName = displayName(user);
        String contactKey = contactKeyFor(user);
        Set<String> lookupKeys = new LinkedHashSet<>();
        addContactKey(lookupKeys, contactKey);
        addContactKey(lookupKeys, priorPhone);
        addContactKey(lookupKeys, priorEmail);
        addContactKey(lookupKeys, user.getPhone());
        addContactKey(lookupKeys, user.getEmail());
        if (lookupKeys.isEmpty()) {
            return;
        }

        List<ChatSession> sessions = chatSessionRepository.findByVisitorPhoneIgnoreCaseInAndStatusIn(
                lookupKeys,
                List.of(ChatSession.STATUS_OPEN, ChatSession.STATUS_ACTIVE)
        );

        for (ChatSession session : sessions) {
            applyVisitorProfile(session, fullName, contactKey);
            ChatSession saved = chatSessionRepository.save(session);
            publishInboxEvent("SESSION_UPDATED", toSessionSummary(saved));
        }
    }

    @Transactional(readOnly = true)
    public ChatSessionResponse getVisitorSession(String sessionToken) {
        ChatSession session = getSessionByToken(sessionToken);
        return toSessionWithMessages(session, false, true);
    }

    @Transactional(readOnly = true)
    public List<ChatSessionResponse> findAllSessions() {
        return chatSessionRepository.findAll(Sort.by(Sort.Direction.DESC, "updatedAt"))
                .stream()
                .map(this::toSessionSummary)
                .toList();
    }

    @Transactional(readOnly = true)
    public ChatSessionResponse findSessionById(Long id) {
        return toSessionWithMessages(getSession(id), true, false);
    }

    @Transactional
    public ChatSessionResponse updateStatus(Long id, ChatSessionStatusUpdateRequest request) {
        ChatSession session = getSession(id);
        String status = request.status().trim().toUpperCase(Locale.ROOT);
        if (!List.of(ChatSession.STATUS_OPEN, ChatSession.STATUS_ACTIVE, ChatSession.STATUS_CLOSED).contains(status)) {
            throw new BadRequestException("Invalid chat session status");
        }
        session.setStatus(status);
        ChatSession saved = chatSessionRepository.save(session);
        ChatSessionResponse response = toSessionSummary(saved);
        publishInboxEvent("SESSION_UPDATED", response);
        return response;
    }

    @Transactional
    public ChatMessageResponse handleVisitorMessage(ChatVisitorSendPayload payload, Long handshakeSessionId) {
        ChatSession session = getSessionByToken(payload.sessionToken());
        if (handshakeSessionId != null && !handshakeSessionId.equals(session.getId())) {
            throw new BadRequestException("Chat session token does not match WebSocket connection");
        }
        if (ChatSession.STATUS_CLOSED.equals(session.getStatus())) {
            throw new BadRequestException("Chat session is closed");
        }

        if (ChatSession.STATUS_OPEN.equals(session.getStatus())) {
            session.setStatus(ChatSession.STATUS_ACTIVE);
        }
        session.setLastMessageAt(LocalDateTime.now());
        chatSessionRepository.save(session);

        String visitorName = resolveVisitorName(session);
        ChatMessage message = persistMessage(session.getId(), ChatMessage.SENDER_VISITOR, null, payload.body().trim());
        ChatMessageResponse response = chatMapper.toMessageResponse(message, visitorName);
        publishMessage(session.getId(), response);
        maybeSendReceivedAcknowledgement(session);
        publishInboxEvent("SESSION_UPDATED", toSessionSummary(session));
        return response;
    }

    @Transactional
    public ChatMessageResponse handleAdminMessage(ChatAdminSendPayload payload, String adminEmail) {
        ChatSession session = getSession(payload.sessionId());
        if (ChatSession.STATUS_CLOSED.equals(session.getStatus())) {
            throw new BadRequestException("Chat session is closed");
        }

        var admin = adminUserRepository.findByEmailIgnoreCase(adminEmail)
                .orElseThrow(() -> new ResourceNotFoundException("Admin user not found"));

        if (ChatSession.STATUS_OPEN.equals(session.getStatus())) {
            session.setStatus(ChatSession.STATUS_ACTIVE);
        }
        session.setAssignedAdminId(admin.getId());
        session.setLastMessageAt(LocalDateTime.now());
        chatSessionRepository.save(session);

        chatMessageRepository.markReadForSession(session.getId(), ChatMessage.SENDER_VISITOR);

        ChatMessage message = persistMessage(session.getId(), ChatMessage.SENDER_ADMIN, admin.getId(), payload.body().trim());
        ChatMessageResponse response = chatMapper.toMessageResponse(message, admin.getFullName());
        publishMessage(session.getId(), response);
        publishInboxEvent("SESSION_UPDATED", toSessionSummary(session));
        return response;
    }

    @Transactional
    public void markVisitorMessagesRead(Long sessionId) {
        getSession(sessionId);
        chatMessageRepository.markReadForSession(sessionId, ChatMessage.SENDER_VISITOR);
    }

    private ChatMessage persistMessage(Long sessionId, String senderType, Long senderAdminId, String body) {
        if (body.isBlank()) {
            throw new BadRequestException("Message body is required");
        }
        ChatMessage message = new ChatMessage();
        message.setSessionId(sessionId);
        message.setSenderType(senderType);
        message.setSenderAdminId(senderAdminId);
        message.setBody(body);
        return chatMessageRepository.save(message);
    }

    private ChatSessionResponse toSessionWithMessages(ChatSession session, boolean markRead, boolean includeSessionToken) {
        if (markRead) {
            chatMessageRepository.markReadForSession(session.getId(), ChatMessage.SENDER_VISITOR);
        }

        Map<Long, String> adminNames = adminUserRepository.findAll()
                .stream()
                .collect(Collectors.toMap(admin -> admin.getId(), admin -> admin.getFullName(), (left, right) -> left));

        List<ChatMessageResponse> messages = chatMessageRepository.findBySessionIdOrderByCreatedAtAsc(session.getId())
                .stream()
                .map(message -> chatMapper.toMessageResponse(message, resolveSenderName(session, message, adminNames)))
                .toList();

        long unreadCount = chatMessageRepository.countBySessionIdAndSenderTypeAndReadAtIsNull(
                session.getId(),
                ChatMessage.SENDER_VISITOR
        );
        return chatMapper.toSessionResponse(
                session,
                messages,
                unreadCount,
                resolveVisitorName(session),
                includeSessionToken
        );
    }

    private ChatSessionResponse toSessionSummary(ChatSession session) {
        long unreadCount = chatMessageRepository.countBySessionIdAndSenderTypeAndReadAtIsNull(
                session.getId(),
                ChatMessage.SENDER_VISITOR
        );
        return chatMapper.toSessionSummary(session, unreadCount, resolveVisitorName(session));
    }

    private String resolveSenderName(ChatSession session, ChatMessage message, Map<Long, String> adminNames) {
        if (ChatMessage.SENDER_ADMIN.equals(message.getSenderType())) {
            if (message.getSenderAdminId() == null) {
                return autoSenderName;
            }
            return adminNames.getOrDefault(message.getSenderAdminId(), autoSenderName);
        }
        return resolveVisitorName(session);
    }

    private String resolveVisitorName(ChatSession session) {
        String storedName = TextEncodingSupport.repairUtf8Mojibake(session.getVisitorName());
        String contact = session.getVisitorPhone();
        if (!StringUtils.hasText(contact)) {
            return storedName;
        }

        Optional<AdminUser> user = findUserByContactKey(contact.trim());
        return user.map(this::displayName).orElse(storedName);
    }

    private Optional<AdminUser> findUserByContactKey(String contactKey) {
        if (!StringUtils.hasText(contactKey)) {
            return Optional.empty();
        }
        String normalized = contactKey.trim();
        if (normalized.contains("@")) {
            Optional<AdminUser> byEmail = adminUserRepository.findByEmailIgnoreCase(normalized);
            if (byEmail.isPresent()) {
                return byEmail;
            }
        }
        return adminUserRepository.findFirstByPhoneIgnoreCase(normalized)
                .or(() -> adminUserRepository.findByEmailIgnoreCase(normalized));
    }

    private String displayName(AdminUser user) {
        String name = StringUtils.hasText(user.getFullName()) ? user.getFullName().trim() : user.getEmail();
        return TextEncodingSupport.repairUtf8Mojibake(name);
    }

    private String contactKeyFor(AdminUser user) {
        if (StringUtils.hasText(user.getPhone())) {
            return user.getPhone().trim();
        }
        return user.getEmail().trim().toLowerCase();
    }

    private void applyVisitorProfile(ChatSession session, String fullName, String contactKey) {
        session.setVisitorName(fullName);
        session.setVisitorPhone(contactKey);
    }

    private void addContactKey(Set<String> keys, String value) {
        if (StringUtils.hasText(value)) {
            keys.add(value.trim());
        }
    }

    private ChatMessageResponse sendAutomatedMessage(ChatSession session, String body) {
        ChatMessage message = persistMessage(session.getId(), ChatMessage.SENDER_ADMIN, null, body);
        session.setLastMessageAt(LocalDateTime.now());
        chatSessionRepository.save(session);

        ChatMessageResponse response = chatMapper.toMessageResponse(message, autoSenderName);
        publishMessage(session.getId(), response);
        return response;
    }

    private void maybeSendReceivedAcknowledgement(ChatSession session) {
        if (!autoMessagesEnabled || !StringUtils.hasText(receivedMessage)) {
            return;
        }
        if (chatMessageRepository.existsBySessionIdAndSenderTypeAndSenderAdminIdIsNotNull(
                session.getId(),
                ChatMessage.SENDER_ADMIN
        )) {
            return;
        }

        long automatedAdminMessages = chatMessageRepository.countBySessionIdAndSenderTypeAndSenderAdminIdIsNull(
                session.getId(),
                ChatMessage.SENDER_ADMIN
        );
        if (automatedAdminMessages != 1) {
            return;
        }

        sendAutomatedMessage(session, receivedMessage.trim());
    }

    private void publishMessage(Long sessionId, ChatMessageResponse message) {
        messagingTemplate.convertAndSend(SESSION_TOPIC_PREFIX + sessionId, message);
    }

    private void publishInboxEvent(String type, ChatSessionResponse session) {
        messagingTemplate.convertAndSend(ADMIN_INBOX_TOPIC, Map.of(
                "type", type,
                "session", session
        ));
    }

    private ChatSession getSession(Long id) {
        return chatSessionRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Chat session not found"));
    }

    private ChatSession getSessionByToken(String sessionToken) {
        if (sessionToken == null || sessionToken.isBlank()) {
            throw new BadRequestException("Session token is required");
        }
        return chatSessionRepository.findBySessionToken(sessionToken.trim())
                .orElseThrow(() -> new ResourceNotFoundException("Chat session not found"));
    }
}
