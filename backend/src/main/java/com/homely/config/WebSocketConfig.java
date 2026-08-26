package com.homely.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.ChannelRegistration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    private final StompAuthInterceptor stompAuthInterceptor;

    public WebSocketConfig(StompAuthInterceptor stompAuthInterceptor) {
        this.stompAuthInterceptor = stompAuthInterceptor;
    }

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        // Pure STOMP/WebSocket endpoint (NO SockJS for Flutter STOMP client compatibility)
        registry.addEndpoint("/ws")
                .setAllowedOriginPatterns("*"); // Allow all origins for dev/staging
        
        // Note: DO NOT add .withSockJS() - it's incompatible with Flutter's STOMP client
        // which expects raw WebSocket, not SockJS protocol
    }

    @Override
    public void configureMessageBroker(MessageBrokerRegistry registry) {
        // Support both topic broadcasts and queue destinations for future user-queues
        registry.enableSimpleBroker("/topic", "/queue");
        registry.setApplicationDestinationPrefixes("/app");
        registry.setUserDestinationPrefix("/user");
    }

    @Override
    public void configureClientInboundChannel(ChannelRegistration registration) {
        registration.interceptors(stompAuthInterceptor);
    }
}
