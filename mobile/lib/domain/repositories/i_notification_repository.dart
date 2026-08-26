import '../entities/notification/notification_entity.dart';

abstract class INotificationRepository {
  Future<List<NotificationEntity>> fetchNotifications(String userId);
  Future<void> markAsRead(String notificationId);
  Future<void> registerFcmToken(String userId, String token);
}
