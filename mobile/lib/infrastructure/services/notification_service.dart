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

  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationController.stream;

  Future<void> init() async {
    await _realtime.init();
    await _subscribeToTopics();
  }

  Future<void> _subscribeToTopics() async {
    final userId = await _storage.getUserId();
    if (userId != null && userId.isNotEmpty) {
      _realtime.subscribe(
        '/topic/notifications/$userId',
        (payload) {
          _notificationController.add(Map<String, dynamic>.from(payload));
        },
      );
    }

    _realtime.subscribe(
      '/topic/notifications/broadcast',
      (payload) {
        _notificationController.add(Map<String, dynamic>.from(payload));
      },
    );
  }

  Future<void> connect({void Function()? onConnected}) async {
    await _realtime.connect(onConnected: onConnected);
  }

  void disconnect() {
    _realtime.disconnect();
    if (!_notificationController.isClosed) {
      _notificationController.close();
    }
  }
}
