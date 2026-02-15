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
    private String reporterName;
    private String reporterEmail;
    private UUID reportedUserId;
    private String reportedUserName;
    private String reportedUserEmail;
    private UUID reportedPropertyId;
    private String reportedPropertyTitle;
    private String reason;
    private ReportStatus status;
    private UUID reviewedByAdminId;
    private String reviewedByAdminName;
    private String reviewedByAdminEmail;
}
