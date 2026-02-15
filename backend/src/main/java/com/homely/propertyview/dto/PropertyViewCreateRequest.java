package com.homely.propertyview.dto;

import java.util.UUID;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PropertyViewCreateRequest {

    @NotNull
    private UUID propertyId;
    private String ipAddress;
}
