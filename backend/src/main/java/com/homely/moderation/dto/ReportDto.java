package com.homely.moderation.dto;

import java.util.UUID;

import com.homely.common.base.BaseEntity;
import com.homely.common.enums.ReportStatus;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ReportDto extends BaseEntity {
    private UUID reporterId;
    private UUID reportedUserId;
    private UUID reportedPropertyId;
    private String reason;
    private ReportStatus status;
    private UUID reviewedByAdminId;
}
