package com.homely.notification.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.homely.notification.entity.Notification;

public interface NotificationRepository extends JpaRepository<Notification, UUID> {
    List<Notification> findByUserIdAndReadFalse(UUID userId);
    List<Notification> findByUserEmail(String email);
List<Notification> findByUserEmailAndReadFalse(String email);

}
