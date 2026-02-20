package com.homely.chat.dto;

import java.time.Instant;
import java.util.UUID;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class ChatMessageResponse {
    private Long id;
    private UUID conversationId;
    private String senderId;
    private String body;
    private Instant sentAt;
}
