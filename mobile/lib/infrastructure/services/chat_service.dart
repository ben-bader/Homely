import 'dart:async';
import 'realtime_service.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final RealtimeService _realtime = RealtimeService();
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();
  final Map<String, void Function(Map<String, dynamic>)> _subscriptions = {};

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  bool get isConnected => _realtime.isConnected;

  Future<void> init() async {
    await _realtime.init();
  }

  Future<void> connect({void Function()? onConnected}) async {
    await _realtime.connect(onConnected: onConnected);
  }

  void subscribe(
    String conversationId,
    void Function(Map<String, dynamic>) onMessage,
  ) {
    _subscriptions[conversationId] = onMessage;
    _realtime.subscribe(
      '/topic/chat/$conversationId',
      (payload) {
        onMessage(payload);
        _messageController.add(payload);
      },
    );
  }

  void unsubscribe(
    String conversationId,
    void Function(Map<String, dynamic>) onMessage,
  ) {
    _realtime.unsubscribe('/topic/chat/$conversationId', onMessage);
    _subscriptions.remove(conversationId);
  }

  void sendMessage(String conversationId, String content, {String? propertyId}) {
    final body = content.trim();
    if (body.isEmpty) return;

    final Map<String, dynamic> payload = {
      'content': body,
      'body': body,
      'messageType': 'TEXT',
    };

    if (conversationId.isNotEmpty && conversationId != 'null' && !conversationId.startsWith('new_')) {
      payload['conversationId'] = conversationId;
    }
    if (propertyId != null && propertyId.isNotEmpty && propertyId != 'null') {
      payload['propertyId'] = propertyId;
    }

    _realtime.send('/app/chat.send', payload);
  }

  void disconnect() {
    _realtime.disconnect();
    if (!_messageController.isClosed) {
      _messageController.close();
    }
  }
}
