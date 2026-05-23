import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
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
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  bool _isConnecting = false;

  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationController.stream;

  Future<void> init() async {
    try {
      final token = await _storage.getToken();
      if (token != null) {
        _connect(token);
      }
    } catch (e) {
      debugPrint('[NotificationService] init failed: $e');
    }
  }

  void _connect(String token) {
    if (_isConnecting || _stompClient?.isActive == true) return;
    _isConnecting = true;
    _reconnectTimer?.cancel();

    _stompClient = StompClient(
      config: StompConfig(
        url: Endpoints.getWebSocketUrl(),
        onConnect: (frame) {
          _reconnectAttempts = 0;
          _isConnecting = false;
          _onConnect(frame);
        },
        onWebSocketError: (error) {
          debugPrint('[NotificationService] WebSocket error: $error');
        },
        onStompError: (error) {
          debugPrint('[NotificationService] STOMP error: $error');
        },
        onDisconnect: (frame) {
          debugPrint('[NotificationService] Disconnected: $frame');
          _scheduleReconnect(token);
        },
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
      ),
    );
    _stompClient?.activate();
  }

  void _onConnect(StompFrame frame) {
    debugPrint('[NotificationService] Connected to STOMP');

    final userId = _storage.getUserId();
    _stompClient?.subscribe(
      destination: '/user/$userId/notifications',
      callback: (frame) {
        final message = jsonDecode(frame.body ?? '{}');
        _notificationController.add(message);
      },
    );

    _stompClient?.subscribe(
      destination: '/topic/notifications',
      callback: (frame) {
        final message = jsonDecode(frame.body ?? '{}');
        _notificationController.add(message);
      },
    );
  }

  void _scheduleReconnect(String token) {
    _reconnectTimer?.cancel();
    _reconnectAttempts++;
    if (_reconnectAttempts > 5) {
      debugPrint('[NotificationService] Reconnect attempts exhausted.');
      return;
    }

    final delaySeconds = min(30, 1 << (_reconnectAttempts - 1));
    debugPrint(
      '[NotificationService] Reconnecting in $delaySeconds seconds...',
    );
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () async {
      final authToken = await _storage.getToken();
      if (authToken != null) {
        _connect(authToken);
      }
    });
  }

  Future<void> startPolling(SecureStorage storage) async {
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      final bool isActive = _stompClient?.isActive ?? false;
      if (!isActive) {
        final token = await storage.getToken();
        if (token != null) {
          _connect(token);
        }
      }
    });
  }

  Future<List<Map<String, dynamic>>> fetchUnread(String userId) async {
    return [];
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _stompClient?.deactivate();
    _notificationController.close();
  }
}
