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

import com.homely.common.dto.PageResponse;
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

    // ✅ Homepage (scroll all properties) - PAGINATED
    @GetMapping("/paginated")
    public ResponseEntity<PageResponse<PropertyDto>> getAllPaginated(
            @RequestParam(defaultValue = "0") Integer page,
            @RequestParam(defaultValue = "30") Integer pageSize) {
        return ResponseEntity.ok(propertyService.getAllPaginated(page, pageSize));
    }

    // ✅ Homepage (scroll all properties) - OLD ENDPOINT (kept for backward compatibility)
    @GetMapping
    public List<PropertyDto> getAll() {
        return propertyService.getAll();
    }

    // ✅ Get one
    @GetMapping("/{id}")
    public PropertyDto get(@PathVariable UUID id) {
        return propertyService.get(id);
    }

    // ✅ FILTER - PAGINATED
    @GetMapping("/filter/paginated")
    public ResponseEntity<PageResponse<PropertyDto>> filterPaginated(
            @RequestParam(required = false) ListingType listingType,
            @RequestParam(required = false) PropertyType propertyType,
            @RequestParam(required = false) BigDecimal minPrice,
            @RequestParam(required = false) BigDecimal maxPrice,
            @RequestParam(required = false) String city,
            @RequestParam(required = false) Instant fromDate,
            @RequestParam(required = false) Instant toDate,
            @RequestParam(defaultValue = "0") Integer page,
            @RequestParam(defaultValue = "30") Integer pageSize) {
        
        return ResponseEntity.ok(propertyService.filterPaginated(
                listingType, propertyType, minPrice, maxPrice, city, fromDate, toDate, page, pageSize));
    }

    // ✅ FILTER - OLD ENDPOINT
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

    // ✅ GLOBAL SEARCH - PAGINATED
    @GetMapping("/search/paginated")
    public ResponseEntity<PageResponse<PropertyDto>> searchPaginated(
            @RequestParam String keyword,
            @RequestParam(defaultValue = "0") Integer page,
            @RequestParam(defaultValue = "30") Integer pageSize) {
        return ResponseEntity.ok(propertyService.searchPaginated(keyword, page, pageSize));
    }

    // ✅ GLOBAL SEARCH - OLD ENDPOINT
    @GetMapping("/search")
    public List<PropertyDto> search(@RequestParam String keyword) {
        return propertyService.search(keyword);
    }

    // ✅ Seller → My Listings - PAGINATED
    @PreAuthorize("hasRole('SELLER')")
    @GetMapping("/my-listed/paginated")
    public ResponseEntity<PageResponse<PropertyDto>> getMyListedPropertiesPaginated(
            Principal principal,
            @RequestParam(defaultValue = "0") Integer page,
            @RequestParam(defaultValue = "30") Integer pageSize) {
        return ResponseEntity.ok(propertyService.getBySellerEmailPaginated(principal.getName(), page, pageSize));
    }

    // ✅ Seller → My Listings - OLD ENDPOINT
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
