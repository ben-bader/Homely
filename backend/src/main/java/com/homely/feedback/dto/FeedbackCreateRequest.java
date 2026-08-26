package com.homely.feedback.dto;

import java.util.UUID;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class FeedbackCreateRequest {

    @NotNull
    private UUID propertyId;
    @NotNull
    @Min(1)
    @Max(5)
    private Integer rating;
    private String comment;
}
