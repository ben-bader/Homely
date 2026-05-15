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
      // Initialize Chat Service
      await ChatService().init();

      // Start Notification polling with the authenticated user context
      final authService = SecureStorage();
      NotificationService().startPolling(authService);

      _initialized = true;
    } catch (e) {
      print('Error during app initialization after login: $e');
      rethrow;
    }
  }

  /// Reset the initialization state (useful for logout)
  void reset() {
    _initialized = false;
  }
}
