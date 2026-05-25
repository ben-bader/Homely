package com.homely.websocket.controller;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.messaging.simp.user.SimpUser;
import org.springframework.messaging.simp.user.SimpUserRegistry;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/ws/diagnostics")
@RequiredArgsConstructor
public class DiagnosticsController {

    private final SimpUserRegistry simpUserRegistry;

    @GetMapping("/users")
    public List<String> listUsers() {
        return simpUserRegistry.getUsers()
                .stream()
                .map(SimpUser::getName)
                .collect(Collectors.toList());
    }

    @GetMapping("/sessions")
    public List<String> listSessions() {
        return simpUserRegistry.getUsers()
                .stream()
                .flatMap(u -> u.getSessions().stream())
                .map(s -> s.getId())
                .collect(Collectors.toList());
    }
}
