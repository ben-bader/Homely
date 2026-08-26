package com.homely.boost.controller;

import java.security.Principal;
import java.util.List;
import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.homely.boost.dto.BoostPurchaseCreateRequest;
import com.homely.boost.dto.BoostPurchaseDto;
import com.homely.boost.mapper.BoostPurchaseMapper;
import com.homely.boost.service.BoostService;
import com.homely.common.enums.PurchaseStatus;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/boost")
@RequiredArgsConstructor
public class BoostController {

    private final BoostService boostService;
    private final BoostPurchaseMapper boostPurchaseMapper;

    // ✅ Create boost
    @PostMapping
    public BoostPurchaseDto create(
            @Valid @RequestBody BoostPurchaseCreateRequest request,
            Principal principal) {
        return boostService.create(request, principal.getName());
    }

    // ✅ Get boost by ID
    @GetMapping("/{id}")
    public BoostPurchaseDto getById(@PathVariable UUID id) {
        return boostPurchaseMapper.toDto(boostService.getById(id));
    }

    // ✅ Get boosts by status
    @GetMapping("/status")
    public List<BoostPurchaseDto> getByStatus(@RequestParam PurchaseStatus status) {
        return boostService.getByStatus(status).stream()
                .map(boostPurchaseMapper::toDto)
                .toList();
    }

    // ✅ Get seller's boosts
    @GetMapping("/my-boosts")
    public List<BoostPurchaseDto> getMyBoosts(Principal principal) {
        return boostService.getMyBoosts(principal.getName()).stream()
                .map(boostPurchaseMapper::toDto)
                .toList();
    }
    
    // ✅ Check if property is currently boosted
    @GetMapping("/property/{propertyId}/is-boosted")
    public ResponseEntity<Boolean> isPropertyBoosted(@PathVariable UUID propertyId) {
        return ResponseEntity.ok(boostService.isBoostActive(propertyId));
    }
    
    // ✅ Get active boost for a property
    @GetMapping("/property/{propertyId}/active")
    public ResponseEntity<?> getActiveBoostForProperty(@PathVariable UUID propertyId) {
        var boost = boostService.getActiveBoost(propertyId, java.time.Instant.now());
        if (boost == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(boostPurchaseMapper.toDto(boost));
    }
    
    // ✅ Update boost status (admin only)
    @PreAuthorize("hasRole('ADMIN')")
    @PutMapping("/{id}/status")
    public BoostPurchaseDto updateStatus(
            @PathVariable UUID id,
            @RequestParam PurchaseStatus status) {
        return boostService.updateStatus(id, status);
    }
    
    // ✅ Get all active boosts (for admin/analytics)
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/active")
    public List<BoostPurchaseDto> getAllActiveBoosts() {
        return boostService.getAllActiveBoosts()
                .stream()
                .map(boostPurchaseMapper::toDto)
                .toList();
    }
}
