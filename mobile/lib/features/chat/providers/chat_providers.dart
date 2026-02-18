import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../repositories/chat_repository.dart';
import '../services/websocket_service.dart';

/// Repository
final chatRepositoryProvider =
    Provider((ref) => ChatRepository());

/// Websocket
final websocketServiceProvider =
    Provider((ref) => WebSocketService());

/// 🔹 Conversations Provider (THIS FIXES YOUR ERROR)
final conversationsProvider =
    FutureProvider<List<Conversation>>((ref) async {
  final repo = ref.read(chatRepositoryProvider);
  return repo.fetchConversations();
});

/// 🔹 Chat Messages Provider
final chatProvider = StateNotifierProvider.family<
    ChatNotifier, List<ChatMessage>, String>(
  (ref, conversationId) =>
      ChatNotifier(ref, conversationId),
);

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final Ref ref;
  final String conversationId;

  ChatNotifier(this.ref, this.conversationId)
      : super([]) {
    _init();
  }

  Future<void> _init() async {
    final repo = ref.read(chatRepositoryProvider);
    final ws = ref.read(websocketServiceProvider);

    if (!ws.isConnected) {
      await ws.connect();
    }

    final messages =
        await repo.fetchMessages(conversationId);
    state = messages;

    await ws.subscribe(conversationId, (message) {
      if (!state.any((m) => m.id == message.id)) {
        state = [...state, message];
      }
    });
  }

  void send(String body) {
    if (body.trim().isEmpty) return;

    final ws = ref.read(websocketServiceProvider);
    ws.sendMessage(conversationId, body);
  }
}
