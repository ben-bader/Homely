package com.homely.visitrequest.controller;

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
import com.homely.property.entity.Property;
import com.homely.visitrequest.dto.VisitRequestCreateRequest;
import com.homely.visitrequest.dto.VisitRequestDto;
import com.homely.visitrequest.entity.VisitRequest;
import com.homely.visitrequest.service.VisitRequestService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/visit-requests")
@RequiredArgsConstructor
public class VisitRequestController {

    private final VisitRequestService visitRequestService;

    @PostMapping
    public VisitRequestDto create(@RequestBody VisitRequestCreateRequest request) {
        VisitRequest visitRequest = new VisitRequest();
        Property property = new Property();
        property.setId(request.getPropertyId());
        visitRequest.setProperty(property);
        visitRequest.setRequestedDate(request.getRequestedDate());
        return convertToDto(visitRequestService.create(visitRequest));
    }

    @GetMapping("/{id}")
    public VisitRequestDto get(@PathVariable UUID id) {
        return convertToDto(visitRequestService.get(id));
    }

    // `getAll` removed from this controller - admin-only listing moved to AdminController

    @GetMapping("/property/{propertyId}")
    public List<VisitRequestDto> getByProperty(@PathVariable UUID propertyId) {
        return visitRequestService.getByProperty(propertyId).stream()
            .map(this::convertToDto)
            .toList();
    }

    @GetMapping("/user/{userId}")
    public List<VisitRequestDto> getByUser(@PathVariable UUID userId) {
        return visitRequestService.getByUser(userId).stream()
            .map(this::convertToDto)
            .toList();
    }

    @GetMapping("/status")
    public List<VisitRequestDto> getByStatus(@RequestParam VisitStatus status) {
        return visitRequestService.getByStatus(status).stream()
            .map(this::convertToDto)
            .toList();
    }

    @PutMapping("/{id}/status")
    public VisitRequestDto updateStatus(@PathVariable UUID id, @RequestParam VisitStatus status) {
        return convertToDto(visitRequestService.updateStatus(id, status));
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable UUID id) {
        visitRequestService.delete(id);
    }

    private VisitRequestDto convertToDto(VisitRequest visitRequest) {
        VisitRequestDto dto = new VisitRequestDto();
        dto.setId(visitRequest.getId());
        dto.setUserId(visitRequest.getUser().getId());
        dto.setPropertyId(visitRequest.getProperty().getId());
        dto.setRequestedDate(visitRequest.getRequestedDate());
        dto.setStatus(visitRequest.getStatus());
        return dto;
    }
}