package com.homely.feedback.service;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.homely.feedback.dto.FeedbackCreateRequest;
import com.homely.feedback.dto.FeedbackDto;
import com.homely.feedback.entity.Feedback;
import com.homely.feedback.mapper.FeedbackMapper;
import com.homely.feedback.repository.FeedbackRepository;
import com.homely.notification.dto.NotificationCreateRequest;
import com.homely.notification.service.NotificationService;
import com.homely.property.repository.PropertyRepository;
import com.homely.user.service.UserService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
@RequiredArgsConstructor
@Slf4j
public class FeedbackService {

    private static final Logger log = LoggerFactory.getLogger(FeedbackService.class);

    private final FeedbackRepository feedbackRepository;
    private final FeedbackMapper feedbackMapper;
    private final UserService userService;
    private final PropertyRepository propertyRepository;
    private final NotificationService notificationService;
    private final ObjectMapper objectMapper;

    public FeedbackDto create(FeedbackCreateRequest request, String userEmail) {
        var user = userService.getByEmail(userEmail);
        if (user == null) throw new RuntimeException("User not found: " + userEmail);
        var property = propertyRepository.findById(request.getPropertyId())
                .orElseThrow(() -> new RuntimeException("Property not found: " + request.getPropertyId()));
        Feedback entity = feedbackMapper.toEntity(request);
        entity.setUser(user);
        entity.setProperty(property);
        Feedback saved = feedbackRepository.save(entity);
        
        // Send notification to property seller about new feedback
        sendFeedbackReceivedNotification(user, property, saved, request);

        return feedbackMapper.toDto(saved);
    }

    public Feedback get(UUID id) {
        return feedbackRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Feedback not found"));
    }

    public List<Feedback> getAll() {
        return feedbackRepository.findAll();
    }

    public List<Feedback> getByProperty(UUID propertyId) {
        return feedbackRepository.findByPropertyId(propertyId);
    }

    public List<Feedback> getByUser(UUID userId) {
        return feedbackRepository.findByUserId(userId);
    }

    public void delete(UUID id) {
        feedbackRepository.deleteById(id);
    }
    
    private void sendFeedbackReceivedNotification(com.homely.user.entity.User user, com.homely.property.entity.Property property, Feedback feedback, FeedbackCreateRequest request) {
        try {
            String payload = objectMapper.writeValueAsString(new java.util.HashMap<String, Object>() {{
                put("reviewerName", user.getName());
                put("reviewerEmail", user.getEmail());
                put("propertyTitle", property.getTitle());
                put("propertyId", property.getId().toString());
                put("feedbackId", feedback.getId().toString());
                put("rating", request.getRating());
                put("commentPreview", request.getComment() != null && request.getComment().length() > 100 ?
                    request.getComment().substring(0, 100) + "..." : request.getComment());
            }});
            
            NotificationCreateRequest notificationRequest = new NotificationCreateRequest();
            notificationRequest.setUserId(property.getSeller().getId());
            notificationRequest.setType("FEEDBACK_RECEIVED");
            notificationRequest.setPayload(payload);
            notificationService.create(notificationRequest);
            
            log.info("Feedback received notification sent to seller: {}", property.getSeller().getEmail());
        } catch (Exception e) {
            log.error("Failed to send feedback notification: {}", e.getMessage(), e);
        }
    }
}