package com.homely.feedback.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.homely.feedback.entity.Feedback;

public interface FeedbackRepository extends JpaRepository<Feedback, UUID> {
    List<Feedback> findByPropertyId(UUID propertyId);
    List<Feedback> findByUserId(UUID userId);
}