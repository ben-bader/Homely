import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:mobile/features/auth/services/auth_service.dart';
import '../models/message.dart';

class WebSocketService {
  StompClient? _client;
  bool _connected = false;

  bool get isConnected => _connected;

  final AuthService _authService = AuthService();

  Future<void> connect() async {
    if (_connected) return;

    final token = await _authService.getToken();

    if (token == null) {
      print("No token found for WebSocket");
      return;
    }

    _client = StompClient(
      config: StompConfig.sockJS(
        url: 'http://YOUR_SERVER/ws', // 🔥 change to your real backend
        stompConnectHeaders: {
          'Authorization': 'Bearer $token',
        },
        webSocketConnectHeaders: {
          'Authorization': 'Bearer $token',
        },
        onConnect: (frame) {
          _connected = true;
          print("✅ WebSocket Connected");
        },
        onWebSocketError: (error) {
          print("❌ WebSocket error: $error");
        },
        onDisconnect: (frame) {
          _connected = false;
          print("🔌 WebSocket Disconnected");
        },
      ),
    );

    _client!.activate();
  }

  void subscribe(
    String conversationId,
    Function(ChatMessage) onMessage,
  ) {
    if (!_connected) {
      print("WebSocket not connected");
      return;
    }

    _client?.subscribe(
      destination: '/topic/conversations/$conversationId',
      callback: (frame) {
        if (frame.body != null) {
          final data = jsonDecode(frame.body!);
          final message = ChatMessage.fromJson(data);
          onMessage(message);
        }
      },
    );

    print("📩 Subscribed to /topic/conversations/$conversationId");
  }

  void sendMessage(String conversationId, String body) {
    if (!_connected) return;

    _client?.send(
      destination: '/app/chat.send',
      body: jsonEncode({
        "conversationId": conversationId,
        "body": body,
        "attachments": []
      }),
    );
  }

  void disconnect() {
    _client?.deactivate();
    _connected = false;
  }
}
