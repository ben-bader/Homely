package com.homely.selleranalytics.dto;

import java.time.LocalDate;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * DTO representing property views over time (daily aggregation)
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ViewsOverTimeDto {
    
    /// Date of the views
    private LocalDate date;
    
    /// Number of views on this date
    private Long viewCount;
}
