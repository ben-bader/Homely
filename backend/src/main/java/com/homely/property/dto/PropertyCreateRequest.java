package com.homely.property.dto;

import java.math.BigDecimal;

import com.homely.common.enums.ListingType;
import com.homely.common.enums.PropertyStatus;
import com.homely.common.enums.PropertyType;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@RequiredArgsConstructor
public class PropertyCreateRequest {

    @NotBlank
    private String title;
    private String description;
    @NotNull
    private BigDecimal price;
    private String currency;
    @NotNull
    private ListingType listingType;
    @NotNull
    private PropertyType propertyType;
    private PropertyStatus status;
    private String address;
    private Double latitude;
    private Double longitude;

    /** Optional nested DTO for property type APARTMENT */
    @Valid
    private ApartmentCreateRequest apartment;
    /** Optional nested DTO for property type HOUSE */
    @Valid
    private HouseCreateRequest house;
    /** Optional nested DTO for property type VILLA */
    @Valid
    private VillaCreateRequest villa;
    /** Optional nested DTO for property type STUDIO */
    @Valid
    private StudioCreateRequest studio;
    /** Optional nested DTO for property type COMMERCIAL */
    @Valid
    private CommercialCreateRequest commercial;
    /** Optional nested DTO for property type LAND */
    @Valid
    private LandCreateRequest land;
}
