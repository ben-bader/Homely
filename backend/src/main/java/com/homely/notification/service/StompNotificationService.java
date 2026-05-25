package com.homely.notification.service;

import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.ObjectMapper;

@Service
public class StompNotificationService {

    private static final Logger log = LoggerFactory.getLogger(StompNotificationService.class);

    private final SimpMessagingTemplate messagingTemplate;
    private final ObjectMapper objectMapper;

    public StompNotificationService(SimpMessagingTemplate messagingTemplate, ObjectMapper objectMapper) {
        this.messagingTemplate = messagingTemplate;
        this.objectMapper = objectMapper;
    }

    public void sendNotification(String targetUserId, String title, String body, Map<String, String> data) {
        if (targetUserId == null || targetUserId.isEmpty()) {
            log.warn("STOMP target user ID is empty, skipping notification");
            return;
        }

        try {
            Map<String, Object> payload = Map.of(
                    "title", title,
                    "body", body,
                    "data", data != null ? data : Map.of(),
                    "timestamp", System.currentTimeMillis()
            );

            String destination = "/topic/notifications/" + targetUserId;
            messagingTemplate.convertAndSend(destination, (Object) payload);

            log.info("Sent STOMP notification to user {} -> dest={} payloadKeys={}", targetUserId, destination, payload.keySet());

        } catch (Exception e) {
            log.error("Failed to send STOMP notification to user {}: {}", targetUserId, e.getMessage(), e);
        }
    }

    public void broadcastNotification(String title, String body, Map<String, String> data) {
        try {
            Map<String, Object> payload = Map.of(
                    "title", title,
                    "body", body,
                    "data", data != null ? data : Map.of(),
                    "timestamp", System.currentTimeMillis()
            );

            String dest = "/topic/notifications/broadcast";
            messagingTemplate.convertAndSend(dest, (Object) payload);

            log.info("Broadcast STOMP notification -> dest={} payloadKeys={}", dest, payload.keySet());

        } catch (Exception e) {
            log.error("Failed to broadcast STOMP notification: {}", e.getMessage(), e);
        }
    }
}
