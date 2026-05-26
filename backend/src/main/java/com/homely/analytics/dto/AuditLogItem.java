package com.homely.analytics.dto;

import java.time.Instant;
import java.util.UUID;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AuditLogItem {
    private UUID id;
    private UUID userId;
    private String userName;
    private String userEmail;
    private String activityType;
    private String entityType;
    private String entityId;
    private String description;
    private String changes;
    private Instant createdAt;
}
