package com.homely.moderation.dto;

import java.util.UUID;

import com.fasterxml.jackson.annotation.JsonProperty;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

/**
 * DTO for creating a new report
 * Clients must provide a reportReasonId that references an active ReportReason
 */
@Getter
@Setter
public class CreateReportRequest {
    
    @JsonProperty("reporterId")
    private UUID reporterId;

    @JsonProperty("reportedUserId")
    private UUID reportedUserId;

    @JsonProperty("reportedPropertyId")
    private UUID reportedPropertyId;

    @NotNull(message = "Report reason ID is required")
    @JsonProperty("reportReasonId")
    private UUID reportReasonId;

    /**
     * Optional: additional details or custom reason text
     * Only used if the selected reason is "Other"
     */
    @JsonProperty("details")
    private String details;
}
