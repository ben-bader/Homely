package com.homely.property.dto;

import java.math.BigDecimal;
import com.homely.common.enums.ListingType;
import com.homely.common.enums.PropertyType;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PropertyCreateRequest {
    private String title;
    private String description;
    private BigDecimal price;
    private String currency;
    private ListingType listingType;
    private PropertyType propertyType;
    private String status;
    private String address;
    private Double latitude;
    private Double longitude;
}
