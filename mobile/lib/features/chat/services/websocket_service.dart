import 'dart:async';
import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:mobile/core/storage/secure_storage.dart';
import '../models/message.dart';

class WebSocketService {
  static final WebSocketService _instance =
      WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  final SecureStorage _storage = SecureStorage();

  StompClient? _client;
  bool _connected = false;
  Completer<void>? _connectionCompleter;

  final Map<String, void Function()> _subscriptions = {};

  bool get isConnected => _connected;

  String get baseUrl {
    final apiBaseUrl =
        'https://zcvxc076-8082.uks1.devtunnels.ms';

    return apiBaseUrl
            .replaceFirst('https://', 'wss://')
            .replaceAll('/api', '') +
        '/ws';
  }

  Future<void> connect() async {
    if (_connected) return;

    _connectionCompleter = Completer<void>();

    final token = await _storage.getToken();
    if (token == null) {
      throw Exception('No token found');
    }

    _client = StompClient(
      config: StompConfig(
        url: baseUrl,
        stompConnectHeaders: {
          'Authorization': 'Bearer $token',
        },
        webSocketConnectHeaders: {
          'Authorization': 'Bearer $token',
        },
        onConnect: (frame) {
          _connected = true;
          _connectionCompleter?.complete();
        },
        onDisconnect: (_) {
          _connected = false;
        },
        reconnectDelay: const Duration(seconds: 5),
      ),
    );

    _client!.activate();
    return _connectionCompleter!.future;
  }

  Future<void> subscribe(
    String conversationId,
    Function(ChatMessage) onMessage,
  ) async {
    if (!_connected) {
      await connect();
    }

    if (_subscriptions.containsKey(conversationId)) return;

    final unsubscribe = _client!.subscribe(
      destination:
          '/user/queue/conversations/$conversationId',
      callback: (StompFrame frame) {
        if (frame.body == null) return;

        final json = jsonDecode(frame.body!);
        final message =
            ChatMessage.fromJson(json as Map<String, dynamic>);
        onMessage(message);
      },
    );

    _subscriptions[conversationId] = unsubscribe;
  }

  void unsubscribe(String conversationId) {
    final unsub = _subscriptions.remove(conversationId);
    unsub?.call();
  }

  void sendMessage(String conversationId, String body) {
    if (!_connected || _client == null) return;

    _client!.send(
      destination: '/app/chat.send',
      body: jsonEncode({
        'conversationId': conversationId,
        'body': body,
      }),
    );
  }

  void disconnect() {
    for (final unsub in _subscriptions.values) {
      unsub();
    }
    _subscriptions.clear();
    _client?.deactivate();
    _connected = false;
  }
}
