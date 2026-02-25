import 'dart:async';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/features/auth/services/auth_service.dart';
import 'package:mobile/features/notifications/models/notifications.dart';

class NotificationService {
  static const String _baseUrl = 'https://unparrying-christene-reductively.ngrok-free.dev/api/notifications';

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Timer? _pollTimer;
  List<String> _seenIds = []; // tracks already-shown notifications

  // Call once at app start
  Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // Request permission on iOS
    await _localNotifications
    .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
    ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  // Start polling every 15 seconds
 void startPolling(AuthService authService) async {
  final userId = await authService.getCurrentUserId();
  if (userId == null) return;

  _pollTimer?.cancel();
  _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
    final notifications = await fetchUnread(userId);
    for (final n in notifications) {
      if (!_seenIds.contains(n.id)) {
        _seenIds.add(n.id);
        _showLocalNotification(n);
      }
    }
  });
}

  void stopPolling() => _pollTimer?.cancel();

  void _showLocalNotification(NotificationModel n) {
    const androidDetails = AndroidNotificationDetails(
      'homely_channel',
      'Homely Notifications',
      channelDescription: 'App notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    _localNotifications.show(
      n.id.hashCode,
      titleFor(n.type),
      n.payload,
      const NotificationDetails(android: androidDetails),
    );
  }

  Future<List<NotificationModel>> fetchUnread(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/unread?userId=$userId'),
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => NotificationModel.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> markAsRead(String notificationId) async {
    await http.patch(Uri.parse('$_baseUrl/$notificationId/read'));
  }

  String titleFor(String type) {
    return switch (type) {
      'MESSAGE' => 'New Message',
      'ALERT'   => 'Alert',
      _         => 'Notification',
    };
  }
}