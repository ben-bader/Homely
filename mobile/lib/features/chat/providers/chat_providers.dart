import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../repositories/chat_repository.dart';
import '../services/websocket_service.dart';

// ── Repository ────────────────────────────────────────────────────────────────
final chatRepositoryProvider = Provider<ChatRepository>(
  (_) => ChatRepository(),
);

// ── WebSocket Service ─────────────────────────────────────────────────────────
final websocketServiceProvider = Provider<WebSocketService>(
  (_) => WebSocketService(),
);

// ── Liste des conversations ───────────────────────────────────────────────────
final conversationsProvider =
    FutureProvider.autoDispose<List<Conversation>>((ref) {
  return ref.read(chatRepositoryProvider).fetchConversations();
});

// ── Messages d'une conversation with WebSocket support ────────────────────────
class ChatNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<ChatMessage>, String> {
  WebSocketService? _wsService;
  String? _conversationId;

  @override
  Future<List<ChatMessage>> build(String conversationId) async {
    _conversationId = conversationId;
    _wsService = ref.read(websocketServiceProvider);
    
    // Setup cleanup on dispose
    ref.onDispose(() {
      if (_conversationId != null && _wsService != null) {
        _wsService!.unsubscribeFromConversation(_conversationId!);
      }
    });
    
    // Connect WebSocket if not connected
    if (!_wsService!.isConnected) {
      try {
        await _wsService!.connect();
      } catch (e) {
        print('Failed to connect WebSocket: $e');
      }
    }

    // Subscribe to real-time messages
    _wsService!.subscribeToConversation(conversationId, (message) {
      final current = state.valueOrNull ?? [];
      if (!current.any((m) => m.id == message.id)) {
        state = AsyncData([...current, message]);
      }
    });

    // Load existing messages
    final repo = ref.read(chatRepositoryProvider);
    return repo.fetchMessages(conversationId);
  }

  Future<void> send(String body) async {
    if (_conversationId == null || _wsService == null) return;
    
    try {
      // Optimistically add message to UI
      final current = state.valueOrNull ?? [];
      final now = DateTime.now();
      final tempMessage = ChatMessage(
        id: 'temp-${now.millisecondsSinceEpoch}',
        conversationId: _conversationId!,
        senderId: '', // Will be set by backend
        body: body,
        sentAt: now,
        isMe: true,
      );
      state = AsyncData([...current, tempMessage]);

      // Send via WebSocket
      _wsService!.sendMessage(_conversationId!, body);
    } catch (e) {
      // Revert optimistic update on error
      final repo = ref.read(chatRepositoryProvider);
      final messages = await repo.fetchMessages(_conversationId!);
      state = AsyncData(messages);
      rethrow;
    }
  }

}

final chatNotifierProvider = AsyncNotifierProvider.autoDispose
    .family<ChatNotifier, List<ChatMessage>, String>(ChatNotifier.new);