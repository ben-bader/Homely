package com.homely.moderation.controller;

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
import com.homely.common.enums.PropertyStatus;
import com.homely.common.enums.ReportStatus;
import com.homely.feedback.dto.FeedbackDto;
import com.homely.feedback.mapper.FeedbackMapper;
import com.homely.feedback.service.FeedbackService;
import com.homely.moderation.dto.AuditLogDto;
import com.homely.moderation.dto.ReportDto;
import com.homely.moderation.entity.Report;
import com.homely.moderation.mapper.AuditLogMapper;
import com.homely.moderation.service.ModerationService;
import com.homely.notification.ReportMapper;
import com.homely.property.dto.PropertyDto;
import com.homely.property.entity.Property;
import com.homely.property.mapper.PropertyMapper;
import com.homely.property.service.PropertyService;
import com.homely.propertyview.dto.PropertyViewDto;
import com.homely.propertyview.mapper.PropertyViewMapper;
import com.homely.propertyview.service.PropertyViewService;
import com.homely.user.dto.ProfileDto;
import com.homely.user.dto.UserDto;
import com.homely.user.entity.User;
import com.homely.user.mapper.ProfileMapper;
import com.homely.user.mapper.UserMapper;
import com.homely.user.service.ProfileService;
import com.homely.user.service.UserService;
import com.homely.visitrequest.dto.VisitRequestDto;
import com.homely.visitrequest.mapper.VisitRequestMapper;
import com.homely.visitrequest.service.VisitRequestService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {

    private final ModerationService moderationService;
    private final UserService userService;
    private final PropertyService propertyService;
    private final ProfileService profileService;
    private final BoostService boostService;
    private final PropertyViewService propertyViewService;
    private final FeedbackService feedbackService;
    private final VisitRequestService visitRequestService;

    private final ReportMapper reportMapper;
    private final AuditLogMapper auditLogMapper;
    private final UserMapper userMapper;
    private final ProfileMapper profileMapper;
    private final PropertyMapper propertyMapper;
    private final BoostPurchaseMapper boostPurchaseMapper;
    private final PropertyViewMapper propertyViewMapper;
    private final FeedbackMapper feedbackMapper;
    private final VisitRequestMapper visitRequestMapper;

    @GetMapping("/reports")
    public List<ReportDto> reports() {
        return moderationService.getReports().stream()
                .map(reportMapper::toDto)
                .toList();
    }

    @GetMapping("/reports/{id}")
    public ReportDto getReportById(@PathVariable UUID id) {
        return reportMapper.toDto(moderationService.getReportById(id));
    }

    @PutMapping("/reports/{id}/status")
public ReportDto updateReportStatus(
        @PathVariable UUID id,
        @RequestParam ReportStatus status,
        Principal principal) {

    User admin = userService.getByEmail(principal.getName());
    if (admin == null) throw new RuntimeException("Admin not found");

    Report updated = moderationService.updateReportStatus(id, status, admin);

    moderationService.logAction(
            "UPDATE_REPORT_STATUS",
            admin,
            "Changed report status to " + status
    );

    return reportMapper.toDto(updated);
}


    @GetMapping("/audit-logs")
    public List<AuditLogDto> getAuditLogs() {
        return moderationService.getAllAuditLogs().stream()
                .map(auditLogMapper::toDto)
                .toList();
    }

   

    @GetMapping("/users")
    public List<UserDto> getAllUsers() {
        return userService.getAll().stream().map(userMapper::toDto).toList();
    }

    @PutMapping("/users/{id}/activate")
public void activateUser(@PathVariable UUID id, Principal principal) {

    User admin = userService.getByEmail(principal.getName());
    if (admin == null) throw new RuntimeException("Admin not found");

    userService.activate(id);

    moderationService.logAction(
        "ACTIVATE_USER",
            admin,
            "Activated user account id: " + id
    );
}

    @PutMapping("/users/{id}/deactivate")
public void deactivateUser(@PathVariable UUID id, Principal principal) {

    User admin = userService.getByEmail(principal.getName());
    if (admin == null) throw new RuntimeException("Admin not found");

    userService.deactivate(id);

    moderationService.logAction(
            "DEACTIVATE_USER",
            admin,
            "Deactivated user account id:" + id
    );
}


    @GetMapping("/profiles")
    public List<ProfileDto> getAllProfiles() {
        return profileService.getAll().stream().map(profileMapper::toDto).toList();
    }

    @GetMapping("/boosts")
    public List<BoostPurchaseDto> getAllBoosts() {
        return boostService.getAll().stream().map(boostPurchaseMapper::toDto).toList();
    }

    @GetMapping("/properties")
    public List<PropertyDto> getAllProperties() {
        return propertyService.getAll();
    }

    @GetMapping("/property-views")
    public List<PropertyViewDto> getAllPropertyViews() {
        return propertyViewService.getAll().stream().map(propertyViewMapper::toDto).toList();
    }

    @GetMapping("/feedbacks")
    public List<FeedbackDto> getAllFeedbacks() {
        return feedbackService.getAll().stream().map(feedbackMapper::toDto).toList();
    }

    @GetMapping("/visit-requests")
    public List<VisitRequestDto> getAllVisitRequests() {
        return visitRequestService.getAll().stream().map(visitRequestMapper::toDto).toList();
    }

@PutMapping("/properties/{id}/status")
public PropertyDto updatePropertyStatus(
        @PathVariable UUID id,
        @RequestParam PropertyStatus status,
        Principal principal) {

    // Get the admin performing the action
    User admin = userService.getByEmail(principal.getName());
    if (admin == null) throw new RuntimeException("Admin not found");

    // Update the property status in the service
    Property updated = propertyService.updateStatus(id, status);

    // Log this action
    moderationService.logAction(
            "UPDATE_PROPERTY_STATUS",
            admin,
            "Changed property id " + id + " status to " + status
    );

    // Convert to DTO and return
    return propertyMapper.toDto(updated);
}

}
