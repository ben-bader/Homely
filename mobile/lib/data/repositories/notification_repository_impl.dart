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
        try {
            final data = await _remote.fetchNotifications(userId);
            return data.map((e) => NotificationModel.fromJson(e)).toList();
        } catch (_) {
            return <NotificationEntity>[];
        }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _remote.markAsRead(notificationId);
    } catch (_) {
      // ignore failures here; UI remains stable.
    }
  }

  @override
  Future<void> registerFcmToken(String userId, String token) =>
      _remote.registerFcmToken(userId, token);
}
