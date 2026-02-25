package com.homely.notification.service;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.homely.notification.dto.NotificationCreateRequest;
import com.homely.notification.dto.NotificationDto;
import com.homely.notification.entity.Notification;
import com.homely.notification.mapper.NotificationMapper;
import com.homely.notification.repository.NotificationRepository;
import com.homely.user.service.UserService;

import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final NotificationMapper notificationMapper;
    private final UserService userService;

    public NotificationDto create(NotificationCreateRequest request) {
        var user = userService.getById(request.getUserId());
        Notification entity = notificationMapper.toEntity(request);
        entity.setUser(user);
        entity.setRead(false);
        Notification saved = notificationRepository.save(entity);
        return notificationMapper.toDto(saved);
    }

    public List<Notification> getUnreadNotifications(UUID userId) {
        return notificationRepository.findByUserIdAndReadFalse(userId);
    }
    public NotificationDto markAsRead(UUID notificationId) {
    Notification notification = notificationRepository.findById(notificationId)
            .orElseThrow(() -> new EntityNotFoundException("Notification not found: " + notificationId));
    notification.setRead(true);
    return notificationMapper.toDto(notificationRepository.save(notification));
}
}
