package com.homely.feedback.controller;

import java.security.Principal;
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
import com.homely.feedback.mapper.FeedbackMapper;
import com.homely.feedback.service.FeedbackService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/feedbacks")
@RequiredArgsConstructor
public class FeedbackController {

    private final FeedbackService feedbackService;
    private final FeedbackMapper feedbackMapper;

    @PostMapping
    public FeedbackDto create(
            @Valid @RequestBody FeedbackCreateRequest request,
            Principal principal) {
        return feedbackService.create(request, principal.getName());
    }

    @GetMapping("/{id}")
    public FeedbackDto get(@PathVariable UUID id) {
        return feedbackMapper.toDto(feedbackService.get(id));
    }

    @GetMapping("/property/{propertyId}")
    public List<FeedbackDto> getByProperty(@PathVariable UUID propertyId) {
        return feedbackService.getByProperty(propertyId).stream()
                .map(feedbackMapper::toDto)
                .toList();
    }

    @GetMapping("/user/{userId}")
    public List<FeedbackDto> getByUser(@PathVariable UUID userId) {
        return feedbackService.getByUser(userId).stream()
                .map(feedbackMapper::toDto)
                .toList();
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable UUID id) {
        feedbackService.delete(id);
    }
}