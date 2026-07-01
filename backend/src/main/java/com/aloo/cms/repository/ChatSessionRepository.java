package com.aloo.cms.repository;

import com.aloo.cms.entity.ChatSession;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ChatSessionRepository extends JpaRepository<ChatSession, Long> {

    Optional<ChatSession> findBySessionToken(String sessionToken);

    Optional<ChatSession> findFirstByVisitorPhoneIgnoreCaseAndStatusInOrderByUpdatedAtDesc(
            String visitorPhone,
            Iterable<String> statuses
    );

    List<ChatSession> findByVisitorPhoneIgnoreCaseInAndStatusIn(
            Collection<String> visitorPhones,
            Collection<String> statuses
    );
}
