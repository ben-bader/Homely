package com.homely.chat.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.homely.chat.entity.Message;

public interface MessageRepository extends JpaRepository<Message, Long> {
    List<Message> findByConversationIdOrderByCreatedAtAsc(UUID conversationId);
    Message findBySenderUsername(String Username);

    // count how many messages are attached to a conversation
    long countByConversationId(UUID conversationId);
}