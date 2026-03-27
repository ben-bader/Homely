package com.homely.property.controller;

import java.math.BigDecimal;
import java.security.Principal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.homely.common.enums.ListingType;
import com.homely.common.enums.PropertyStatus;
import com.homely.common.enums.PropertyType;
import com.homely.property.dto.PropertyCreateRequest;
import com.homely.property.dto.PropertyDto;
import com.homely.property.dto.PropertyUpdateRequest;
import com.homely.property.service.PropertyService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/properties")
@RequiredArgsConstructor
public class PropertyController {

    private final PropertyService propertyService;

    // ✅ Create property
    @PostMapping
    public ResponseEntity<PropertyDto> create(
            @Valid @RequestBody PropertyCreateRequest request,
            Principal principal) {

        return ResponseEntity.ok(
                propertyService.create(request, principal.getName()));
    }

    // ✅ Homepage (scroll all properties)
    @GetMapping
    public List<PropertyDto> getAll() {
        return propertyService.getAll();
    }

    // ✅ Get one
    @GetMapping("/{id}")
    public PropertyDto get(@PathVariable UUID id) {
        return propertyService.get(id);
    }

    // ✅ FILTER
    @GetMapping("/filter")
    public List<PropertyDto> filter(
            @RequestParam(required = false) ListingType listingType,
            @RequestParam(required = false) PropertyType propertyType,
            @RequestParam(required = false) BigDecimal minPrice,
            @RequestParam(required = false) BigDecimal maxPrice,
            @RequestParam(required = false) String city,
            @RequestParam(required = false) Instant fromDate,
            @RequestParam(required = false) Instant toDate) {
        return propertyService.filter(
                listingType,
                propertyType,
                minPrice,
                maxPrice,
                city,
                fromDate,
                toDate);
    }

    // ✅ GLOBAL SEARCH
    @GetMapping("/search")
    public List<PropertyDto> search(@RequestParam String keyword) {
        return propertyService.search(keyword);
    }

    // ✅ Seller → My Listings
    @PreAuthorize("hasRole('SELLER')")
    @GetMapping("/my-listed")
    public List<PropertyDto> getMyListedProperties(Principal principal) {
        return propertyService.getBySellerEmail(principal.getName());
    }

    // ✅ Update status
    @PreAuthorize("hasRole('SELLER')")
    @PatchMapping("/{id}/status")
    public PropertyDto updateStatus(
            @PathVariable UUID id,
            @RequestParam PropertyStatus status) {

        return propertyService.updateStatus(id, status);
    }

    // ✅ Update property (seller only)
    @PreAuthorize("hasRole('SELLER')")
    @PutMapping("/{id}")
    public ResponseEntity<PropertyDto> update(
            @PathVariable UUID id,
            @Valid @RequestBody PropertyUpdateRequest request,
            Principal principal) {

        return ResponseEntity.ok(
                propertyService.update(id, request, principal.getName()));
    }

    // ✅ Delete
    @PreAuthorize("hasRole('SELLER')")
    @DeleteMapping("/{id}")
    public void delete(@PathVariable UUID id) {
        propertyService.delete(id);
    }
}
