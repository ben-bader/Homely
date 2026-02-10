package com.homely.moderation.dto;

import java.util.UUID;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AuditLogDto {
    private UUID id;
    private UUID adminId;
    private String action;
    private String details;
}
