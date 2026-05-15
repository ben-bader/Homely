import 'dart:async';
import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../../core/network/endpoints.dart';
import '../../data/datasources/local/secure_storage.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  StompClient? _stompClient;
  final SecureStorage _storage = SecureStorage();
  final StreamController<Map<String, dynamic>> _notificationController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationController.stream;

  Future<void> init() async {
    // Initialize STOMP client for notifications
    final token = await _storage.getToken();
    if (token != null) {
      _connect(token);
    }
  }

  void _connect(String token) {
    _stompClient = StompClient(
      config: StompConfig(
        url: Endpoints.getWebSocketUrl(),
        onConnect: _onConnect,
        onWebSocketError: (error) => print('WebSocket error: $error'),
        onStompError: (error) => print('STOMP error: $error'),
        onDisconnect: (frame) => print('Disconnected: $frame'),
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
      ),
    );
    _stompClient?.activate();
  }

  void _onConnect(StompFrame frame) {
    print('Connected to STOMP');

    // Subscribe to user-specific notifications
    final userId = _storage.getUserId();
    if (userId != null) {
      _stompClient?.subscribe(
        destination: '/user/$userId/notifications',
        callback: (frame) {
          final message = jsonDecode(frame.body ?? '{}');
          _notificationController.add(message);
        },
      );
    }

    // Subscribe to general notifications
    _stompClient?.subscribe(
      destination: '/topic/notifications',
      callback: (frame) {
        final message = jsonDecode(frame.body ?? '{}');
        _notificationController.add(message);
      },
    );
  }

  Future<void> startPolling(SecureStorage storage) async {
    // Polling fallback if WebSocket fails
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (_stompClient?.isActive != true) {
        final token = await storage.getToken();
        if (token != null) {
          _connect(token);
        }
      }
    });
  }

  Future<List<Map<String, dynamic>>> fetchUnread(String userId) async {
    // This would be implemented to fetch unread notifications from API
    // For now, return empty list as real-time is handled via STOMP
    return [];
  }

  void disconnect() {
    _stompClient?.deactivate();
    _notificationController.close();
  }
}
