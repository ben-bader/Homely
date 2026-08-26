package com.homely.analytics.dto;

import java.math.BigDecimal;
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
public class OverviewStatsResponse {
    private long totalUsers;
    private long totalProperties;
    private long totalPendingProperties;
    private long totalApprovedProperties;
    private long totalRejectedProperties;
    private long totalSoldProperties;
    private long totalChats;
    private long totalMessages;
    private long totalFavorites;
    private long totalNotifications;
    private long totalReports;
    private long totalBoostPurchases;
    private BigDecimal totalRevenue;
    private long activeUsersToday;
    private long activeUsersThisWeek;
    private long activeUsersThisMonth;
}
