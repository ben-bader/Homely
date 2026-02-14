package com.homely.moderation.dto;

import java.util.UUID;

import com.homely.common.base.BaseEntity;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AuditLogDto extends BaseEntity {
    private UUID adminId;
    private String action;
    private String details;
}
