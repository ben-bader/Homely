import 'package:homely/core/network/api_client.dart';

abstract class NotificationRemoteDatasource {
  Future<List<Map<String, dynamic>>> getNotifications();
  Future<Map<String, dynamic>> markAsRead(String notificationId);
  Future<Map<String, dynamic>> deleteNotification(String notificationId);
  Future<List<Map<String, dynamic>>> fetchNotifications(String userId);
  Future<void> registerFcmToken(String userId, String token);
}

class NotificationRemoteDatasourceImpl implements NotificationRemoteDatasource {
  @override
  Future<List<Map<String, dynamic>>> getNotifications() async {
    final response = await ApiClient.get('/notifications');
    return List<Map<String, dynamic>>.from(response ?? []);
  }

  @override
  Future<Map<String, dynamic>> markAsRead(String notificationId) async {
    final response = await ApiClient.put('/notifications/$notificationId/read');
    return response;
  }

  @override
  Future<Map<String, dynamic>> deleteNotification(String notificationId) async {
    final response = await ApiClient.delete('/notifications/$notificationId');
    return response;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchNotifications(String userId) async {
    return await getNotifications();
  }

  @override
  Future<void> registerFcmToken(String userId, String token) async {
    await ApiClient.post(
      '/notifications/register-token',
      body: {'userId': userId, 'token': token},
    );
  }
}
