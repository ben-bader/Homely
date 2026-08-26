package com.homely.chat.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.homely.chat.entity.Conversation;

public interface ConversationRepository extends JpaRepository<Conversation, UUID> {
    // Legacy client/seller based queries removed. Use participant-based queries.

    @Query("SELECT c FROM Conversation c WHERE (c.participantOne.id = :first AND c.participantTwo.id = :second) OR (c.participantOne.id = :second AND c.participantTwo.id = :first)")
    Optional<Conversation> findByParticipants(@Param("first") UUID participantOneId, @Param("second") UUID participantTwoId);

    @Query("SELECT c FROM Conversation c WHERE c.participantOne.id = :userId OR c.participantTwo.id = :userId")
    List<Conversation> findByParticipantOneIdOrParticipantTwoId(@Param("userId") UUID userId);
}
