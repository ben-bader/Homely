package com.homely.feedback.controller;

import java.util.List;
import java.util.UUID;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.homely.feedback.dto.FeedbackCreateRequest;
import com.homely.feedback.dto.FeedbackDto;
import com.homely.feedback.entity.Feedback;
import com.homely.feedback.service.FeedbackService;
import com.homely.property.entity.Property;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/feedbacks")
@RequiredArgsConstructor
public class FeedbackController {

    private final FeedbackService feedbackService;

    @PostMapping
    public FeedbackDto create(@RequestBody FeedbackCreateRequest request) {
        Feedback feedback = new Feedback();
        Property property = new Property();
        property.setId(request.getPropertyId());
        feedback.setProperty(property);
        feedback.setRating(request.getRating());
        feedback.setComment(request.getComment());
        return convertToDto(feedbackService.create(feedback));
    }

    @GetMapping("/{id}")
    public FeedbackDto get(@PathVariable UUID id) {
        return convertToDto(feedbackService.get(id));
    }

    // `getAll` removed from this controller - admin-only listing moved to AdminController

    @GetMapping("/property/{propertyId}")
    public List<FeedbackDto> getByProperty(@PathVariable UUID propertyId) {
        return feedbackService.getByProperty(propertyId).stream()
            .map(this::convertToDto)
            .toList();
    }

    @GetMapping("/user/{userId}")
    public List<FeedbackDto> getByUser(@PathVariable UUID userId) {
        return feedbackService.getByUser(userId).stream()
            .map(this::convertToDto)
            .toList();
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable UUID id) {
        feedbackService.delete(id);
    }

    private FeedbackDto convertToDto(Feedback feedback) {
        FeedbackDto dto = new FeedbackDto();
        dto.setId(feedback.getId());
        dto.setUserId(feedback.getUser().getId());
        dto.setPropertyId(feedback.getProperty().getId());
        dto.setRating(feedback.getRating());
        dto.setComment(feedback.getComment());
        return dto;
    }
}