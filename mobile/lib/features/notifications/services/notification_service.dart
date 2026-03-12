import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/endpoints.dart';
import 'package:mobile/features/auth/services/auth_service.dart';
import 'package:mobile/features/notifications/models/notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Timer? _pollTimer;
  final List<String> _seenIds = [];

  // ─────────────────────────────────────────────────────────────
  // init — call once at app start
  // ─────────────────────────────────────────────────────────────
Future<void> init() async {
  // Fix: InitializationSettings passed as named params, not positional
  await _localNotifications.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
    onDidReceiveNotificationResponse: _onNotificationTap,
  );
    // Create Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'homely_channel',
      'Homely Notifications',
      description: 'App notifications from Homely',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Request iOS permissions
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // Request Firebase messaging permissions
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Handle foreground Firebase messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
        '[NotificationService] 📬 Foreground message: ${message.messageId}',
      );
      _handleRemoteMessage(message);
    });

    // Handle notification tap from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(
        '[NotificationService] 👆 Opened from background: ${message.messageId}',
      );
      _handleMessageTap(message);
    });

    // Handle notification tap from terminated state
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint(
        '[NotificationService] 🚀 Opened from terminated: ${initialMessage.messageId}',
      );
      _handleMessageTap(initialMessage);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Local notification tap handler
  // ─────────────────────────────────────────────────────────────
  void _onNotificationTap(NotificationResponse response) {
    debugPrint(
      '[NotificationService] 🔔 Local notification tapped: ${response.payload}',
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Firebase message handlers
  // ─────────────────────────────────────────────────────────────
  void _handleRemoteMessage(RemoteMessage message) {
    final notification = message.notification;
    final data = message.data;

    if (notification != null) {
      _showLocalNotification(
        NotificationModel(
          id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
          type: data['type'] ?? 'NOTIFICATION',
          payload: data['payload'] ?? notification.body ?? 'New notification',
          read: false,
        ),
      );
    }
  }

  void _handleMessageTap(RemoteMessage message) {
    final type = message.data['type'] ?? '';

    switch (type) {
      case 'NEW_CHAT_MESSAGE':
      case 'CONVERSATION_CREATED':
        debugPrint(
          '[NotificationService] 💬 Navigate to chat: ${message.data['conversationId']}',
        );
        break;
      case 'VISIT_REQUEST_CREATED':
      case 'VISIT_REQUEST_STATUS_CHANGED':
        debugPrint('[NotificationService] 👁️ Navigate to visit requests');
        break;
      case 'PROPERTY_CREATED':
        debugPrint(
          '[NotificationService] 🏠 Navigate to property: ${message.data['propertyId']}',
        );
        break;
      default:
        debugPrint('[NotificationService] 📲 Navigate to notifications');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Polling
  // ─────────────────────────────────────────────────────────────
  Future<void> startPolling(AuthService authService) async {
    final userId = await authService.getCurrentUserId();
    if (userId == null) {
      debugPrint('[NotificationService] ⚠️ Cannot start polling: userId is null');
      return;
    }

    debugPrint('[NotificationService] ✅ Starting polling for userId: $userId');

    await _registerDeviceToken(userId);

    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      try {
        final notifications = await fetchUnread(userId);
        debugPrint(
          '[NotificationService] 📬 Fetched ${notifications.length} notifications',
        );
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

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  // ─────────────────────────────────────────────────────────────
  // FCM token registration
  // ─────────────────────────────────────────────────────────────
  Future<void> _registerDeviceToken(String userId) async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        debugPrint('[NotificationService] 🔐 FCM token: $token');
        await ApiClient.post(
          '/users/$userId/fcm-token',
          body: {'token': token},
          auth: true,
        );
      }
    } catch (e) {
      debugPrint('[NotificationService] ❌ Error registering FCM token: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Show local notification
  // Fix: show() now uses correct positional + named args
  // ─────────────────────────────────────────────────────────────
  Future<void> _showLocalNotification(NotificationModel n) async {
    debugPrint(
      '[NotificationService] 🔔 Showing: ${n.type} - ${n.payload}',
    );

    const androidDetails = AndroidNotificationDetails(
      'homely_channel',
      'Homely Notifications',
      channelDescription: 'App notifications from Homely',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    await _localNotifications.show(
      id: n.id.hashCode,
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
      debugPrint('[NotificationService] 🚫 Error fetching notifications: $e');
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
      debugPrint('[NotificationService] ❌ Error marking as read: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────
  String titleFor(String type) {
    return switch (type) {
      'NEW_CHAT_MESSAGE'              => '💬 New Message',
      'CONVERSATION_CREATED'          => '💬 New Conversation',
      'VISIT_REQUEST_CREATED'         => '👁️ New Visit Request',
      'VISIT_REQUEST_STATUS_CHANGED'  => '👁️ Visit Request Updated',
      'PROPERTY_CREATED'              => '🏠 New Property',
      'BOOST_PURCHASED'               => '⚡ Boost Purchased',
      'BOOST_STATUS_CHANGED'          => '⚡ Boost Updated',
      'FEEDBACK_RECEIVED'             => '⭐ New Feedback',
      'MESSAGE'                       => '💬 New Message',
      'ALERT'                         => '🚨 Alert',
      _                               => '🔔 Notification',
    };
  }
}