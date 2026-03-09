package com.homely.notification.dto;

import java.time.Instant;
import java.util.UUID;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class NotificationDto {
    private UUID id;
    private UUID userId;
    private String type;
    private String payload;
    private boolean read;
    private Instant createdAt;
    private Instant updatedAt;
}
