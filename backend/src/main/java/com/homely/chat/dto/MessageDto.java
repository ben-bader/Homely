package com.homely.chat.dto;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonProperty;

import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MessageDto {
    private Long id;
    @JsonProperty("conversationId")
    @JsonAlias({"conversationId", "conversation_id"})
    private UUID conversationId;
    @JsonProperty("senderId")
    @JsonAlias({"senderId", "sender_id"})
    private UUID senderId;
    @JsonProperty("senderName")
    private String senderName;
    @JsonAlias({"body", "content"})
    @NotBlank(message = "Message content must not be empty")
    private String text;
    private String body;
    @JsonProperty("messageType")
    @JsonAlias({"messageType", "message_type"})
    private String messageType;
    @JsonProperty("propertyId")
    @JsonAlias({"propertyId", "property_id"})
    private UUID propertyId;
    private Map<String, Object> attachments;
    private String readStatus;
    private Instant readAt;
    private Instant createdAt; // Timestamp when message was sent
    private Instant updatedAt;

    public void setConversationId(Object value) {
        if (value == null) {
            this.conversationId = null;
        } else if (value instanceof String) {
            String str = ((String) value).trim();
            if (str.isEmpty() || "null".equalsIgnoreCase(str)) {
                this.conversationId = null;
            } else {
                this.conversationId = UUID.fromString(str);
            }
        } else if (value instanceof UUID) {
            this.conversationId = (UUID) value;
        }
    }

    public void setPropertyId(Object value) {
        if (value == null) {
            this.propertyId = null;
        } else if (value instanceof String) {
            String str = ((String) value).trim();
            if (str.isEmpty() || "null".equalsIgnoreCase(str)) {
                this.propertyId = null;
            } else {
                this.propertyId = UUID.fromString(str);
            }
        } else if (value instanceof UUID) {
            this.propertyId = (UUID) value;
        }
    }

    public String getText() {
        return text != null ? text : body;
    }

    public String getBody() {
        return text != null ? text : body;
    }

    public void setBody(String body) {
        this.body = body;
        this.text = body;
    }

    @AssertTrue(message = "Either conversationId or propertyId must be provided")
    public boolean isValidConversationOrProperty() {
        return this.conversationId != null || this.propertyId != null;
    }
}
