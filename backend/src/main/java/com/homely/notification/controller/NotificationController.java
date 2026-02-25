package com.homely.notification.controller;

import java.util.List;
import java.util.UUID;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.homely.notification.dto.NotificationCreateRequest;
import com.homely.notification.dto.NotificationDto;
import com.homely.notification.mapper.NotificationMapper;
import com.homely.notification.service.NotificationService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;
    private final NotificationMapper notificationMapper;

    @GetMapping("/unread")
    public List<NotificationDto> getUnreadNotifications(@RequestParam UUID userId) {
        return notificationService.getUnreadNotifications(userId).stream()
                .map(notificationMapper::toDto)
                .toList();
    }

    @PostMapping
    public NotificationDto create(@Valid @RequestBody NotificationCreateRequest request) {
        return notificationService.create(request);
    }
    @PatchMapping("/{id}/read")
public NotificationDto markAsRead(@PathVariable UUID id) {
    return notificationService.markAsRead(id);
}
}
