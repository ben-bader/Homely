package com.homely.moderation.controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.homely.boost.dto.BoostPurchaseDto;
import com.homely.boost.entity.BoostPurchase;
import com.homely.boost.service.BoostService;
import com.homely.feedback.dto.FeedbackDto;
import com.homely.feedback.entity.Feedback;
import com.homely.feedback.service.FeedbackService;
import com.homely.moderation.dto.ReportDto;
import com.homely.moderation.entity.Report;
import com.homely.moderation.service.ModerationService;
import com.homely.property.dto.PropertyDto;
import com.homely.property.entity.Property;
import com.homely.property.service.PropertyService;
import com.homely.propertyview.dto.PropertyViewDto;
import com.homely.propertyview.entity.PropertyView;
import com.homely.propertyview.service.PropertyViewService;
import com.homely.user.dto.ProfileDto;
import com.homely.user.dto.UserDto;
import com.homely.user.entity.Profile;
import com.homely.user.entity.User;
import com.homely.user.service.ProfileService;
import com.homely.user.service.UserService;
import com.homely.visitrequest.dto.VisitRequestDto;
import com.homely.visitrequest.entity.VisitRequest;
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

    // Admin listing/management services
    private final ProfileService profileService;
    private final BoostService boostService;
    private final PropertyViewService propertyViewService;
    private final FeedbackService feedbackService;
    private final VisitRequestService visitRequestService;

    @GetMapping("/reports")
    public List<ReportDto> reports() {
        return moderationService.getReports().stream()
            .map(this::convertToDto)
            .toList();
    }

    @PostMapping("/reports")
    public ResponseEntity<ReportDto> createReport(@RequestBody ReportDto dto) {
        Report report = new Report();

        User reporter = userService.getById(dto.getReporterId());
        User reportedUser = dto.getReportedUserId() != null ? userService.getById(dto.getReportedUserId()) : null;
        Property reportedProperty = dto.getReportedPropertyId() != null ? propertyService.get(dto.getReportedPropertyId()) : null;

        report.setReporter(reporter);
        report.setReportedUser(reportedUser);
        report.setReportedProperty(reportedProperty);
        report.setReason(dto.getReason());
        report.setStatus(dto.getStatus());
        report.setReviewedByAdmin(dto.getReviewedByAdminId() != null ? userService.getById(dto.getReviewedByAdminId()) : null);

        Report savedReport = moderationService.report(report);
        return new ResponseEntity<>(convertToDto(savedReport), HttpStatus.CREATED);
    }

    // --- admin management endpoints merged from admin.AdminController ---
    @GetMapping("/users")
    public List<UserDto> getAllUsers() {
        return userService.getAll().stream().map(this::convertUserToDto).toList();
    }

    @PutMapping("/users/{id}/activate")
    public void activateUser(@PathVariable java.util.UUID id) {
        userService.activate(id);
    }

    @PutMapping("/users/{id}/deactivate")
    public void deactivateUser(@PathVariable java.util.UUID id) {
        userService.deactivate(id);
    }

    @GetMapping("/profiles")
    public List<ProfileDto> getAllProfiles() {
        return profileService.getAll().stream().map(this::convertProfileToDto).toList();
    }

    @GetMapping("/boosts")
    public List<BoostPurchaseDto> getAllBoosts() {
        return boostService.getAll().stream().map(this::convertBoostToDto).toList();
    }

    @GetMapping("/properties")
    public List<PropertyDto> getAllProperties() {
        return propertyService.getAll().stream().map(this::convertPropertyToDto).toList();
    }

    @GetMapping("/property-views")
    public List<PropertyViewDto> getAllPropertyViews() {
        return propertyViewService.getAll().stream().map(this::convertPropertyViewToDto).toList();
    }

    @GetMapping("/feedbacks")
    public List<FeedbackDto> getAllFeedbacks() {
        return feedbackService.getAll().stream().map(this::convertFeedbackToDto).toList();
    }

    @GetMapping("/visit-requests")
    public List<VisitRequestDto> getAllVisitRequests() {
        return visitRequestService.getAll().stream().map(this::convertVisitRequestToDto).toList();
    }

    // --- conversion helpers ---
    private UserDto convertUserToDto(User user) {
        UserDto dto = new UserDto();
        dto.setId(user.getId());
        dto.setEmail(user.getEmail());
        dto.setName(user.getName());
        dto.setPhone(user.getPhone());
        dto.setRole(user.getRole());
        dto.setActive(user.isActive());
        return dto;
    }

    private ProfileDto convertProfileToDto(Profile profile) {
        ProfileDto dto = new ProfileDto();
        dto.setUserId(profile.getUserId());
        dto.setBio(profile.getBio());
        dto.setAddress(profile.getAddress());
        dto.setVerified(profile.isVerified());
        dto.setIdDocumentUrl(profile.getIdDocumentUrl());
        return dto;
    }

    private BoostPurchaseDto convertBoostToDto(BoostPurchase boost) {
        BoostPurchaseDto dto = new BoostPurchaseDto();
        dto.setId(boost.getId());
        dto.setSellerId(boost.getSeller() != null ? boost.getSeller().getId() : null);
        dto.setPropertyId(boost.getProperty() != null ? boost.getProperty().getId() : null);
        dto.setAmount(boost.getAmount());
        dto.setCurrency(boost.getCurrency());
        dto.setDurationDays(boost.getDurationDays());
        dto.setStatus(boost.getStatus());
        dto.setPaymentProviderRef(boost.getPaymentProviderRef());
        return dto;
    }

    private PropertyDto convertPropertyToDto(Property property) {
        PropertyDto dto = new PropertyDto();
        dto.setId(property.getId());
        dto.setSellerId(property.getSeller() != null ? property.getSeller().getId() : null);
        dto.setTitle(property.getTitle());
        dto.setDescription(property.getDescription());
        dto.setPrice(property.getPrice());
        dto.setCurrency(property.getCurrency());
        dto.setListingType(property.getListingType());
        dto.setPropertyType(property.getPropertyType());
        dto.setStatus(property.getStatus());
        dto.setAddress(property.getAddress());
        dto.setLatitude(property.getLatitude());
        dto.setLongitude(property.getLongitude());
        return dto;
    }

    private PropertyViewDto convertPropertyViewToDto(PropertyView pv) {
        PropertyViewDto dto = new PropertyViewDto();
        dto.setId(pv.getId());
        dto.setUserId(pv.getUser() != null ? pv.getUser().getId() : null);
        dto.setPropertyId(pv.getProperty().getId());
        dto.setIpAddress(pv.getIpAddress());
        return dto;
    }

    private FeedbackDto convertFeedbackToDto(Feedback feedback) {
        FeedbackDto dto = new FeedbackDto();
        dto.setId(feedback.getId());
        dto.setUserId(feedback.getUser().getId());
        dto.setPropertyId(feedback.getProperty().getId());
        dto.setRating(feedback.getRating());
        dto.setComment(feedback.getComment());
        return dto;
    }

    private VisitRequestDto convertVisitRequestToDto(VisitRequest vr) {
        VisitRequestDto dto = new VisitRequestDto();
        dto.setId(vr.getId());
        dto.setUserId(vr.getUser().getId());
        dto.setPropertyId(vr.getProperty().getId());
        dto.setRequestedDate(vr.getRequestedDate());
        dto.setStatus(vr.getStatus());
        return dto;
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
