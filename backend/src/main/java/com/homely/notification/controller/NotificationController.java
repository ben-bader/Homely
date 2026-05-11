package com.homely.notification.controller;

import java.util.List;
import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.homely.common.dto.PageResponse;
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

    // ✅ Get ALL notifications for logged-in user - PAGINATED
    @GetMapping("/paginated")
    public ResponseEntity<PageResponse<NotificationDto>> getAllPaginated(
            Authentication authentication,
            @RequestParam(defaultValue = "0") Integer page,
            @RequestParam(defaultValue = "30") Integer pageSize) {
        String email = authentication.getName();
        return ResponseEntity.ok(notificationService.getAllByEmailPaginated(email, page, pageSize));
    }

    // ✅ Get ALL notifications for logged-in user - OLD ENDPOINT
    @GetMapping
    public List<NotificationDto> getAll(Authentication authentication) {
        String email = authentication.getName();

        return notificationService.getAllByEmail(email)
                .stream()
                .map(notificationMapper::toDto)
                .toList();
    }

    // ✅ Get unread notifications - PAGINATED
    @GetMapping("/unread/paginated")
    public ResponseEntity<PageResponse<NotificationDto>> getUnreadPaginated(
            Authentication authentication,
            @RequestParam(defaultValue = "0") Integer page,
            @RequestParam(defaultValue = "30") Integer pageSize) {
        String email = authentication.getName();
        return ResponseEntity.ok(notificationService.getUnreadByEmailPaginated(email, page, pageSize));
    }

    // ✅ Get unread notifications - OLD ENDPOINT
    @GetMapping("/unread")
    public List<NotificationDto> getUnread(Authentication authentication) {
        String email = authentication.getName();

        return notificationService.getUnreadByEmail(email)
                .stream()
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