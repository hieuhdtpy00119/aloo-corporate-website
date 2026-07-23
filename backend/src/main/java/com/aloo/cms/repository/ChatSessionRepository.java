package com.aloo.cms.repository;

import com.aloo.cms.entity.ChatSession;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

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

    long countByAssignedAdminId(Long assignedAdminId);

    @Modifying
    @Query("UPDATE ChatSession session SET session.assignedAdminId = :newAdminId WHERE session.assignedAdminId = :oldAdminId")
    int transferAssignments(@Param("oldAdminId") Long oldAdminId, @Param("newAdminId") Long newAdminId);
}
