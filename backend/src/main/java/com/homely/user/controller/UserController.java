package com.homely.user.controller;

import java.util.List;
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

import com.homely.common.enums.RoleType;
import com.homely.moderation.dto.ReportDto;
import com.homely.moderation.entity.Report;
import com.homely.moderation.service.ModerationService;
import com.homely.notification.ReportMapper;
import com.homely.property.service.PropertyService;
import com.homely.user.dto.UserDto;
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
    private final ReportMapper reportMapper;
    @GetMapping("/role/{role}")
    public List<UserDto> byRole(@PathVariable RoleType role) {
        return userService.getByRole(role).stream()
                .map(userMapper::toDto)
                .toList();
    }

    @GetMapping("/active/{isActive}")
    public List<UserDto> byActiveStatus(@PathVariable boolean isActive) {
        return userService.getByActiveStatus(isActive).stream()
                .map(userMapper::toDto)
                .toList();
    }
    @PostMapping("/reports")
    public ResponseEntity<ReportDto> createReport(@Valid @RequestBody ReportDto dto) {
        Report report = new Report();
        User reporter = userService.getById(dto.getReporterId());
        User reportedUser = dto.getReportedUserId() != null ? userService.getById(dto.getReportedUserId()) : null;
        var reportedProperty = dto.getReportedPropertyId() != null ? propertyService.getEntityById(dto.getReportedPropertyId()) : null;

        report.setReporter(reporter);
        report.setReportedUser(reportedUser);
        report.setReportedProperty(reportedProperty);
        report.setReason(dto.getReason());
        report.setStatus(dto.getStatus());
        report.setReviewedByAdmin(dto.getReviewedByAdminId() != null ? userService.getById(dto.getReviewedByAdminId()) : null);

        Report savedReport = moderationService.report(report);
        return new ResponseEntity<>(reportMapper.toDto(savedReport), HttpStatus.CREATED);
    }
    @DeleteMapping("/{id}")
    public void deactivate(@PathVariable UUID id) {
        userService.deactivate(id);
    }

    @PutMapping("/{id}")
    public void activate(@PathVariable UUID id) {
        userService.activate(id);
    }
}
