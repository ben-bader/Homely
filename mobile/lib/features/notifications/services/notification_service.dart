import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/endpoints.dart';
import 'package:mobile/features/auth/services/auth_service.dart';
import 'package:mobile/features/notifications/models/notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Timer? _pollTimer;
  final List<String> _seenIds = [];

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

  Future<void> startPolling(AuthService authService) async {
    final userId = await authService.getCurrentUserId();
    if (userId == null) {
      debugPrint('[NotificationService] ⚠️ Failed to start polling: userId is null');
      return;
    }

    debugPrint('[NotificationService] ✅ Starting polling for userId: $userId');
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      try {
        final notifications = await fetchUnread(userId);
        debugPrint('[NotificationService] 📬 Fetched ${notifications.length} notifications');
        for (final n in notifications) {
          if (!_seenIds.contains(n.id)) {
            _seenIds.add(n.id);
            _showLocalNotification(n);
          }
        }
      } catch (e) {
        debugPrint('[NotificationService] ❌ Polling error: $e');
      }
    });
  }

  void stopPolling() => _pollTimer?.cancel();

  void _showLocalNotification(NotificationModel n) {
    debugPrint('[NotificationService] 🔔 Showing notification: ${n.type} - ${n.payload}');
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
      final data = await ApiClient.get(
        Endpoints.notifications,
        queryParams: {'userId': userId},
        auth: true,
      );

      if (data is List) {
        return data.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      if (data is Map && data['content'] is List) {
        return (data['content'] as List)
            .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('[NotificationService] 🚫 Error fetching notifications: $e');
      return [];
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await ApiClient.patch(
        Endpoints.markNotificationAsRead(notificationId),
        auth: true,
      );
    } catch (e) {
      debugPrint('[NotificationService] ❌ Error marking as read: $e');
    }
  }

  String titleFor(String type) {
    return switch (type) {
      'MESSAGE' => 'New Message',
      'ALERT'   => 'Alert',
      _         => 'Notification',
    };
  }
}