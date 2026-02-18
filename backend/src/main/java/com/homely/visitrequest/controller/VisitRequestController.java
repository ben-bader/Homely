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
import com.homely.user.repository.UserRepository;
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

   
    @PutMapping("/{id}/status")
    public VisitRequestDto updateStatus(@PathVariable UUID id, @RequestParam VisitStatus status) {
        return visitRequestService.updateStatus(id, status);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable UUID id) {
        visitRequestService.delete(id);
    }

    // --- New endpoint for authenticated user to get their own requests ---
    @GetMapping("/my-requests")
    public List<VisitRequestDto> getMyRequests(Principal principal) {
        String email = principal.getName();
        return visitRequestService.getByUserEmail(email).stream()
                .map(visitRequestMapper::toDto)
                .toList();
    }

    // --- New endpoint for property seller to get all visit requests for their property ---
    @GetMapping("/property/{propertyId}/seller")
    public List<VisitRequestDto> getRequestsForPropertyAsSeller(
            @PathVariable UUID propertyId,
            Principal principal) {
        String sellerEmail = principal.getName();
        return visitRequestService.getByPropertyForSeller(propertyId, sellerEmail).stream()
                .map(visitRequestMapper::toDto)
                .toList();
    }
}
