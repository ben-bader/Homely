package com.homely.feedback.dto;

import java.util.UUID;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class FeedbackCreateRequest {
    private UUID propertyId;
    private Integer rating;
    private String comment;
}
