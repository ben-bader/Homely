package com.homely.moderation.dto;

// ✅ CORRECT
import com.fasterxml.jackson.databind.JsonNode;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AuditLogCreateRequest {
    private String action;
    private JsonNode details;
}
