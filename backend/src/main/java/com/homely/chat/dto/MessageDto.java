package com.homely.chat.dto;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

import com.fasterxml.jackson.annotation.JsonAlias;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MessageDto {
    private Long id;
    private UUID conversationId;
    private UUID senderId;
    private String senderName;
    @JsonAlias({"body"})
    private String text;
    private String body;
    private String messageType;
    private UUID propertyId;
    private Map<String, Object> attachments;
    private String readStatus;
    private Instant readAt;
    private Instant createdAt; // Timestamp when message was sent
    private Instant updatedAt;

    public String getText() {
        return text != null ? text : body;
    }

    public String getBody() {
        return text != null ? text : body;
    }

    public void setBody(String body) {
        this.text = body;
    }
}
