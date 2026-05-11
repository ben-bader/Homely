import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/notification_remote_datasource.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/entities/notification/notification_entity.dart';
import '../../domain/repositories/i_notification_repository.dart';

final notificationRemoteDatasourceProvider =
    Provider<NotificationRemoteDatasource>(
  (ref) => NotificationRemoteDatasourceImpl(),
);

final notificationRepositoryProvider =
    Provider<INotificationRepository>((ref) {
  return NotificationRepositoryImpl(
      ref.read(notificationRemoteDatasourceProvider));
});

final notificationsProvider =
    FutureProvider.family<List<NotificationEntity>, String>(
        (ref, userId) async {
  return ref
      .read(notificationRepositoryProvider)
      .fetchNotifications(userId);
});
