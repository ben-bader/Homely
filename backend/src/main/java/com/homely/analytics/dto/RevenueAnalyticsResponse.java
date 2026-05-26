package com.homely.analytics.dto;

import java.math.BigDecimal;
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
public class RevenueAnalyticsResponse {
    private BigDecimal boostPurchaseRevenue;
    private Map<String, BigDecimal> monthlyRevenue;
    private double revenueGrowth;
    private List<SellerRevenueDto> topSellers;
}
