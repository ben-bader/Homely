package com.homely.property.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CommercialCreateRequest {
    private Double areaSqm;
    private String businessType;
}
