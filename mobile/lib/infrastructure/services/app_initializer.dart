import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:homely/infrastructure/services/chat_service.dart';
import 'package:homely/infrastructure/services/notification_service.dart';
import 'package:homely/data/datasources/local/secure_storage.dart';

/// Initializes background services and polling after successful user login.
/// This ensures services only start after authentication is complete.
class AppInitializer {
  static final AppInitializer _instance = AppInitializer._internal();

  factory AppInitializer() {
    return _instance;
  }

  AppInitializer._internal();

  bool _initialized = false;

  /// Initialize all background services after successful login.
  /// Should only be called ONCE after the user is authenticated.
  Future<void> initializeAfterLogin() async {
    if (_initialized) {
      return; // Prevent duplicate initialization
    }

    try {
      await ChatService().init();
      unawaited(_initializeNotificationService());
      _initialized = true;
    } catch (e) {
      debugPrint('Error during app initialization after login: $e');
    }
  }

  Future<void> _initializeNotificationService() async {
    try {
      await NotificationService().init();
    } catch (e) {
      debugPrint('[AppInitializer] Notification init failed: $e');
    }
  }

  /// Reset the initialization state (useful for logout)
  void reset() {
    _initialized = false;
  }
}
