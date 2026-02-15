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
import com.homely.property.service.PropertyService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/properties")
@RequiredArgsConstructor
public class PropertyController {

    private final PropertyService propertyService;

    @PostMapping
    public ResponseEntity<PropertyDto> create(
            @Valid @RequestBody PropertyCreateRequest request,
            Principal principal) {
        PropertyDto created = propertyService.create(request, principal.getName());
        return ResponseEntity.ok(created);
    }

    @GetMapping("/{id}")
    public PropertyDto get(@PathVariable UUID id) {
        return propertyService.get(id);
    }

    @GetMapping("/search")
    public List<PropertyDto> search(
            @RequestParam(required = false) ListingType type,
            @RequestParam(required = false) BigDecimal minPrice,
            @RequestParam(required = false) BigDecimal maxPrice,
            @RequestParam(required = false) String city
    ) {
        return propertyService.search(type, minPrice, maxPrice, city);
    }

    @GetMapping("/type/{propertyType}")
    public List<PropertyDto> findByPropertyType(@PathVariable PropertyType propertyType) {
        return propertyService.findByPropertyType(propertyType);
    }
}
