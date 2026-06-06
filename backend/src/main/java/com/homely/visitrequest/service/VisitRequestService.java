package com.homely.visitrequest.service;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.homely.common.enums.RoleType;
import com.homely.common.enums.VisitStatus;
import com.homely.notification.dto.NotificationCreateRequest;
import com.homely.notification.service.NotificationService;
import com.homely.property.entity.Property;
import com.homely.property.repository.PropertyRepository;
import com.homely.user.entity.User;
import com.homely.user.repository.UserRepository;
import com.homely.user.service.UserService;
import com.homely.visitrequest.dto.VisitRequestCreateRequest;
import com.homely.visitrequest.dto.VisitRequestDto;
import com.homely.visitrequest.entity.VisitRequest;
import com.homely.visitrequest.mapper.VisitRequestMapper;
import com.homely.visitrequest.repository.VisitRequestRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class VisitRequestService {

    private final VisitRequestRepository visitRequestRepository;
    private final VisitRequestMapper visitRequestMapper;
    private final UserService userService;
    private final PropertyRepository propertyRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;
    private final ObjectMapper objectMapper;


    public VisitRequestDto create(VisitRequestCreateRequest request, String userEmail) {
        User user = userService.getByEmail(userEmail);
        if (user == null) throw new RuntimeException("User not found: " + userEmail);
        var property = propertyRepository.findById(request.getPropertyId())
                .orElseThrow(() -> new RuntimeException("Property not found: " + request.getPropertyId()));
        VisitRequest entity = visitRequestMapper.toEntity(request);
        entity.setUser(user);
        entity.setProperty(property);
        entity.setStatus(VisitStatus.PENDING);
        VisitRequest saved = visitRequestRepository.save(entity);
        
        // Send notification to property seller
        sendVisitRequestNotification(user, property, saved, request.getRequestedDate());
        
        return visitRequestMapper.toDto(saved);
    }

    public VisitRequest get(UUID id) {
        return visitRequestRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("VisitRequest not found"));
    }

    public List<VisitRequest> getAll() {
        return visitRequestRepository.findAll();
    }

    public List<VisitRequest> getByProperty(UUID propertyId) {
        return visitRequestRepository.findByPropertyId(propertyId);
    }

    public List<VisitRequest> getBySellerEmail(String sellerEmail) {
        return visitRequestRepository.findByPropertySellerEmail(sellerEmail);
    }

    public List<VisitRequest> getByUser(User user) {
        return visitRequestRepository.findByUser(user);
    }

    public List<VisitRequest> getByStatus(VisitStatus status) {
        return visitRequestRepository.findByStatus(status);
    }

    public VisitRequestDto updateStatus(UUID id, VisitStatus status) {
        VisitRequest request = get(id);
        request.setStatus(status);
        VisitRequest saved = visitRequestRepository.save(request);

        // Send notification to the user who created the visit request
        sendVisitRequestStatusNotification(request, status);

        return visitRequestMapper.toDto(saved);
    }

    public VisitRequestDto updateStatus(UUID id, VisitStatus status, String userEmail) {
        VisitRequest request = get(id);
        validateSellerOrAdmin(request, userEmail);
        request.setStatus(status);
        VisitRequest saved = visitRequestRepository.save(request);

        // Send notification to the user who created the visit request
        sendVisitRequestStatusNotification(request, status);

        return visitRequestMapper.toDto(saved);
    }
    
    private void validateSellerOrAdmin(VisitRequest request, String userEmail) {
        if (userEmail == null) {
            return;
        }

        User currentUser = userService.getByEmail(userEmail);
        if (currentUser == null) {
            throw new RuntimeException("User not found: " + userEmail);
        }

        boolean isAdmin = currentUser.getRole() == RoleType.ADMIN;
        boolean isPropertySeller = request.getProperty() != null && request.getProperty().getSeller() != null
                && request.getProperty().getSeller().getEmail().equals(userEmail);

        if (!isAdmin && !isPropertySeller) {
            throw new RuntimeException("Unauthorized: only the property seller or admin can update this visit request");
        }
    }

    private void sendVisitRequestNotification(User user, Property property, VisitRequest visitRequest, java.time.LocalDateTime requestedDate) {
        try {
            String payload = objectMapper.writeValueAsString(new java.util.HashMap<String, Object>() {{
                put("visitorName", user.getName());
                put("visitorEmail", user.getEmail());
                put("propertyTitle", property.getTitle());
                put("propertyId", property.getId().toString());
                put("visitRequestId", visitRequest.getId().toString());
                put("requestedDate", requestedDate);
            }});
            
            NotificationCreateRequest notificationRequest = new NotificationCreateRequest();
            notificationRequest.setUserId(property.getSeller().getId());
            notificationRequest.setType("VISIT_REQUEST_CREATED");
            notificationRequest.setPayload(payload);
            
            notificationService.create(notificationRequest);
            log.info("Visit request notification sent to seller: {}", property.getSeller().getEmail());
        } catch (Exception e) {
            log.error("Failed to send visit request notification: {}", e.getMessage(), e);
        }
    }
    
    private void sendVisitRequestStatusNotification(VisitRequest visitRequest, VisitStatus status) {
        try {
            String payload = objectMapper.writeValueAsString(new java.util.HashMap<String, Object>() {{
                put("propertyTitle", visitRequest.getProperty().getTitle());
                put("propertyId", visitRequest.getProperty().getId().toString());
                put("visitRequestId", visitRequest.getId().toString());
                put("newStatus", status.name());
                put("message", "Your visit request for " + visitRequest.getProperty().getTitle() + " has been " + status.name().toLowerCase());
            }});
            
            NotificationCreateRequest notificationRequest = new NotificationCreateRequest();
            notificationRequest.setUserId(visitRequest.getUser().getId());
            notificationRequest.setType("VISIT_REQUEST_" + status.name());
            notificationRequest.setPayload(payload);
            
            notificationService.create(notificationRequest);
            log.info("Visit request status notification sent to user: {}", visitRequest.getUser().getEmail());
        } catch (Exception e) {
            log.error("Failed to send visit request status notification: {}", e.getMessage(), e);
        }
    }
        public List<VisitRequest> getByUserEmail(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        return visitRequestRepository.findByUser(user);
    }

    // --- New method: find requests for a property if current user is the seller ---
    public List<VisitRequest> getByPropertyForSeller(UUID propertyId, String sellerEmail) {
        Property property = propertyRepository.findById(propertyId)
                .orElseThrow(() -> new RuntimeException("Property not found"));

        if (!property.getSeller().getEmail().equals(sellerEmail)) {
            throw new RuntimeException("Unauthorized: You are not the seller of this property");
        }

        return getByProperty(property.getId());
    }

    public void delete(UUID id, String userEmail) {
        VisitRequest request = get(id);
        User currentUser = userService.getByEmail(userEmail);
        if (currentUser == null) {
            throw new RuntimeException("User not found: " + userEmail);
        }

        boolean isAdmin = currentUser.getRole() == RoleType.ADMIN;
        boolean isRequestOwner = request.getUser() != null && request.getUser().getEmail().equals(userEmail);
        boolean isPropertySeller = request.getProperty() != null && request.getProperty().getSeller() != null
                && request.getProperty().getSeller().getEmail().equals(userEmail);

        if (!isAdmin && !isRequestOwner && !isPropertySeller) {
            throw new RuntimeException("Unauthorized: only the request owner, property seller, or admin can delete this visit request");
        }

        visitRequestRepository.delete(request);
    }
}