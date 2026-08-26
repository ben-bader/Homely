package com.homely.moderation.dto;

import java.util.UUID;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ReportCreateRequest {
    private UUID reportedUserId;
    private UUID reportedPropertyId;
    private String reason;
}
