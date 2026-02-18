package com.homely.boost.controller;

import java.security.Principal;
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

    @PostMapping
    public BoostPurchaseDto create(
            @Valid @RequestBody BoostPurchaseCreateRequest request,
            Principal principal) {
        return boostService.create(request, principal.getName());
    }

    @GetMapping("/{id}")
    public BoostPurchaseDto getById(@PathVariable UUID id) {
        return boostPurchaseMapper.toDto(boostService.getById(id));
    }

    @GetMapping("/status")
    public List<BoostPurchaseDto> getByStatus(@RequestParam PurchaseStatus status) {
        return boostService.getByStatus(status).stream()
                .map(boostPurchaseMapper::toDto)
                .toList();
    }

    @GetMapping("/my-boosts")
    public List<BoostPurchaseDto> getMyBoosts(Principal principal) {
        return boostService.getMyBoosts(principal.getName()).stream()
                .map(boostPurchaseMapper::toDto)
                .toList();
    }
}
