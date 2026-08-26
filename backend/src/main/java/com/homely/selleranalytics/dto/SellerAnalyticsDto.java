package com.homely.selleranalytics.dto;

import java.math.BigDecimal;
import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Main analytics dashboard DTO for sellers
 * Contains aggregated statistics about property listings and engagement
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SellerAnalyticsDto {
    
    /// Total number of listings created by the seller
    private Long totalListings;
    
    /// Number of currently active listings (not sold, not archived)
    private Long activeListings;
    
    /// Total number of views across all properties
    private Long totalViews;
    
    /// Total number of messages received
    private Long totalMessages;
    
    /// Total number of visit requests
    private Long totalVisitRequests;
    
    /// Conversion rate from views to messages (percentage)
    private BigDecimal conversionRate;
    
    /// Top performing properties based on views and engagement
    private List<PropertyPerformanceDto> topPerformingProperties;
}
