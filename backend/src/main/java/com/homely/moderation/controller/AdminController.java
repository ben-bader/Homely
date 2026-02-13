package com.homely.moderation.controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.homely.moderation.dto.ReportDto;
import com.homely.moderation.entity.Report;
import com.homely.moderation.service.ModerationService;
import com.homely.property.entity.Property;
import com.homely.property.service.PropertyService;
import com.homely.user.entity.User;
import com.homely.user.service.UserService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
public class AdminController {

    private final ModerationService moderationService;
    private final UserService userService;
    private final PropertyService propertyService;
    @GetMapping("/reports")
    public List<ReportDto> reports() {
        return moderationService.getReports().stream()
            .map(this::convertToDto)
            .toList();
    }

    @PostMapping("/reports")
    public ResponseEntity<ReportDto> createReport(@RequestBody ReportDto dto) {
        Report report = new Report();

        // Assuming ModerationService can fetch users and property by UUID
        User reporter = userService.getById(dto.getReporterId());
        User reportedUser = dto.getReportedUserId() != null ? userService.getById(dto.getReportedUserId()) : null;
        Property reportedProperty = dto.getReportedPropertyId() != null ? propertyService.get(dto.getReportedPropertyId()) : null;

        report.setReporter(reporter);
        report.setReportedUser(reportedUser);
        report.setReportedProperty(reportedProperty);
        report.setReason(dto.getReason());
        report.setStatus(dto.getStatus());
        // Optional: reviewedByAdmin can be null initially
        report.setReviewedByAdmin(dto.getReviewedByAdminId() != null ? userService.getById(dto.getReviewedByAdminId()) : null);

        Report savedReport = moderationService.report(report);
        return new ResponseEntity<>(convertToDto(savedReport), HttpStatus.CREATED);
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
