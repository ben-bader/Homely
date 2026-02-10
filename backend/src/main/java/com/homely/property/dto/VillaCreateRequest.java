package com.homely.property.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class VillaCreateRequest {
    private int bedrooms;
    private int bathrooms;
    private Double landAreaSqm;
    private boolean hasPool;
}
