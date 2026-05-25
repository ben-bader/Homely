package com.homely.websocket.interceptor;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.event.EventListener;
import org.springframework.messaging.simp.broker.BrokerAvailabilityEvent;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.messaging.SessionConnectedEvent;
import org.springframework.web.socket.messaging.SessionDisconnectEvent;
import org.springframework.web.socket.messaging.SessionSubscribeEvent;
import org.springframework.web.socket.messaging.SessionUnsubscribeEvent;

@Component
public class WebSocketEventListener {

    private static final Logger log = LoggerFactory.getLogger(WebSocketEventListener.class);

    @EventListener
    public void handleSessionConnected(SessionConnectedEvent event) {
        StompHeaderAccessor sha = StompHeaderAccessor.wrap(event.getMessage());
        log.info("WS CONNECTED session={} user={}", sha.getSessionId(), sha.getUser() != null ? sha.getUser().getName() : "anonymous");
    }

    @EventListener
    public void handleSessionSubscribe(SessionSubscribeEvent event) {
        StompHeaderAccessor sha = StompHeaderAccessor.wrap(event.getMessage());
        log.info("WS SUBSCRIBE session={} user={} dest={}", sha.getSessionId(), sha.getUser()!=null?sha.getUser().getName():"anonymous", sha.getDestination());
    }

    @EventListener
    public void handleSessionUnsubscribe(SessionUnsubscribeEvent event) {
        StompHeaderAccessor sha = StompHeaderAccessor.wrap(event.getMessage());
        log.info("WS UNSUBSCRIBE session={} user={}", sha.getSessionId(), sha.getUser()!=null?sha.getUser().getName():"anonymous");
    }

    @EventListener
    public void handleSessionDisconnect(SessionDisconnectEvent event) {
        StompHeaderAccessor sha = StompHeaderAccessor.wrap(event.getMessage());
        log.info("WS DISCONNECT session={} user={}", sha.getSessionId(), sha.getUser()!=null?sha.getUser().getName():"anonymous");
    }

    @EventListener
    public void handleBrokerAvailable(BrokerAvailabilityEvent event) {
        log.info("Broker availability changed: available={}", event.isBrokerAvailable());
    }
}
