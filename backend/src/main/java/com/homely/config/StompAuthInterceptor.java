package com.homely.config;

import java.util.List;
import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.messaging.support.MessageHeaderAccessor;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.stereotype.Component;

import com.homely.auth.service.JwtService;
import com.homely.user.entity.User;
import com.homely.user.service.UserService;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class StompAuthInterceptor implements ChannelInterceptor {

    private static final Logger log = LoggerFactory.getLogger(StompAuthInterceptor.class);

    private final JwtService jwtService;
    private final UserService userService;

    @Override
    public Message<?> preSend(Message<?> message, MessageChannel channel) {

        StompHeaderAccessor accessor = MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);

        if (accessor == null) return message;

        StompCommand command = accessor.getCommand();
        String sessionId = accessor.getSessionId();
        String destination = accessor.getDestination();
        String userInfo = accessor.getUser() != null ? accessor.getUser().getName() : "anonymous";

        log.debug("STOMP preSend: cmd={}, session={}, user={}, dest={}", command, sessionId, userInfo, destination);

        // Handle CONNECT — extract Authorization header and populate Principal
        if (StompCommand.CONNECT.equals(command)) {
            String authHeader = accessor.getFirstNativeHeader("Authorization");

            if (authHeader != null && authHeader.startsWith("Bearer ")) {
                try {
                    String token = authHeader.substring(7);
                    String email = jwtService.extractUsername(token);
                    if (email != null) {
                        User user = userService.getByEmail(email);
                            if (user != null && jwtService.isTokenValid(token, user) && user.isActive()) {
                            List<String> roles = jwtService.extractRoles(token);
                            List<SimpleGrantedAuthority> authorities = roles.stream()
                                .map(SimpleGrantedAuthority::new)
                                .collect(Collectors.toList());

                            UsernamePasswordAuthenticationToken auth =
                                new UsernamePasswordAuthenticationToken(
                                    user.getEmail(),
                                    null,
                                    authorities
                                );

                            accessor.setUser(auth);
                            log.info("STOMP CONNECT authenticated session={} user={}", sessionId, user.getEmail());
                            } else {
                            log.warn("STOMP CONNECT authentication failed for token user={}, session={}", email, sessionId);
                            throw new BadCredentialsException("Invalid STOMP token");
                            }
                    }
                } catch (Exception e) {
                    log.warn("WebSocket auth validation error for session {}: {}", sessionId, e.getMessage());
                    throw new BadCredentialsException("Invalid STOMP authentication");
                }
            } else {
                log.debug("STOMP CONNECT without Authorization header for session={}", sessionId);
                throw new BadCredentialsException("Missing Authorization header for STOMP CONNECT");
            }
        }

        if ((StompCommand.SUBSCRIBE.equals(command) || StompCommand.SEND.equals(command)) && accessor.getUser() == null) {
            log.warn("STOMP frame rejected because user is not authenticated: cmd={} session={} dest={}", command, sessionId, destination);
            throw new BadCredentialsException("STOMP session is not authenticated");
        }

        // Log SUBSCRIBE and SEND frames for diagnostics
        if (StompCommand.SUBSCRIBE.equals(command)) {
            log.info("STOMP SUBSCRIBE session={} user={} dest={}", sessionId, userInfo, destination);
        }

        if (StompCommand.SEND.equals(command)) {
            Object payload = message.getPayload();
            String payloadStr = "";
            if (payload instanceof byte[]) {
                payloadStr = new String((byte[]) payload, java.nio.charset.StandardCharsets.UTF_8);
            } else if (payload != null) {
                payloadStr = payload.toString();
            }
            log.info("STOMP SEND message received. SessionId={}, User={}, Destination={}, Payload={}", 
                sessionId, userInfo, destination, payloadStr);
        }

        return message;
    }
}
