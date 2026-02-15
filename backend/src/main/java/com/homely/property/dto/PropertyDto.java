package com.homely.property.dto;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.homely.common.enums.ListingType;
import com.homely.common.enums.PropertyType;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@JsonInclude(JsonInclude.Include.NON_NULL)
public class PropertyDto {

    private UUID id;
    private UUID sellerId;
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
    private Instant createdAt;
    private Instant updatedAt;

    private ApartmentDto apartment;
    private HouseDto house;
    private VillaDto villa;
    private StudioDto studio;
    private CommercialDto commercial;
    private LandDto land;
}
