package com.homely.selleranalytics.dto;

import java.time.LocalDate;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * DTO representing messages received over time (daily aggregation)
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MessagesOverTimeDto {
    
    /// Date of the messages
    private LocalDate date;
    
    /// Number of messages received on this date
    private Long messageCount;
}
