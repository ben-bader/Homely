import '../../domain/entities/notification/notification_entity.dart';
import '../../domain/repositories/i_notification_repository.dart';
import '../datasources/remote/notification_remote_datasource.dart';
import '../models/notification/notification_model.dart';

class NotificationRepositoryImpl implements INotificationRepository {
  final NotificationRemoteDatasource _remote;

  NotificationRepositoryImpl(this._remote);

  @override
  Future<List<NotificationEntity>> fetchNotifications(
      String userId) async {
    final data = await _remote.fetchNotifications(userId);
    return data
        .map((e) =>
            NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> markAsRead(String notificationId) =>
      _remote.markAsRead(notificationId);

  @override
  Future<void> registerFcmToken(String userId, String token) =>
      _remote.registerFcmToken(userId, token);
}
