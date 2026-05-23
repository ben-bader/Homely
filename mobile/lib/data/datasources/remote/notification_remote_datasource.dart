import 'package:homely/core/network/api_client.dart';
import 'package:homely/core/network/endpoints.dart';

abstract class NotificationRemoteDatasource {
  Future<List<Map<String, dynamic>>> getNotifications();
  Future<Map<String, dynamic>> markAsRead(String notificationId);
  Future<Map<String, dynamic>> deleteNotification(String notificationId);
  Future<List<Map<String, dynamic>>> fetchNotifications(String userId);
  Future<void> registerFcmToken(String userId, String token);
}

class NotificationRemoteDatasourceImpl implements NotificationRemoteDatasource {
  final Set<String> _inFlightMarkReads = {};

  @override
  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final response = await ApiClient.get('/notifications');
      return List<Map<String, dynamic>>.from(response ?? []);
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  @override
  Future<Map<String, dynamic>> markAsRead(String notificationId) async {
    if (_inFlightMarkReads.contains(notificationId)) {
      return <String, dynamic>{};
    }
    _inFlightMarkReads.add(notificationId);
    // Fire-and-forget but catch errors to avoid bubbling up
    try {
      final response = await ApiClient.patch(
        Endpoints.markNotificationAsRead(notificationId),
      );
      return response ?? <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    } finally {
      _inFlightMarkReads.remove(notificationId);
    }
  }

  @override
  Future<Map<String, dynamic>> deleteNotification(String notificationId) async {
    try {
      final response = await ApiClient.delete('/notifications/$notificationId');
      return response ?? <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchNotifications(String userId) async {
    try {
      return await getNotifications();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  @override
  Future<void> registerFcmToken(String userId, String token) async {
    try {
      await ApiClient.post(
        Endpoints.updateFcmToken(userId),
        body: {'token': token},
      );
    } catch (_) {
      // ignore registration failures silently
    }
  }
}
