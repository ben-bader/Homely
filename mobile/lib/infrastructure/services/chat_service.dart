import 'dart:async';
import 'dart:convert';
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

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  Future<void> init() async {
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
        onWebSocketError: (error) => print('Chat WebSocket error: $error'),
        onStompError: (error) => print('Chat STOMP error: $error'),
        onDisconnect: (frame) => print('Chat Disconnected: $frame'),
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
      ),
    );
    _stompClient?.activate();
  }

  void _onConnect(StompFrame frame) {
    print('Connected to Chat STOMP');

    // Subscribe to user's chat messages
    final userId = _storage.getUserId();
    if (userId != null) {
      _stompClient?.subscribe(
        destination: '/user/$userId/chat',
        callback: (frame) {
          final message = jsonDecode(frame.body ?? '{}');
          _messageController.add(message);
        },
      );
    }
  }

  bool get isConnected => _stompClient?.isActive ?? false;

  Future<void> connect({void Function()? onConnected}) async {
    final token = await _storage.getToken();
    if (token != null) {
      _connect(token);
      // Wait a bit for connection
      await Future.delayed(const Duration(seconds: 1));
      onConnected?.call();
    }
  }

  void subscribe(
    String conversationId,
    void Function(Map<String, dynamic>) onMessage,
  ) {
    if (_stompClient?.isActive == true) {
      _stompClient?.subscribe(
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
    _stompClient?.deactivate();
    _messageController.close();
  }
}
