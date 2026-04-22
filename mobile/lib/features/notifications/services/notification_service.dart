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

  // ─────────────────────────────────────────────────────────────
  // init — call once at app start
  // ─────────────────────────────────────────────────────────────
  Future<void> init() async {
    // FIX: InitializationSettings is a positional argument, not named
// Try this
await _localNotifications.initialize(
  settings: const InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  ),
  onDidReceiveNotificationResponse: _onNotificationTap,
);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'homely_channel',
      'Homely Notifications',
      description: 'App notifications from Homely',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  // ─────────────────────────────────────────────────────────────
  // Local notification tap handler
  // ─────────────────────────────────────────────────────────────
  void _onNotificationTap(NotificationResponse response) {
    debugPrint(
      '[NotificationService] Local notification tapped: ${response.payload}',
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Polling
  // ─────────────────────────────────────────────────────────────
  Future<void> startPolling(AuthService authService) async {
    final userId = await authService.getCurrentUserId();
    if (userId == null) {
      debugPrint('[NotificationService] Cannot start polling: userId is null');
      return;
    }

    debugPrint('[NotificationService] Starting polling for userId: $userId');

    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      try {
        final notifications = await fetchUnread(userId);
        debugPrint(
          '[NotificationService] Fetched ${notifications.length} unread notifications',
        );
      } catch (e) {
        debugPrint('[NotificationService] Polling error: $e');
      }
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  // ─────────────────────────────────────────────────────────────
  // Show local notification
  // ─────────────────────────────────────────────────────────────
  Future<void> showLocalNotification(NotificationModel n) async {
    debugPrint('[NotificationService] Showing: ${n.type} - ${n.payload}');

    const androidDetails = AndroidNotificationDetails(
      'homely_channel',
      'Homely Notifications',
      channelDescription: 'App notifications from Homely',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    await _localNotifications.show(
      id: n.id.hashCode & 0x7FFFFFFF,
      title: n.getTitle(),
      body: n.getDetailedMessage(),
      notificationDetails: const NotificationDetails(android: androidDetails),
      payload: n.type,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Fetch notifications from backend
  // ─────────────────────────────────────────────────────────────
  Future<List<NotificationModel>> fetchUnread(String userId) async {
    try {
      final data = await ApiClient.get(
        Endpoints.notifications,
        queryParams: {'userId': userId},
        auth: true,
      );

      if (data is List) {
        return data
            .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      if (data is Map && data['content'] is List) {
        return (data['content'] as List)
            .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint('[NotificationService] Error fetching notifications: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Mark notification as read
  // ─────────────────────────────────────────────────────────────
  Future<void> markAsRead(String notificationId) async {
    try {
      await ApiClient.patch(
        Endpoints.markNotificationAsRead(notificationId),
        auth: true,
      );
    } catch (e) {
      debugPrint('[NotificationService] Error marking as read: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────
  String titleFor(String type) {
    return switch (type) {
      'NEW_CHAT_MESSAGE'             => 'New Message',
      'CONVERSATION_CREATED'         => 'New Conversation',
      'VISIT_REQUEST_CREATED'        => 'New Visit Request',
      'VISIT_REQUEST_STATUS_CHANGED' => 'Visit Request Updated',
      'PROPERTY_CREATED'             => 'New Property',
      'BOOST_PURCHASED'              => 'Boost Purchased',
      'BOOST_STATUS_CHANGED'         => 'Boost Updated',
      'FEEDBACK_RECEIVED'            => 'New Feedback',
      'MESSAGE'                      => 'New Message',
      'ALERT'                        => 'Alert',
      _                              => 'Notification',
    };
  }
}