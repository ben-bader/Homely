package com.homely.property.dto;

import java.math.BigDecimal;

import com.homely.common.enums.ListingType;
import com.homely.common.enums.PropertyType;

import jakarta.validation.Valid;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PropertyUpdateRequest {

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

    @Valid
    private ApartmentUpdateRequest apartment;
    @Valid
    private HouseUpdateRequest house;
    @Valid
    private VillaUpdateRequest villa;
    @Valid
    private StudioUpdateRequest studio;
    @Valid
    private CommercialUpdateRequest commercial;
    @Valid
    private LandUpdateRequest land;
}
