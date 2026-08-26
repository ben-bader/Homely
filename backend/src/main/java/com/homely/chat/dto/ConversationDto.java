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
    // legacy client/seller removed; use participant IDs instead
    private UUID participantOneId;
    private UUID participantTwoId;
    // Display fields
    private String propertyTitle;
    private String participantOneName;
    private String participantTwoName;
    private String participantOneAvatar;
    private String participantTwoAvatar;
    private String lastMessage;
    private String lastMessageType;
    private Instant lastMessageAt;
    private int unreadCount;

    private Instant createdAt;
    private Instant updatedAt;
}
