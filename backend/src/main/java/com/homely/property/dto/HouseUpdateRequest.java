package com.homely.property.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class HouseUpdateRequest {
    private int bedrooms;
    private int bathrooms;
    private boolean hasGarage;
    private Double landAreaSqm;
}
