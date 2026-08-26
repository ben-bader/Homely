package com.homely.property.dto;

import java.util.UUID;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class StudioDto {
    private UUID propertyId;
    private boolean furnished;
}
