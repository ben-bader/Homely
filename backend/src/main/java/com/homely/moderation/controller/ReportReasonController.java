package com.homely.moderation.controller;

import java.util.List;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.homely.moderation.dto.CreateReportReasonRequest;
import com.homely.moderation.entity.ReportReason;
import com.homely.moderation.service.ReportReasonService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/report-reasons")
@RequiredArgsConstructor
public class ReportReasonController {
    private final ReportReasonService reportReasonService;

    /**
     * Get all report reasons (including inactive) - ADMIN ONLY
     */
    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public List<ReportReason> getAllReasons() {
        return reportReasonService.getAllReasons();
    }

    /**
     * Get only active report reasons - PUBLIC (for mobile and users)
     * Used by mobile app and users to select a reason for reporting
     */
    @GetMapping("/active")
    public List<ReportReason> getActiveReasons() {
        return reportReasonService.getActiveReasons();
    }

    /**
     * Get a specific report reason by ID
     */
    @GetMapping("/{id}")
    public ReportReason getReasonById(@PathVariable UUID id) {
        ReportReason reason = reportReasonService.getReasonById(id);
        if (reason == null) {
            throw new RuntimeException("Report reason not found: " + id);
        }
        return reason;
    }

    /**
     * Create a new report reason - ADMIN ONLY
     */
    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    @ResponseStatus(HttpStatus.CREATED)
    public ReportReason addReason(@RequestBody CreateReportReasonRequest request) {
        ReportReason reason = new ReportReason();
        reason.setReason(request.getReason());
        reason.setName(request.getName() != null ? request.getName() : request.getReason());
        reason.setDescription(request.getDescription());
        reason.setActive(request.getActive() == null ? true : request.getActive());
        return reportReasonService.addReason(reason);
    }

    /**
     * Update an existing report reason - ADMIN ONLY
     */
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ReportReason updateReason(
            @PathVariable UUID id,
            @RequestBody ReportReason reason) {
        return reportReasonService.updateReason(id, reason);
    }

    /**
     * Activate a report reason - ADMIN ONLY
     */
    @PutMapping("/{id}/activate")
    @PreAuthorize("hasRole('ADMIN')")
    public ReportReason activateReason(@PathVariable UUID id) {
        return reportReasonService.activateReason(id);
    }

    /**
     * Deactivate a report reason - ADMIN ONLY
     */
    @PutMapping("/{id}/deactivate")
    @PreAuthorize("hasRole('ADMIN')")
    public ReportReason deactivateReason(@PathVariable UUID id) {
        return reportReasonService.deactivateReason(id);
    }

    /**
     * Delete a report reason permanently - ADMIN ONLY
     */
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteReason(@PathVariable UUID id) {
        reportReasonService.deleteReason(id);
    }
}
