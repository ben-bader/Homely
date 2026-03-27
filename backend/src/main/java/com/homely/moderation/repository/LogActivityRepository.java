package com.homely.moderation.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.homely.moderation.entity.LogActivity;
import com.homely.moderation.entity.LogActivity.ActivityType;
import com.homely.moderation.entity.LogActivity.EntityType;

public interface LogActivityRepository extends JpaRepository<LogActivity, UUID> {

    List<LogActivity> findAllByOrderByCreatedAtDesc();

    List<LogActivity> findByUserIdOrderByCreatedAtDesc(UUID userId);

    List<LogActivity> findByActivityTypeOrderByCreatedAtDesc(ActivityType activityType);

    List<LogActivity> findByEntityTypeOrderByCreatedAtDesc(EntityType entityType);

    List<LogActivity> findByEntityIdOrderByCreatedAtDesc(UUID entityId);

    List<LogActivity> findByUserIdAndActivityTypeOrderByCreatedAtDesc(UUID userId, ActivityType activityType);

    List<LogActivity> findByEntityTypeAndEntityIdOrderByCreatedAtDesc(EntityType entityType, UUID entityId);
}
