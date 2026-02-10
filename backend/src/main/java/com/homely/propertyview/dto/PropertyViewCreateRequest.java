package com.homely.propertyview.dto;

import java.util.UUID;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PropertyViewCreateRequest {
    private UUID propertyId;
    private String ipAddress;
}
