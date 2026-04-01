package com.homely.notification.service;

import java.nio.charset.StandardCharsets;
import java.util.Map;

import org.eclipse.paho.client.mqttv3.MqttClient;
import org.eclipse.paho.client.mqttv3.MqttMessage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.ObjectMapper;

@Service
public class MqttNotificationService {

    private static final Logger log = LoggerFactory.getLogger(MqttNotificationService.class);

    private final MqttClient mqttClient;
    private final ObjectMapper objectMapper;

    @Value("${mqtt.topic.prefix:home/notifications}")
    private String topicPrefix;

    public MqttNotificationService(MqttClient mqttClient, ObjectMapper objectMapper) {
        this.mqttClient = mqttClient;
        this.objectMapper = objectMapper;
    }

    public void sendNotification(String targetTopicOrClientId, String title, String body, Map<String, String> data) {
        if (targetTopicOrClientId == null || targetTopicOrClientId.isEmpty()) {
            log.warn("MQTT target is empty, skipping notification");
            return;
        }

        try {
            String topic = topicPrefix + "/" + targetTopicOrClientId;

            Map<String, Object> payload = Map.of(
                    "title", title,
                    "body", body,
                    "data", data != null ? data : Map.of()
            );

            String json = objectMapper.writeValueAsString(payload);
            MqttMessage message = new MqttMessage(json.getBytes(StandardCharsets.UTF_8));
            message.setQos(1);
            message.setRetained(false);

            if (!mqttClient.isConnected()) {
                mqttClient.reconnect();
            }

            mqttClient.publish(topic, message);
            log.info("MQTT notification sent to topic {}", topic);

        } catch (Exception e) {
            log.error("Failed to send MQTT notification to {}: {}", targetTopicOrClientId, e.getMessage(), e);
        }
    }

    public void sendMulticast(java.util.List<String> targets, String title, String body, Map<String, String> data) {
        if (targets == null || targets.isEmpty()) {
            log.warn("No MQTT targets provided for multicast");
            return;
        }

        for (String target : targets) {
            sendNotification(target, title, body, data);
        }
    }
}
