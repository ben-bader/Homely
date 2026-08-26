package com.homely.chat.dto;

import java.time.Instant;
import java.util.UUID;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class ChatMessageResponse {
    private Long id;
    private UUID conversationId;
    private String senderId;
    private String senderName;
    private String text;
    private String messageType;
    private UUID propertyId;
    private String propertyTitle;
    private String propertyImageUrl;
    private String propertyPrice;
    private String propertyLocation;
    private Instant readAt;
    private Instant sentAt;

    @JsonProperty("body")
    public String getBody() {
        return text;
    }
}
