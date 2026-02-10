package com.homely.moderation.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AuditLogCreateRequest {
    private String action;
    private String details;
}
