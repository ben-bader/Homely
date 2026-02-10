package com.homely.chat.dto;

import java.util.Map;
import java.util.UUID;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MessageCreateRequest {
    private UUID conversationId;
    private String body;
    private Map<String, Object> attachments;
}
