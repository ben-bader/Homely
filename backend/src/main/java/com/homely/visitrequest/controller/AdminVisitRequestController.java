package com.homely.visitrequest.controller;

import java.util.List;
import java.util.UUID;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.homely.common.enums.VisitStatus;
import com.homely.visitrequest.dto.VisitRequestDto;
import com.homely.visitrequest.mapper.VisitRequestMapper;
import com.homely.visitrequest.service.VisitRequestService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/admin/visit-requests")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminVisitRequestController {

    private final VisitRequestService visitRequestService;
    private final VisitRequestMapper visitRequestMapper;

    @GetMapping
    public List<VisitRequestDto> getAll(@RequestParam(required = false) VisitStatus status) {
        return (status == null ? visitRequestService.getAll() : visitRequestService.getByStatus(status)).stream()
                .map(visitRequestMapper::toDto)
                .toList();
    }

    @PutMapping("/{id}/status")
    public VisitRequestDto updateStatus(@PathVariable UUID id, @RequestParam VisitStatus status) {
        return visitRequestService.updateStatus(id, status);
    }
}
