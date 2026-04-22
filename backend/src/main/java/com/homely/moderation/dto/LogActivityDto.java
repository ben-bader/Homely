package com.homely.moderation.dto;

import java.util.UUID;

import org.apache.logging.log4j.CloseableThreadContext;

import com.homely.common.base.BaseEntity;
import com.homely.moderation.entity.LogActivity.ActivityType;
import com.homely.moderation.entity.LogActivity.EntityType;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class LogActivityDto extends BaseEntity {
    private UUID id;
    private UUID userId;
    private String userEmail;
    private String userName;
    private ActivityType activityType;
    private EntityType entityType;
    private UUID entityId;
    private String description;
    private String changes;
}
