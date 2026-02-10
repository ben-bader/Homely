package com.homely.boost.controller;

import java.util.List;
import java.util.UUID;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.homely.boost.dto.BoostPurchaseCreateRequest;
import com.homely.boost.dto.BoostPurchaseDto;
import com.homely.boost.entity.BoostPurchase;
import com.homely.boost.service.BoostService;
import com.homely.common.enums.PurchaseStatus;

import lombok.RequiredArgsConstructor;


@RestController
@RequestMapping("/api/boost")
@RequiredArgsConstructor
public class BoostController {

    private final BoostService boostService;

    @PostMapping
    public BoostPurchaseDto boost(@RequestBody BoostPurchaseCreateRequest request) {
        BoostPurchase boost = new BoostPurchase();
        boost.setAmount(request.getAmount());
        boost.setCurrency(request.getCurrency());
        boost.setDurationDays(request.getDurationDays());
        boost.setPaymentProviderRef(request.getPaymentProviderRef());
        return convertToDto(boostService.create(boost));
    }
    @GetMapping("/{id}")
    public BoostPurchaseDto getById(@PathVariable UUID id) {
        return convertToDto(boostService.getById(id));
    }
    @GetMapping("/status")
    public List<BoostPurchaseDto> getByStatus(@RequestParam PurchaseStatus status) {
        return boostService.getByStatus(status).stream()
            .map(this::convertToDto)
            .toList();
    }

    @GetMapping("/seller")
    public List<BoostPurchaseDto> getBySellerId(@RequestParam UUID sellerId) {
        return boostService.getBySellerId(sellerId).stream()
            .map(this::convertToDto)
            .toList();
    }
    @GetMapping("/all")
    public List<BoostPurchaseDto> getAll() {
        return boostService.getAll().stream()
            .map(this::convertToDto)
            .toList();
    }

    private BoostPurchaseDto convertToDto(BoostPurchase boost) {
        BoostPurchaseDto dto = new BoostPurchaseDto();
        dto.setId(boost.getId());
        dto.setSellerId(boost.getSeller().getId());
        dto.setPropertyId(boost.getProperty().getId());
        dto.setAmount(boost.getAmount());
        dto.setCurrency(boost.getCurrency());
        dto.setDurationDays(boost.getDurationDays());
        dto.setStatus(boost.getStatus());
        dto.setPaymentProviderRef(boost.getPaymentProviderRef());
        return dto;
    }
    
    
}
