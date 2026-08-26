package com.homely.property.dto;

import java.util.UUID;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class VillaDto {
    private UUID propertyId;
    private int bedrooms;
    private int bathrooms;
    private Double landAreaSqm;
    private boolean hasPool;
}
