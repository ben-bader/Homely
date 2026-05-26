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
public class UserGrowthResponse {
    private Map<String, Long> dailyRegistrations;
    private Map<String, Long> weeklyRegistrations;
    private Map<String, Long> monthlyRegistrations;
}
