package com.homely.propertyview.dto;

import java.time.Instant;
import java.util.UUID;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PropertyViewDto {
    private UUID id;
    private UUID userId;
    private UUID propertyId;
    private String ipAddress;

    private Instant createdAt;
    private Instant updatedAt;
}
