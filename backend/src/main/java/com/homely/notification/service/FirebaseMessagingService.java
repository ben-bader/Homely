package com.homely.notification.service;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class FirebaseMessagingService {

    public void sendNotification(String token, String title, String body, Map<String, String> data) {
        if (token == null || token.isEmpty()) {
            log.warn("FCM token is empty, skipping notification");
            return;
        }

        try {
            Message.Builder messageBuilder = Message.builder()
                    .setToken(token)
                    .setNotification(Notification.builder()
                            .setTitle(title)
                            .setBody(body)
                            .build());

            // Add custom data if provided
            if (data != null && !data.isEmpty()) {
                messageBuilder.putAllData(data);
            }

            String response = FirebaseMessaging.getInstance().send(messageBuilder.build());
            log.info("FCM message sent successfully. Message ID: {}", response);
        } catch (Exception e) {
            log.error("Failed to send FCM notification to token {}: {}", token, e.getMessage(), e);
        }
    }

    public void sendMulticast(java.util.List<String> tokens, String title, String body, Map<String, String> data) {
        if (tokens == null || tokens.isEmpty()) {
            log.warn("No FCM tokens provided for multicast");
            return;
        }

        try {
            Message.Builder messageBuilder = Message.builder()
                    .setNotification(Notification.builder()
                            .setTitle(title)
                            .setBody(body)
                            .build());

            if (data != null && !data.isEmpty()) {
                messageBuilder.putAllData(data);
            }

            Message message = messageBuilder.build();
            com.google.firebase.messaging.MulticastMessage multicastMessage =
                    com.google.firebase.messaging.MulticastMessage.builder()
                            .addAllTokens(tokens)
                            .setNotification(Notification.builder()
                                    .setTitle(title)
                                    .setBody(body)
                                    .build())
                            .putAllData(data != null ? data : Map.of())
                            .build();

            com.google.firebase.messaging.BatchResponse response =
                    FirebaseMessaging.getInstance().sendMulticast(multicastMessage);

            log.info("Multicast FCM sent to {} tokens. Success: {}, Failure: {}",
                    tokens.size(), response.getSuccessCount(), response.getFailureCount());
        } catch (Exception e) {
            log.error("Failed to send multicast FCM notification: {}", e.getMessage(), e);
        }
    }
}
