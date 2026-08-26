package com.homely.selleranalytics.dto;

import java.util.UUID;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * DTO representing a property's performance metrics
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PropertyPerformanceDto {
    
    /// Property ID
    private UUID propertyId;
    
    /// Property title/name
    private String propertyTitle;
    
    /// Total views for this property
    private Long viewCount;
    
    /// Total messages/inquiries for this property
    private Long messageCount;
    
    /// Total visit requests for this property
    private Long visitRequestCount;
}
