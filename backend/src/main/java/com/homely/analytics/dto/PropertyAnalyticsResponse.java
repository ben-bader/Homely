package com.homely.analytics.dto;

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
public class PropertyAnalyticsResponse {
    private Map<String, Long> propertiesByType;
    private Map<String, Long> propertiesByStatus;
    private Map<String, Long> propertiesByCity;
    private Map<String, Long> propertiesByListingType;
    private Map<String, Long> propertiesCreatedOverTime;
}
