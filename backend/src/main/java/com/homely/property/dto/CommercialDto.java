package com.homely.property.dto;

import java.util.UUID;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CommercialDto {
    private UUID propertyId;
    private Double areaSqm;
    private String businessType;
}
