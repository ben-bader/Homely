package com.homely.chat.dto;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MessageDto {
    private Long id;
    private UUID conversationId;
    private UUID senderId;
    private String body;
    private Map<String, Object> attachments;
    private Instant readAt;
    private Instant createdAt; // Timestamp when message was sent
}
