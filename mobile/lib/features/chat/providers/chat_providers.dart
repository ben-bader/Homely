import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../repositories/chat_repository.dart';
import '../services/websocket_service.dart';

/// Repository
final chatRepositoryProvider =
    Provider((ref) => ChatRepository());

/// WebSocket
final websocketServiceProvider =
    Provider((ref) => WebSocketService());

/// 🔹 Conversations Provider
final conversationsProvider =
    FutureProvider<List<Conversation>>((ref) async {
  final repo = ref.read(chatRepositoryProvider);
  return repo.fetchConversations();
});

/// 🔹 Chat Messages Provider
final chatProvider = StateNotifierProvider.family<
    ChatNotifier,
    AsyncValue<List<ChatMessage>>,
    String>((ref, conversationId) {
  return ChatNotifier(ref, conversationId);
});

class ChatNotifier
    extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  final Ref ref;
  final String conversationId;

  ChatNotifier(this.ref, this.conversationId)
      : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
  try {
    final repo = ref.read(chatRepositoryProvider);
    final ws = ref.read(websocketServiceProvider);

    if (!ws.isConnected) {
      await ws.connect();
    }

    final messages = await repo.fetchMessages(conversationId);
    state = AsyncValue.data(messages);

    ws.subscribe(conversationId, (message) {
      state.whenData((current) {
        if (!current.any((m) => m.id == message.id)) {
          state = AsyncValue.data([...current, message]);
        }
      });
    });

  } catch (e, st) {
    state = AsyncValue.error(e, st);
  }
}


  void send(String body) {
    if (body.trim().isEmpty) return;

    final ws = ref.read(websocketServiceProvider);
    ws.sendMessage(conversationId, body);
  }
}
