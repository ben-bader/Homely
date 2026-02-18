package com.homely.property.dto;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.homely.common.enums.ListingType;
import com.homely.common.enums.PropertyStatus;
import com.homely.common.enums.PropertyType;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@RequiredArgsConstructor
@AllArgsConstructor
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
    private PropertyStatus status;
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

    /**
     * Projection constructor used by {@link com.homely.property.repository.PropertyRepository#findPropertyDtoById}.
     * Matches the JPQL constructor expression:
     *   new com.homely.property.dto.PropertyDto(p.id, p.address, p.price, p.listingType, s.id)
     */
    public PropertyDto(UUID id, String address, BigDecimal price, ListingType listingType, UUID sellerId) {
        this.id = id;
        this.address = address;
        this.price = price;
        this.listingType = listingType;
        this.sellerId = sellerId;
    }
}
