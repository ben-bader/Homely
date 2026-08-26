package com.homely.boost.controller;

import java.security.Principal;
import java.util.List;
import java.util.UUID;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.homely.boost.dto.BoostPurchaseDto;
import com.homely.boost.mapper.BoostPurchaseMapper;
import com.homely.boost.service.BoostService;
import com.homely.common.enums.PurchaseStatus;
import com.homely.moderation.service.ModerationService;
import com.homely.user.entity.User;
import com.homely.user.service.UserService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/admin/boosts")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminBoostController {

    private final BoostService boostService;
    private final BoostPurchaseMapper boostPurchaseMapper;
    private final ModerationService moderationService;
    private final UserService userService;

    @GetMapping
    public List<BoostPurchaseDto> getAll(@RequestParam(required = false) PurchaseStatus status) {
        return (status == null ? boostService.getAll() : boostService.getByStatus(status)).stream()
                .map(boostPurchaseMapper::toDto)
                .toList();
    }

    @PutMapping("/{id}/status")
    public BoostPurchaseDto updateStatus(
            @PathVariable UUID id,
            @RequestParam PurchaseStatus status,
            Principal principal) {
        User admin = userService.getByEmail(principal.getName());
        if (admin == null) {
            throw new RuntimeException("Admin user not found: " + principal.getName());
        }

        BoostPurchaseDto updated = boostService.updateStatus(id, status);

        moderationService.logAction(
                "UPDATE_BOOST_STATUS",
                admin,
                "Changed boost id " + id + " status to " + status);

        return updated;
    }
}
