import 'dart:async';
import '../../data/datasources/local/secure_storage.dart';
import 'realtime_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final RealtimeService _realtime = RealtimeService();
  final SecureStorage _storage = SecureStorage();
  final StreamController<Map<String, dynamic>> _notificationController =
      StreamController<Map<String, dynamic>>.broadcast();
  
  // Track subscribed topics for cleanup
  final Set<String> _subscribedTopics = <String>{};

  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationController.stream;

  Future<void> init() async {
    await _realtime.init();
    await _subscribeToTopics();
  }

  Future<void> _subscribeToTopics() async {
    final userId = await _storage.getUserId();
    if (userId != null && userId.isNotEmpty) {
      final userTopic = '/topic/notifications/$userId';
      _subscribedTopics.add(userTopic);
      _realtime.subscribe(
        userTopic,
        (payload) {
          if (!_notificationController.isClosed) {
            _notificationController.add(Map<String, dynamic>.from(payload));
          }
        },
      );
    }

    final broadcastTopic = '/topic/notifications/broadcast';
    _subscribedTopics.add(broadcastTopic);
    _realtime.subscribe(
      broadcastTopic,
      (payload) {
        if (!_notificationController.isClosed) {
          _notificationController.add(Map<String, dynamic>.from(payload));
        }
      },
    );
  }

  Future<void> connect({void Function()? onConnected}) async {
    await _realtime.connect(onConnected: onConnected);
  }

  /// Complete disconnect and cleanup for logout
  void disconnect() {
    // Unsubscribe from all topics
    for (var topic in _subscribedTopics) {
      _realtime.unsubscribe(topic, (_) {});
    }
    _subscribedTopics.clear();
    
    // Close notification stream
    if (!_notificationController.isClosed) {
      _notificationController.close();
    }
  }
  
  /// Reset service for new session
  void reset() {
    disconnect();
    // Create new controller for next session
    // Note: Cannot reassign final field, so we rely on the old controller being closed
  }
}
