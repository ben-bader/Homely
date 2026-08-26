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

import com.homely.chat.dto.ConversationDto;
import com.homely.chat.mapper.ConversationMapper;
import com.homely.chat.service.ChatService;
import com.homely.common.enums.PropertyStatus;
import com.homely.common.enums.ReportStatus;
import com.homely.feedback.dto.FeedbackDto;
import com.homely.feedback.mapper.FeedbackMapper;
import com.homely.feedback.service.FeedbackService;
import com.homely.moderation.dto.AuditLogDto;
import com.homely.moderation.dto.LogActivityDto;
import com.homely.moderation.dto.ReportDto;
import com.homely.moderation.entity.LogActivity;
import com.homely.moderation.entity.Report;
import com.homely.moderation.mapper.AuditLogMapper;
import com.homely.moderation.mapper.LogActivityMapper;
import com.homely.moderation.mapper.ReportMapper;
import com.homely.moderation.service.LogActivityService;
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

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {

    private final ModerationService moderationService;
    private final LogActivityService logActivityService;
    private final UserService userService;
    private final PropertyService propertyService;
    private final ProfileService profileService;
    private final ChatService chatService;
    private final PropertyViewService propertyViewService;
    private final FeedbackService feedbackService;
    private final PropertyRepository propertyRepository;

    private final ReportMapper reportMapper;
    private final AuditLogMapper auditLogMapper;
    private final LogActivityMapper logActivityMapper;
    private final UserMapper userMapper;
    private final ProfileMapper profileMapper;
    private final PropertyMapper propertyMapper;
    private final PropertyViewMapper propertyViewMapper;
    private final FeedbackMapper feedbackMapper;
    private final ConversationMapper conversationMapper;

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

    @GetMapping("/log-activities")
    public List<LogActivityDto> getLogActivities() {
        return moderationService.getAllLogActivities().stream()
                .map(logActivityMapper::toDto)
                .toList();
    }

    @GetMapping("/users")
    public List<UserDto> getAllUsers() {
        return userService.getAll().stream().map(userMapper::toDto).toList();
    }

    @PutMapping("/users/{id}/activate")
    public void activateUser(@PathVariable UUID id, Principal principal) {

        User admin = userService.getByEmail(principal.getName());
        userService.activate(id);
        User activatedUser = userService.getById(id);

        moderationService.logAction(
                "ACTIVATE_USER",
                admin,
                "Activated user account id: " + id);
        
        // Log admin action in the new system
        logActivityService.log(
            admin,
            LogActivity.ActivityType.APPROVE,
            LogActivity.EntityType.USER,
            id,
            "Admin reactivated user: " + activatedUser.getEmail(),
            "{\"userId\":\"" + id + "\",\"email\":\"" + activatedUser.getEmail() + "\"}"
        );
    }

    @PutMapping("/users/{id}/deactivate")
    public void deactivateUser(@PathVariable UUID id, Principal principal) {

        User admin = userService.getByEmail(principal.getName());
        if (admin == null)
            throw new RuntimeException("Admin not found");

        User deactivatedUser = userService.getById(id);
        userService.deactivate(id);

        moderationService.logAction(
                "DEACTIVATE_USER",
                admin,
                "Deactivated user account id:" + id);
        
        // Log admin action in the new system
        logActivityService.log(
            admin,
            LogActivity.ActivityType.SUSPEND,
            LogActivity.EntityType.USER,
            id,
            "Admin suspended user: " + deactivatedUser.getEmail(),
            "{\"userId\":\"" + id + "\",\"email\":\"" + deactivatedUser.getEmail() + "\"}"
        );
    }

    @GetMapping("/profiles")
    public List<ProfileDto> getAllProfiles() {
        return profileService.getAll().stream().map(profileMapper::toDto).toList();
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
        
        // Log admin action in the new system
        logActivityService.log(
            admin,
            LogActivity.ActivityType.UPDATE,
            LogActivity.EntityType.PROPERTY,
            id,
            "Admin updated property status to: " + status,
            "{\"propertyId\":\"" + id + "\",\"newStatus\":\"" + status + "\"}"
        );

        return updated;
    }

    @GetMapping("/conversations")
    public List<ConversationDto> getAllConversations() {
        return chatService.getAllConversations()
                .stream()
                .map(conversationMapper::toDto)
                .toList();
    }
    
}
