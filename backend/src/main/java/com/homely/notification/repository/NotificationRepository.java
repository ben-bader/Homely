package com.homely.notification.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.homely.notification.entity.Notification;

public interface NotificationRepository extends JpaRepository<Notification, UUID> {
    List<Notification> findByUserIdAndReadFalse(UUID userId);
    
    @Query("SELECT n FROM Notification n WHERE n.user.email = :email ORDER BY n.createdAt DESC")
    List<Notification> findByUserEmail(@Param("email") String email);
    
    @Query("SELECT n FROM Notification n WHERE n.user.email = :email AND n.read = false ORDER BY n.createdAt DESC")
    List<Notification> findByUserEmailAndReadFalse(@Param("email") String email);
    
    @Query("SELECT n FROM Notification n WHERE n.user.id = :userId ORDER BY n.createdAt DESC")
    List<Notification> findByUserId(@Param("userId") UUID userId);
    
    @Query("SELECT COUNT(n) > 0 FROM Notification n WHERE n.user = :user AND n.type = :type AND n.sent = true")
    boolean existsByUserAndTypeAndSentTrue(@Param("user") com.homely.user.entity.User user, @Param("type") String type);

    @Query("SELECT n FROM Notification n WHERE n.user = :user AND n.type = :type AND n.sent = true ORDER BY n.createdAt DESC")
    java.util.Optional<Notification> findFirstByUserAndTypeAndSentTrue(@Param("user") com.homely.user.entity.User user, @Param("type") String type);
}
