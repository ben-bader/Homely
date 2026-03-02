package com.homely.moderation.controller;

import java.security.Principal;
import java.util.List;
import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.homely.boost.dto.BoostPurchaseDto;
import com.homely.boost.entity.BoostPurchase;
import com.homely.boost.mapper.BoostPurchaseMapper;
import com.homely.boost.mapper.BoostPurchaseMapperImpl;
import com.homely.boost.service.BoostService;
import com.homely.common.enums.PropertyStatus;
import com.homely.common.enums.PurchaseStatus;
import com.homely.common.enums.ReportStatus;
import com.homely.feedback.dto.FeedbackDto;
import com.homely.feedback.mapper.FeedbackMapper;
import com.homely.feedback.service.FeedbackService;
import com.homely.moderation.dto.AuditLogDto;
import com.homely.moderation.dto.ReportDto;
import com.homely.moderation.entity.Report;
import com.homely.moderation.mapper.AuditLogMapper;
import com.homely.moderation.mapper.ReportMapper;
import com.homely.moderation.service.ModerationService;
import com.homely.property.dto.PropertyDto;
import com.homely.property.mapper.PropertyMapper;
import com.homely.property.repository.PropertyRepository;
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

    private final BoostPurchaseMapperImpl boostPurchaseMapperImpl;

    private final ModerationService moderationService;
    private final UserService userService;
    private final PropertyService propertyService;
    private final ProfileService profileService;
    private final BoostService boostService;
    private final PropertyViewService propertyViewService;
    private final FeedbackService feedbackService;
    private final VisitRequestService visitRequestService;
     private final PropertyRepository propertyRepository;

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
        if (admin == null)
            throw new RuntimeException("Admin not found");

        Report updated = moderationService.updateReportStatus(id, status, admin);

        moderationService.logAction(
                "UPDATE_REPORT_STATUS",
                admin,
                "Changed report status to " + status);

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
        if (admin == null)
            throw new RuntimeException("Admin not found");

        userService.activate(id);

        moderationService.logAction(
                "ACTIVATE_USER",
                admin,
                "Activated user account id: " + id);
    }

    @PutMapping("/users/{id}/deactivate")
    public void deactivateUser(@PathVariable UUID id, Principal principal) {

        User admin = userService.getByEmail(principal.getName());
        if (admin == null)
            throw new RuntimeException("Admin not found");

        userService.deactivate(id);

        moderationService.logAction(
                "DEACTIVATE_USER",
                admin,
                "Deactivated user account id:" + id);
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
    @GetMapping("/properties/{id}")
    public ResponseEntity<PropertyDto> getProperty(@PathVariable UUID id) {
        return propertyRepository.findById(id)
            .map(propertyMapper::toDto)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
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

        User admin = userService.getByEmail(principal.getName());
        if (admin == null)
            throw new RuntimeException("Admin not found");

        PropertyDto updated = propertyService.updateStatus(id, status);

        moderationService.logAction(
                "UPDATE_PROPERTY_STATUS",
                admin,
                "Changed property id " + id + " status to " + status);

        return updated;
    }

    @PutMapping("boosts/{id}/status")
    public BoostPurchaseDto updateBoostStatus(
            @PathVariable UUID id,
            @RequestParam PurchaseStatus status,
            Principal principal) {

        // Get admin user
        User admin = userService.getByEmail(principal.getName());
        if (admin == null)
            throw new RuntimeException("Admin not found");

        // Update the boost purchase status
        BoostPurchase boost = boostService.getById(id);
        boost.setStatus(status);
        BoostPurchaseDto updated = boostService.updateStatus(boost.getId(), status); // make sure save method exists in
                                                                                     // your service

        // Log audit
        moderationService.logAction(
                "UPDATE_BOOST_STATUS",
                admin,
                "Changed boost id " + id + " status to " + status);

        // Convert to DTO if needed
        return updated; // or use a mapper
    }
}
