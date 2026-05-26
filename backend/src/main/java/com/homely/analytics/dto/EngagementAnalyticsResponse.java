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
public class EngagementAnalyticsResponse {
    private Map<String, Long> favoritesTrends;
    private Map<String, Long> notificationsTrends;
    private List<PropertyPerformanceDto> mostViewedProperties;
    private List<PropertyPerformanceDto> mostFavoritedProperties;
}
