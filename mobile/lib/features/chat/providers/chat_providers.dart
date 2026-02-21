import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../repositories/chat_repository.dart';
import '../services/websocket_service.dart';

// ─────────────────────────────────────────────────────────────
// Core Providers
// ─────────────────────────────────────────────────────────────

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepository(),
);

final websocketServiceProvider = Provider<WebSocketService>(
  (ref) => WebSocketService(),
);

// ─────────────────────────────────────────────────────────────
// Conversations Provider
// ─────────────────────────────────────────────────────────────

final conversationsProvider = FutureProvider<List<Conversation>>((ref) async {
  final repo = ref.read(chatRepositoryProvider);
  return repo.fetchConversations();
});

// ─────────────────────────────────────────────────────────────
// Chat Provider (per conversation)
// ─────────────────────────────────────────────────────────────

final chatProvider = StateNotifierProvider.family<  // ← was missing 
    ChatNotifier,
    AsyncValue<List<ChatMessage>>,
    String>(
  (ref, conversationId) => ChatNotifier(ref, conversationId),
);

// ─────────────────────────────────────────────────────────────
// Chat Notifier
// ─────────────────────────────────────────────────────────────

class ChatNotifier extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  final Ref _ref;
  final String conversationId;
  bool _subscribed = false; // ← guard against double subscription

  ChatNotifier(this._ref, this.conversationId)
      : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      // 1. Load existing messages from REST
      final messages = await _repo.fetchMessages(conversationId);
      if (mounted) state = AsyncValue.data(messages);

      // 2. Already connected → subscribe immediately
      if (_ws.isConnected) {
        _subscribe();
        return;
      }

      // 3. Not connected → connect, then subscribe via callback
      await _ws.connect(onConnected: _subscribe);

    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }

  void _subscribe() {
    if (_subscribed) return; // prevent duplicate subscriptions
    _subscribed = true;
    _ws.subscribe(conversationId, _onMessageReceived);
  }

  void _onMessageReceived(ChatMessage incoming) {
    if (!mounted) return;
    state.whenData((current) {
      final alreadyExists = current.any((m) => m.id == incoming.id);
      if (!alreadyExists) {
        state = AsyncValue.data([...current, incoming]);
      }
    });
  }

  void send(String body) {
    final text = body.trim();
    if (text.isEmpty) return;
    _ws.sendMessage(conversationId, text);
  }

  Future<void> retry() async {
    _subscribed = false;
    state = const AsyncValue.loading();
    await _init();
  }

  ChatRepository get _repo => _ref.read(chatRepositoryProvider);
  WebSocketService get _ws => _ref.read(websocketServiceProvider);
}