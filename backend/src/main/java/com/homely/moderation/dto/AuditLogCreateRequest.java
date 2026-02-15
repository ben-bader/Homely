package com.homely.moderation.dto;

import com.jayway.jsonpath.internal.filter.ValueNodes.JsonNode;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AuditLogCreateRequest {
    private String action;
    private JsonNode details;
}
