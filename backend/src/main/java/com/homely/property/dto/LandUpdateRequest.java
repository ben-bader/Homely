package com.homely.property.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class LandUpdateRequest {
    private Double areaSqm;
    private boolean constructible;
}
