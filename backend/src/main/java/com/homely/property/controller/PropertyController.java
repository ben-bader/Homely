package com.homely.property.controller;

import java.math.BigDecimal;
import java.security.Principal;
import java.util.List;
import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.homely.common.enums.ListingType;
import com.homely.common.enums.PropertyType;
import com.homely.property.dto.PropertyCreateRequest;
import com.homely.property.dto.PropertyDto;
import com.homely.property.entity.Property;
import com.homely.property.service.PropertyService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/properties")
@RequiredArgsConstructor
public class PropertyController {

    private final PropertyService propertyService;

    @PostMapping
    public ResponseEntity<PropertyDto> create(@RequestBody PropertyCreateRequest request,Principal principal) {
        
        Property property = new Property();
        property.setTitle(request.getTitle());
        property.setDescription(request.getDescription());
        property.setPrice(request.getPrice());
        property.setCurrency(request.getCurrency());
        property.setListingType(request.getListingType());
        property.setPropertyType(request.getPropertyType());
        property.setStatus(request.getStatus());
        property.setAddress(request.getAddress());
        property.setLatitude(request.getLatitude());
        property.setLongitude(request.getLongitude());
        Property created = propertyService.create(property, principal.getName());
        return ResponseEntity.ok(convertToDto(created));
    }

    
    @GetMapping("/{id}")
    public PropertyDto get(@PathVariable UUID id) {
        return convertToDto(propertyService.get(id));
    }

    @GetMapping
    public List<PropertyDto> all() {
        return propertyService.getAll().stream()
            .map(this::convertToDto)
            .toList();
    }
    @GetMapping("/search")
    public List<PropertyDto> search(
            @RequestParam(required = false) ListingType type,
            @RequestParam(required = false) BigDecimal minPrice,
            @RequestParam(required = false) BigDecimal maxPrice,
            @RequestParam(required = false) String city
    ) {
        return propertyService.search(type, minPrice, maxPrice, city).stream()
            .map(this::convertToDto)
            .toList();
    }

    @GetMapping("/type/{propertyType}")
    public List<PropertyDto> findByPropertyType(@PathVariable PropertyType propertyType) {
        return propertyService.findByPropertyType(propertyType).stream()
            .map(this::convertToDto)
            .toList();
    }

    private PropertyDto convertToDto(Property property) {
        PropertyDto dto = new PropertyDto();
        dto.setId(property.getId());
        dto.setSellerId(property.getSeller().getId());
        dto.setTitle(property.getTitle());
        dto.setDescription(property.getDescription());
        dto.setPrice(property.getPrice());
        dto.setCurrency(property.getCurrency());
        dto.setListingType(property.getListingType());
        dto.setPropertyType(property.getPropertyType());
        dto.setStatus(property.getStatus());
        dto.setAddress(property.getAddress());
        dto.setLatitude(property.getLatitude());
        dto.setLongitude(property.getLongitude());
        return dto;
    }
}
