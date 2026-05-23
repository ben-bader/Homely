import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../../core/network/endpoints.dart';
import '../../data/datasources/local/secure_storage.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  StompClient? _stompClient;
  final SecureStorage _storage = SecureStorage();
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  bool _isConnecting = false;

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  Future<void> init() async {
    try {
      final token = await _storage.getToken();
      if (token != null) {
        _connect(token);
      }
    } catch (e) {
      debugPrint('[ChatService] init failed: $e');
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
          debugPrint('[ChatService] WebSocket error: $error');
        },
        onStompError: (error) {
          debugPrint('[ChatService] STOMP error: $error');
        },
        onDisconnect: (frame) {
          debugPrint('[ChatService] Disconnected: $frame');
          _scheduleReconnect(token);
        },
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
      ),
    );
    _stompClient?.activate();
  }

  void _onConnect(StompFrame frame) {
    debugPrint('[ChatService] Connected to Chat STOMP');

    final userId = _storage.getUserId();
    _stompClient?.subscribe(
      destination: '/user/$userId/chat',
      callback: (frame) {
        final message = jsonDecode(frame.body ?? '{}');
        _messageController.add(message);
      },
    );
  }

  void _scheduleReconnect(String token) {
    _reconnectTimer?.cancel();
    _reconnectAttempts++;
    if (_reconnectAttempts > 5) {
      debugPrint('[ChatService] Reconnect attempts exhausted.');
      return;
    }

    final delaySeconds = min(30, 1 << (_reconnectAttempts - 1));
    debugPrint('[ChatService] Reconnecting in $delaySeconds seconds...');
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () async {
      final authToken = await _storage.getToken();
      if (authToken != null) {
        _connect(authToken);
      }
    });
  }

  bool get isConnected => _stompClient?.isActive ?? false;

  Future<void> connect({void Function()? onConnected}) async {
    final token = await _storage.getToken();
    if (token != null) {
      _connect(token);
      await Future.delayed(const Duration(seconds: 1));
      onConnected?.call();
    }
  }

  void subscribe(
    String conversationId,
    void Function(Map<String, dynamic>) onMessage,
  ) {
    final bool isActive = _stompClient?.isActive ?? false;
    if (isActive) {
      _stompClient!.subscribe(
        destination: '/topic/chat/$conversationId',
        callback: (frame) {
          final message = jsonDecode(frame.body ?? '{}');
          onMessage(message);
        },
      );
    }
  }

  void sendMessage(String conversationId, String content) {
    if (_stompClient?.isActive == true) {
      _stompClient?.send(
        destination: '/app/chat.sendMessage',
        body: jsonEncode({
          'conversationId': conversationId,
          'content': content,
        }),
      );
    }
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _stompClient?.deactivate();
    _messageController.close();
  }
}
