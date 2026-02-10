package com.homely.moderation.controller;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.homely.moderation.dto.ReportDto;
import com.homely.moderation.entity.Report;
import com.homely.moderation.service.ModerationService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
public class AdminController {

    private final ModerationService moderationService;

    @GetMapping("/reports")
    public List<ReportDto> reports() {
        return moderationService.getReports().stream()
            .map(this::convertToDto)
            .toList();
    }

    private ReportDto convertToDto(Report report) {
        ReportDto dto = new ReportDto();
        dto.setId(report.getId());
        dto.setReporterId(report.getReporter().getId());
        dto.setReportedUserId(report.getReportedUser() != null ? report.getReportedUser().getId() : null);
        dto.setReportedPropertyId(report.getReportedProperty() != null ? report.getReportedProperty().getId() : null);
        dto.setReason(report.getReason());
        dto.setStatus(report.getStatus());
        dto.setReviewedByAdminId(report.getReviewedByAdmin() != null ? report.getReviewedByAdmin().getId() : null);
        return dto;
    }
}
