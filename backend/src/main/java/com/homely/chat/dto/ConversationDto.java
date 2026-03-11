package com.homely.chat.dto;

import java.time.Instant;
import java.util.UUID;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ConversationDto {
    private UUID id;
    private UUID propertyId;
    private UUID clientId;
    private UUID sellerId;
    
    // Display fields
    private String propertyTitle;
    private String sellerName;
    private String clientName;                // ← include both sides
    private String sellerAvatar;
    private String clientAvatar;
    private String lastMessage;
    private Instant lastMessageAt;
    private int unreadCount;

    private Instant createdAt;
    private Instant updatedAt;
}
