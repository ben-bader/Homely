package com.homely.notification.controller;

import java.util.List;
import java.util.UUID;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.homely.notification.dto.NotificationCreateRequest;
import com.homely.notification.dto.NotificationDto;
import com.homely.notification.entity.Notification;
import com.homely.notification.service.NotificationService;

import lombok.RequiredArgsConstructor;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;


@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    @GetMapping("/unread")
    public List<NotificationDto> getUnreadNotifications(@RequestParam UUID userId) {
        return notificationService.getUnreadNotifications(userId).stream()
            .map(this::convertToDto)
            .toList();
    }
    

    @PostMapping
    public NotificationDto notify(@RequestBody NotificationCreateRequest request) {
        Notification n = new Notification();
        n.setType(request.getType());
        n.setPayload(request.getPayload());
        return convertToDto(notificationService.notify(n));
    }

    private NotificationDto convertToDto(Notification notification) {
        NotificationDto dto = new NotificationDto();
        dto.setId(notification.getId());
        dto.setUserId(notification.getUser().getId());
        dto.setType(notification.getType());
        dto.setPayload(notification.getPayload());
        dto.setRead(notification.isRead());
        return dto;
    }
}
