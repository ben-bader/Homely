package com.homely.user.controller;

import java.security.Principal;
import java.util.Map;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.homely.common.error.BadRequestException;
import com.homely.moderation.dto.CreateReportRequest;
import com.homely.moderation.dto.ReportDto;
import com.homely.moderation.entity.Report;
import com.homely.moderation.entity.ReportReason;
import com.homely.moderation.mapper.ReportMapper;
import com.homely.moderation.service.ModerationService;
import com.homely.moderation.service.ReportReasonService;
import com.homely.property.service.PropertyService;
import com.homely.user.dto.UserUpdateRequest;
import com.homely.user.entity.User;
import com.homely.user.mapper.UserMapper;
import com.homely.user.service.UserService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;


@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;
    private final UserMapper userMapper;
    private final PropertyService propertyService;
    private final ModerationService moderationService;
    private final ReportReasonService reportReasonService;
    private final ReportMapper reportMapper;

    @GetMapping("/{id}")
    public ResponseEntity<?> getUser(@PathVariable UUID id) {
        User user = userService.getById(id);
        return ResponseEntity.ok(userMapper.toDto(user));
    }
    
    ////////////////////////////////////////////////////////////
    // ✅ CREATE REPORT
    ////////////////////////////////////////////////////////////

    @PostMapping("/reports")
    public ResponseEntity<ReportDto> createReport(
            @Valid @RequestBody CreateReportRequest dto,
            Principal principal) {

        if (dto.getReportedUserId() == null && dto.getReportedPropertyId() == null) {
            throw new BadRequestException("A report must target either a user or a property.");
        }

        User reporter;
        if (principal != null && principal.getName() != null) {
            reporter = userService.getByEmail(principal.getName());
            if (reporter == null) {
                throw new BadRequestException("Authenticated reporter not found.");
            }
        } else if (dto.getReporterId() != null) {
            reporter = userService.getById(dto.getReporterId());
        } else {
            throw new BadRequestException("Reporter ID is required.");
        }

        ReportReason reportReason = reportReasonService.getReasonById(dto.getReportReasonId());
        if (reportReason == null) {
            throw new BadRequestException("Invalid report reason ID: " + dto.getReportReasonId());
        }
        if (!reportReason.isActive()) {
            throw new BadRequestException("Selected report reason is no longer available");
        }

        Report report = new Report();

        User reportedUser = dto.getReportedUserId() != null
                ? userService.getById(dto.getReportedUserId())
                : null;

        var reportedProperty = dto.getReportedPropertyId() != null
                ? propertyService.getEntityById(dto.getReportedPropertyId())
                : null;

        report.setReporter(reporter);
        report.setReportedUser(reportedUser);
        report.setReportedProperty(reportedProperty);
        report.setReportReason(reportReason);

        String reasonText = reportReason.getName();
        if (dto.getDetails() != null && !dto.getDetails().isBlank()) {
            reasonText = dto.getDetails();
        }
        report.setReason(reasonText);

        report.setStatus(com.homely.common.enums.ReportStatus.OPEN);
        report.setReviewedByAdmin(null);

        Report savedReport = moderationService.report(report);

        return new ResponseEntity<>(
                reportMapper.toDto(savedReport),
                HttpStatus.CREATED);
    }

    ////////////////////////////////////////////////////////////
    // ✅ UPDATE USER BASIC INFO (Admin or internal usage)
    ////////////////////////////////////////////////////////////

    @PutMapping("/{id}")
    public ResponseEntity<?> updateUser(
            @PathVariable UUID id,
            @Valid @RequestBody UserUpdateRequest request) {

        User updatedUser = userService.updateBasicInfo(id, request);

        return ResponseEntity.ok(userMapper.toDto(updatedUser));
    }

    ////////////////////////////////////////////////////////////
    // ✅ UPDATE FCM TOKEN FOR PUSH NOTIFICATIONS
    ////////////////////////////////////////////////////////////

    @PostMapping("/{id}/fcm-token")
    public ResponseEntity<Void> updateFcmToken(@PathVariable UUID id, @RequestBody Map<String, String> request) {
        String token = request.get("token");
        userService.updateFcmToken(id, token);
        return ResponseEntity.ok().build();
    }

    ////////////////////////////////////////////////////////////
    // ✅ DEACTIVATE USER
    ////////////////////////////////////////////////////////////

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deactivate(@PathVariable UUID id) {
        userService.deactivate(id);
        return ResponseEntity.noContent().build();
    }

    ////////////////////////////////////////////////////////////
    // ✅ ACTIVATE USER
    ////////////////////////////////////////////////////////////

    @PutMapping("/{id}/activate")
    public ResponseEntity<Void> activate(@PathVariable UUID id) {
        userService.activate(id);
        return ResponseEntity.noContent().build();
    }
}
