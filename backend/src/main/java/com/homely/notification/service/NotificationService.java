package com.homely.notification.service;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.homely.notification.dto.NotificationCreateRequest;
import com.homely.notification.dto.NotificationDto;
import com.homely.notification.entity.Notification;
import com.homely.notification.mapper.NotificationMapper;
import com.homely.notification.repository.NotificationRepository;
import com.homely.user.entity.User;
import com.homely.user.service.UserService;
import com.homely.notification.service.MqttNotificationService;

import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final NotificationMapper notificationMapper;
    private final UserService userService;
    private final MqttNotificationService mqttNotificationService;

    @Transactional
    public NotificationDto create(NotificationCreateRequest request) {
        try {
            // Validate user exists
            User user = userService.getById(request.getUserId());
            if (user == null) {
                log.error("User not found with ID: {}", request.getUserId());
                throw new EntityNotFoundException("User not found with ID: " + request.getUserId());
            }

            // Check if a similar notification has already been sent
            java.util.Optional<Notification> existingOpt = notificationRepository
                    .findFirstByUserAndTypeAndSentTrue(user, request.getType());
            if (existingOpt.isPresent()) {
                log.info("Notification of type '{}' already sent to user '{}'. Returning existing.", request.getType(), user.getEmail());
                return notificationMapper.toDto(existingOpt.get());
            }

            // Create and set notification properties
            Notification entity = new Notification();
            entity.setUser(user);
            entity.setType(request.getType());
            entity.setPayload(request.getPayload());
            entity.setRead(false);
            entity.setSent(false); // Initially mark as not sent

            // Save notification to database first
            Notification saved = notificationRepository.save(entity);

            log.info("Notification created successfully - ID: {}, Type: {}, User: {}", 
                saved.getId(), request.getType(), user.getEmail());

            // Send push notification if user has FCM token
            if (user.getFcmToken() != null && !user.getFcmToken().isEmpty()) {
                sendPushNotification(user, request.getType(), request.getPayload());
                saved.setSent(true); // Mark as sent after successful push
                notificationRepository.save(saved); // Update the notification
            } else {
                log.debug("User {} has no FCM token, push notification not sent", user.getEmail());
            }

            return notificationMapper.toDto(saved);
        } catch (Exception e) {
            log.error("Error creating notification: {}", e.getMessage(), e);
            throw e;
        }
    }

    private void sendPushNotification(User user, String notificationType, String payload) {
        try {
            String title = getTitleForType(notificationType);

            Map<String, String> data = Map.of(
                "type", notificationType,
                "payload", payload
            );

            // MQTT topic can be user-specific (fallback to user ID if token is not available)
            String mqttTarget = user.getFcmToken() != null && !user.getFcmToken().isEmpty()
                    ? user.getFcmToken()
                    : user.getId().toString();

            mqttNotificationService.sendNotification(
                    mqttTarget,
                    title,
                    payload != null ? payload : "New notification",
                    data
            );

            log.info("MQTT notification sent to user: {} for type: {}", user.getEmail(), notificationType);
        } catch (Exception e) {
            log.error("Failed to send MQTT notification to user {}: {}", user.getEmail(), e.getMessage(), e);
            // Don't fail the notification creation if push fails
        }
    }

    private String getTitleForType(String type) {
        return switch (type) {
            case "NEW_CHAT_MESSAGE" -> "💬 New Message";
            case "CONVERSATION_CREATED" -> "💬 New Conversation";
            case "VISIT_REQUEST_CREATED" -> "👁️ Visit Request";
            case "VISIT_REQUEST_STATUS_CHANGED" -> "👁️ Visit Request Updated";
            case "PROPERTY_CREATED" -> "🏠 New Property";
            case "PROPERTY_STATUS_CHANGED" -> "🏠 Property Updated";
            case "BOOST_PURCHASED" -> "⚡ Boost Purchased";
            case "BOOST_STATUS_CHANGED" -> "⚡ Boost Updated";
            case "FEEDBACK_RECEIVED" -> "⭐ New Feedback";
            default -> "📬 Notification";
        };
    }

    public List<Notification> getUnreadNotifications(UUID userId) {
        return notificationRepository.findByUserIdAndReadFalse(userId);
    }

    @Transactional
    public NotificationDto markAsRead(UUID notificationId) {
        try {
            Notification notification = notificationRepository.findById(notificationId)
                    .orElseThrow(() -> new EntityNotFoundException("Notification not found: " + notificationId));
            notification.setRead(true);
            Notification saved = notificationRepository.save(notification);

            log.info("Notification marked as read - ID: {}", notificationId);

            return notificationMapper.toDto(saved);
        } catch (Exception e) {
            log.error("Error marking notification as read: {}", e.getMessage(), e);
            throw e;
        }
    }

    public List<Notification> getAllByEmail(String email) {
        try {
            List<Notification> notifications = notificationRepository.findByUserEmail(email);
            log.debug("Retrieved {} notifications for user: {}", notifications.size(), email);
            return notifications;
        } catch (Exception e) {
            log.error("Error getting notifications for email {}: {}", email, e.getMessage(), e);
            return List.of();
        }
    }

    public List<Notification> getUnreadByEmail(String email) {
        try {
            List<Notification> notifications = notificationRepository.findByUserEmailAndReadFalse(email);
            log.debug("Retrieved {} unread notifications for user: {}", notifications.size(), email);
            return notifications;
        } catch (Exception e) {
            log.error("Error getting unread notifications for email {}: {}", email, e.getMessage(), e);
            return List.of();
        }
    }
}

