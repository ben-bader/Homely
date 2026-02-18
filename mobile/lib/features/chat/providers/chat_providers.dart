import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../repositories/chat_repository.dart';

// ── Repository ────────────────────────────────────────────────────────────────
final chatRepositoryProvider = Provider<ChatRepository>(
  (_) => ChatRepository(),
);

// ── Liste des conversations ───────────────────────────────────────────────────
final conversationsProvider =
    FutureProvider.autoDispose<List<Conversation>>((ref) {
  return ref.read(chatRepositoryProvider).fetchConversations();
});

// ── Messages d'une conversation ───────────────────────────────────────────────
class ChatNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<ChatMessage>, String> {
  @override
  Future<List<ChatMessage>> build(String conversationId) {
    return ref.read(chatRepositoryProvider).fetchMessages(conversationId);
  }

  Future<void> send(String content) async {
    final repo = ref.read(chatRepositoryProvider);
    final current = state.valueOrNull ?? [];
    try {
      final msg = await repo.sendMessage(arg, content);
      state = AsyncData([...current, msg]);
    } catch (_) {
      // optionnellement afficher une erreur
    }
  }
}

final chatNotifierProvider = AsyncNotifierProvider.autoDispose
    .family<ChatNotifier, List<ChatMessage>, String>(ChatNotifier.new);