package com.homely.feedback.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class FeedbackUpdateRequest {
    private Integer rating;
    private String comment;
}
