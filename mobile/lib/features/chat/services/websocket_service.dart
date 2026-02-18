import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:mobile/core/storage/secure_storage.dart';
import '../models/message.dart';

/// WebSocket service for real-time chat messaging using STOMP protocol
class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  StompClient? _client;
  final SecureStorage _storage = SecureStorage();
  bool _isConnected = false;
  final Map<String, Function(ChatMessage)> _subscriptions = {};
  final Map<String, void Function()> _unsubscribeFunctions = {}; // Store unsubscribe functions

  /// Base URL for WebSocket (should match backend WebSocket endpoint)
  String get baseUrl {
    // Extract base URL from ApiClient
    // For Android emulator: ws://10.0.2.2:8082/ws
    // For iOS simulator: ws://localhost:8082/ws
    // For production: wss://your-domain.com/ws
    final apiBaseUrl = 'https://zcvxc076-8082.uks1.devtunnels.ms';
    // Convert https to wss (WebSocket Secure)
    if (apiBaseUrl.startsWith('https://')) {
      // Remove /api if present, then add /ws
      String wsUrl = apiBaseUrl.replaceFirst('https://', 'wss://');
      if (wsUrl.endsWith('/api')) {
        wsUrl = wsUrl.substring(0, wsUrl.length - 4);
      }
      return '$wsUrl/ws';
    } else {
      String wsUrl = apiBaseUrl.replaceFirst('http://', 'ws://');
      if (wsUrl.endsWith('/api')) {
        wsUrl = wsUrl.substring(0, wsUrl.length - 4);
      }
      return '$wsUrl/ws';
    }
  }

  /// Check if WebSocket is connected
  bool get isConnected => _isConnected && _client != null;

  /// Connect to WebSocket server
  Future<void> connect() async {
    if (_isConnected) return;

    try {
      final token = await _storage.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      _client = StompClient(
        config: StompConfig(
          url: baseUrl,
          onConnect: _onConnect,
          onDisconnect: _onDisconnect,
          onWebSocketError: _onError,
          onStompError: _onStompError,
          stompConnectHeaders: {
            'Authorization': 'Bearer $token',
          },
          webSocketConnectHeaders: {
            'Authorization': 'Bearer $token',
          },
          connectionTimeout: const Duration(seconds: 5),
          reconnectDelay: const Duration(seconds: 5),
        ),
      );

      _client!.activate();
    } catch (e) {
      print('WebSocket connection error: $e');
      _isConnected = false;
      rethrow;
    }
  }

  /// Disconnect from WebSocket server
  void disconnect() {
    if (_client != null) {
      // Unsubscribe from all conversations
      for (final unsubscribe in _unsubscribeFunctions.values) {
        unsubscribe();
      }
      _client!.deactivate();
      _client = null;
      _isConnected = false;
      _subscriptions.clear();
      _unsubscribeFunctions.clear();
    }
  }

  /// Subscribe to messages for a specific conversation
  void subscribeToConversation(
    String conversationId,
    Function(ChatMessage) onMessage,
  ) {
    if (!_isConnected || _client == null) {
      throw Exception('WebSocket not connected');
    }

    final destination = '/user/queue/conversations/$conversationId';
    
    // Store subscription callback
    _subscriptions[conversationId] = onMessage;

    final unsubscribe = _client!.subscribe(
      destination: destination,
      callback: (StompFrame frame) async {
        try {
          if (frame.body != null) {
            final json = jsonDecode(frame.body!);
            final myId = await _storage.getUserId();
            if (myId != null) {
              final message = ChatMessage.fromJson(json, myId);
              onMessage(message);
            }
          }
        } catch (e) {
          print('Error parsing message: $e');
        }
      },
    );
    
    // Store unsubscribe function for later cleanup
    _unsubscribeFunctions[conversationId] = unsubscribe;
  }

  /// Unsubscribe from a conversation
  void unsubscribeFromConversation(String conversationId) {
    final unsubscribe = _unsubscribeFunctions[conversationId];
    if (unsubscribe != null) {
      unsubscribe();
      _unsubscribeFunctions.remove(conversationId);
    }
    _subscriptions.remove(conversationId);
  }

  /// Send a message via WebSocket
  void sendMessage(String conversationId, String body) {
    if (!_isConnected || _client == null) {
      throw Exception('WebSocket not connected');
    }

    final message = {
      'conversationId': conversationId,
      'body': body,
    };

    _client!.send(
      destination: '/app/chat.send',
      body: jsonEncode(message),
    );
  }

  /// Callback when WebSocket connects
  void _onConnect(StompFrame frame) {
    print('WebSocket connected');
    _isConnected = true;
  }

  /// Callback when WebSocket disconnects
  void _onDisconnect(StompFrame frame) {
    print('WebSocket disconnected');
    _isConnected = false;
    _subscriptions.clear();
    _unsubscribeFunctions.clear();
  }

  /// Callback for WebSocket errors
  void _onError(dynamic error) {
    print('WebSocket error: $error');
    _isConnected = false;
  }

  /// Callback for STOMP protocol errors
  void _onStompError(StompFrame frame) {
    print('STOMP error: ${frame.body}');
    _isConnected = false;
  }
}
