package com.homely.moderation.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CreateReportReasonRequest {

    @NotBlank(message = "Reason code is required")
    @JsonProperty("reason")
    private String reason;

    @JsonProperty("name")
    private String name;

    @JsonProperty("description")
    private String description;

    @JsonProperty("active")
    private Boolean active;
}
