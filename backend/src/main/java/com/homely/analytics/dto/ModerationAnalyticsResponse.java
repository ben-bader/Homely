package com.homely.analytics.dto;

import java.util.List;
import java.util.Map;
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
public class ModerationAnalyticsResponse {
    private Map<String, Long> approvalsOverTime;
    private double rejectionRate;
    private List<AdminActivityDto> moderationActivity;
    private List<AuditLogItem> adminActivityLogs;
}
