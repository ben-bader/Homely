package com.homely.feedback.service;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.homely.feedback.dto.FeedbackCreateRequest;
import com.homely.feedback.dto.FeedbackDto;
import com.homely.feedback.entity.Feedback;
import com.homely.feedback.mapper.FeedbackMapper;
import com.homely.feedback.repository.FeedbackRepository;
import com.homely.property.repository.PropertyRepository;
import com.homely.user.service.UserService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class FeedbackService {

    private final FeedbackRepository feedbackRepository;
    private final FeedbackMapper feedbackMapper;
    private final UserService userService;
    private final PropertyRepository propertyRepository;

    public FeedbackDto create(FeedbackCreateRequest request, String userEmail) {
        var user = userService.getByEmail(userEmail);
        if (user == null) throw new RuntimeException("User not found: " + userEmail);
        var property = propertyRepository.findById(request.getPropertyId())
                .orElseThrow(() -> new RuntimeException("Property not found: " + request.getPropertyId()));
        Feedback entity = feedbackMapper.toEntity(request);
        entity.setUser(user);
        entity.setProperty(property);
        Feedback saved = feedbackRepository.save(entity);
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
}