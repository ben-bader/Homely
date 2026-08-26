package com.homely.feedback.dto;

import java.time.Instant;
import java.util.UUID;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class FeedbackDto {
    private UUID id;
    private UUID userId;
    private UUID propertyId;
    private Integer rating;
    private String comment;

    private Instant createdAt;
    private Instant updatedAt;
}
