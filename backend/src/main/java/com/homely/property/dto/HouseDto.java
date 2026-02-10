package com.homely.property.dto;

import java.util.UUID;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class HouseDto {
    private UUID propertyId;
    private int bedrooms;
    private int bathrooms;
    private boolean hasGarage;
    private Double landAreaSqm;
}
