package com.homely.property.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ApartmentCreateRequest {
    private int bedrooms;
    private int bathrooms;
    private int floor;
    private boolean hasElevator;
}
