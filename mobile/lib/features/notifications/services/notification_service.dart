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
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[NotificationService] 📬 Received foreground message: ${message.messageId}');
      _handleRemoteMessage(message);
    });
    
    // Handle background message tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[NotificationService] 👆 Message opened from background: ${message.messageId}');
      _handleMessageTap(message);
    });
  }

  void _handleRemoteMessage(RemoteMessage message) {
    final data = message.data;
    final notification = message.notification;
    
    if (notification != null) {
      _showLocalNotification(
        NotificationModel(
          id: message.messageId ?? DateTime.now().toString(),
          type: data['type'] ?? 'NOTIFICATION',
          payload: data['payload'] ?? notification.body ?? 'New notification',
          read: false,
        ),
      );
    }
  }

  void _handleMessageTap(RemoteMessage message) {
    // Handle message tap - navigate to relevant screen
    final data = message.data;
    final type = data['type'] ?? '';
    
    switch (type) {
      case 'NEW_CHAT_MESSAGE':
      case 'CONVERSATION_CREATED':
        // Navigate to chat screen
        debugPrint('[NotificationService] 💬 Navigating to chat: ${data['conversationId']}');
        break;
      case 'VISIT_REQUEST_CREATED':
      case 'VISIT_REQUEST_STATUS_CHANGED':
        // Navigate to visit requests
        debugPrint('[NotificationService] 👁️ Navigating to visit requests');
        break;
      case 'PROPERTY_CREATED':
        // Navigate to property details
        debugPrint('[NotificationService] 🏠 Navigating to property: ${data['propertyId']}');
        break;
      default:
        debugPrint('[NotificationService] 📲 Navigating to notifications');
    }
  }

  Future<void> startPolling(AuthService authService) async {
    final userId = await authService.getCurrentUserId();
    if (userId == null) {
      debugPrint('[NotificationService] ⚠️ Failed to start polling: userId is null');
      return;
    }

    debugPrint('[NotificationService] ✅ Starting polling for userId: $userId');
    
    // Get Firebase device token and register it
    await _registerDeviceToken(userId);
    
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

  Future<void> _registerDeviceToken(String userId) async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        debugPrint('[NotificationService] 🔐 Firebase token: $token');
        // TODO: Send token to backend to store it
        // This will be used later to send push notifications
        await ApiClient.post(
          '/users/$userId/fcm-token',
          body: {'token': token},
          auth: true,
        );
      }
    } catch (e) {
      debugPrint('[NotificationService] ❌ Error registering device token: $e');
    }
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
      n.getTitle(),
      n.getDetailedMessage(),
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
      'NEW_CHAT_MESSAGE' => '💬 New Message',
      'CONVERSATION_CREATED' => '💬 New Conversation',
      'VISIT_REQUEST_CREATED' => '👁️ New Visit Request',
      'VISIT_REQUEST_STATUS_CHANGED' => '👁️ Visit Request Updated',
      'PROPERTY_CREATED' => '🏠 New Property',
      'BOOST_PURCHASED' => '⚡ Boost Purchased',
      'BOOST_STATUS_CHANGED' => '⚡ Boost Updated',
      'FEEDBACK_RECEIVED' => '⭐ New Feedback',
      'MESSAGE' => 'New Message',
      'ALERT'   => 'Alert',
      _         => 'Notification',
    };
  }
}
