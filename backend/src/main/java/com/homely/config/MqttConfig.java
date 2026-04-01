package com.homely.config;

import org.eclipse.paho.client.mqttv3.MqttClient;
import org.eclipse.paho.client.mqttv3.MqttConnectOptions;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class MqttConfig {

    @Value("${mqtt.broker.uri:tcp://localhost:1883}")
    private String brokerUri;

    @Value("${mqtt.client.id:homely-backend}")
    private String clientId;

    @Bean
    public MqttClient mqttClient() throws Exception {
        MqttClient mqttClient = new MqttClient(brokerUri, clientId);

        MqttConnectOptions options = new MqttConnectOptions();
        options.setCleanSession(true);
        options.setAutomaticReconnect(true);

        mqttClient.connect(options);

        return mqttClient;
    }
}
