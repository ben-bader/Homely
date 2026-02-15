package com.homely.visitrequest.controller;

import java.security.Principal;
import java.util.List;
import java.util.UUID;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.homely.common.enums.VisitStatus;
import com.homely.visitrequest.dto.VisitRequestCreateRequest;
import com.homely.visitrequest.dto.VisitRequestDto;
import com.homely.visitrequest.mapper.VisitRequestMapper;
import com.homely.visitrequest.service.VisitRequestService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/visit-requests")
@RequiredArgsConstructor
public class VisitRequestController {

    private final VisitRequestService visitRequestService;
    private final VisitRequestMapper visitRequestMapper;

    @PostMapping
    public VisitRequestDto create(
            @Valid @RequestBody VisitRequestCreateRequest request,
            Principal principal) {
        return visitRequestService.create(request, principal.getName());
    }

    @GetMapping("/{id}")
    public VisitRequestDto get(@PathVariable UUID id) {
        return visitRequestMapper.toDto(visitRequestService.get(id));
    }

    @GetMapping("/property/{propertyId}")
    public List<VisitRequestDto> getByProperty(@PathVariable UUID propertyId) {
        return visitRequestService.getByProperty(propertyId).stream()
                .map(visitRequestMapper::toDto)
                .toList();
    }

    @GetMapping("/user/{userId}")
    public List<VisitRequestDto> getByUser(@PathVariable UUID userId) {
        return visitRequestService.getByUser(userId).stream()
                .map(visitRequestMapper::toDto)
                .toList();
    }

    @GetMapping("/status")
    public List<VisitRequestDto> getByStatus(@RequestParam VisitStatus status) {
        return visitRequestService.getByStatus(status).stream()
                .map(visitRequestMapper::toDto)
                .toList();
    }

    @PutMapping("/{id}/status")
    public VisitRequestDto updateStatus(@PathVariable UUID id, @RequestParam VisitStatus status) {
        return visitRequestService.updateStatus(id, status);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable UUID id) {
        visitRequestService.delete(id);
    }
}