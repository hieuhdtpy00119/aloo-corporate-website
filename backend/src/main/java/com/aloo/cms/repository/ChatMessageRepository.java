package com.aloo.cms.repository;

import com.aloo.cms.entity.ChatMessage;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ChatMessageRepository extends JpaRepository<ChatMessage, Long> {

    List<ChatMessage> findBySessionIdOrderByCreatedAtAsc(Long sessionId);

    long countBySessionIdAndSenderTypeAndReadAtIsNull(Long sessionId, String senderType);

    long countBySessionIdAndSenderTypeAndSenderAdminIdIsNull(Long sessionId, String senderType);

    boolean existsBySessionIdAndSenderTypeAndSenderAdminIdIsNotNull(Long sessionId, String senderType);

    long countBySessionIdAndSenderType(Long sessionId, String senderType);

    @Modifying
    @Query("""
            UPDATE ChatMessage message
            SET message.readAt = CURRENT_TIMESTAMP
            WHERE message.sessionId = :sessionId
              AND message.senderType = :senderType
              AND message.readAt IS NULL
            """)
    int markReadForSession(@Param("sessionId") Long sessionId, @Param("senderType") String senderType);
}
