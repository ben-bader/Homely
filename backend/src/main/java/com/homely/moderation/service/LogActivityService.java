package com.homely.moderation.service;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.homely.moderation.entity.LogActivity;
import com.homely.moderation.entity.LogActivity.ActivityType;
import com.homely.moderation.entity.LogActivity.EntityType;
import com.homely.moderation.repository.LogActivityRepository;
import com.homely.user.entity.User;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class LogActivityService {

    private final LogActivityRepository logActivityRepository;

    /**
     * Log a user activity
     *
     * @param user        User performing the action
     * @param activityType Type of activity (LOGIN, CREATE, UPDATE, DELETE, etc.)
     * @param entityType   Type of entity affected (USER, PROPERTY, REPORT, etc.)
     * @param entityId     ID of the entity affected
     * @param description  Human-readable description of the activity
     * @param changes      JSON string containing the changes made
     */
    public void log(User user, ActivityType activityType, EntityType entityType, UUID entityId,
                    String description, String changes) {
        LogActivity activity = new LogActivity();
        activity.setUser(user);
        activity.setActivityType(activityType);
        activity.setEntityType(entityType);
        activity.setEntityId(entityId);
        activity.setDescription(description);
        activity.setChanges(changes);

        logActivityRepository.save(activity);
        log.info("Logged activity: {} - {} for {} with id: {}", activityType, entityType, user.getEmail(),
                entityId);
    }

    /**
     * Log a user activity without changes
     */
    public void log(User user, ActivityType activityType, EntityType entityType, UUID entityId,
                    String description) {
        log(user, activityType, entityType, entityId, description, null);
    }

    /**
     * Log a user activity without entity ID or changes
     */
    public void log(User user, ActivityType activityType, String description) {
        log(user, activityType, null, null, description, null);
    }

    /**
     * Get all activities (sorted by most recent first)
     */
    public List<LogActivity> getAllActivities() {
        return logActivityRepository.findAllByOrderByCreatedAtDesc();
    }

    /**
     * Get activities by user
     */
    public List<LogActivity> getActivitiesByUser(UUID userId) {
        return logActivityRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    /**
     * Get activities by activity type
     */
    public List<LogActivity> getActivitiesByType(ActivityType activityType) {
        return logActivityRepository.findByActivityTypeOrderByCreatedAtDesc(activityType);
    }

    /**
     * Get activities by entity type
     */
    public List<LogActivity> getActivitiesByEntityType(EntityType entityType) {
        return logActivityRepository.findByEntityTypeOrderByCreatedAtDesc(entityType);
    }

    /**
     * Get activities for a specific entity
     */
    public List<LogActivity> getActivitiesForEntity(EntityType entityType, UUID entityId) {
        return logActivityRepository.findByEntityTypeAndEntityIdOrderByCreatedAtDesc(entityType, entityId);
    }

    /**
     * Get all login activities in descending order
     */
    public List<LogActivity> getLoginActivities() {
        return getActivitiesByType(ActivityType.LOGIN);
    }

    /**
     * Get all signup activities in descending order
     */
    public List<LogActivity> getSignupActivities() {
        return getActivitiesByType(ActivityType.SIGNUP);
    }

    /**
     * Get all property changes
     */
    public List<LogActivity> getPropertyActivities() {
        return getActivitiesByEntityType(EntityType.PROPERTY);
    }

    /**
     * Get all report activities
     */
    public List<LogActivity> getReportActivities() {
        return getActivitiesByEntityType(EntityType.REPORT);
    }

    /**
     * Get all user activities (suspensions, updates)
     */
    public List<LogActivity> getUserActivities() {
        return getActivitiesByEntityType(EntityType.USER);
    }

    /**
     * Get login count for a user
     */
    public long getLoginCountForUser(UUID userId) {
        return logActivityRepository.findByUserIdAndActivityTypeOrderByCreatedAtDesc(userId, ActivityType.LOGIN)
                .size();
    }

    /**
     * Delete all logs for testing purposes (use carefully)
     */
    public void clearAllLogs() {
        logActivityRepository.deleteAll();
        log.warn("All log activities have been cleared");
    }
}
