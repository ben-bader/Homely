import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/chat_remote_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/chat/conversation_entity.dart';
import '../../domain/entities/chat/message_entity.dart';
import '../../domain/repositories/i_chat_repository.dart';
import '../../infrastructure/services/chat_service.dart';

final chatRemoteDatasourceProvider = Provider<ChatRemoteDatasource>(
  (ref) => ChatRemoteDatasourceImpl(),
);

final chatRepositoryProvider = Provider<IChatRepository>((ref) {
  return ChatRepositoryImpl(ref.read(chatRemoteDatasourceProvider));
});

final chatServiceProvider = Provider<ChatService>((ref) => ChatService());

final conversationsProvider = FutureProvider<List<ConversationEntity>>((
  ref,
) async {
  return ref.read(chatRepositoryProvider).fetchConversations();
});

final chatProvider =
    StateNotifierProvider.family<
      ChatNotifier,
      AsyncValue<List<MessageEntity>>,
      String
    >((ref, conversationId) => ChatNotifier(ref, conversationId));

class ChatNotifier extends StateNotifier<AsyncValue<List<MessageEntity>>> {
  final Ref _ref;
  final String conversationId;
  bool _subscribed = false;

  ChatNotifier(this._ref, this.conversationId)
    : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final messages = await _repo.fetchMessages(conversationId);
      if (mounted) state = AsyncValue.data(messages);
      if (_ws.isConnected) {
        _subscribe();
        return;
      }
      await _ws.connect(onConnected: _subscribe);
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }

  void _subscribe() {
    if (_subscribed) return;
    _subscribed = true;
    _ws.subscribe(conversationId, _onMessageReceived);
  }

  void _onMessageReceived(Map<String, dynamic> incoming) {
    final message = MessageEntity(
      id: incoming['id'] ?? '',
      conversationId: incoming['conversationId'] ?? '',
      senderId: incoming['senderId'] ?? '',
      senderName: incoming['senderName'] ?? '',
      body: incoming['body'] ?? '',
      sentAt: DateTime.parse(
        incoming['sentAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
    if (!mounted) return;
    state.whenData((current) {
      final alreadyExists = current.any((m) => m.id == message.id);
      if (!alreadyExists) {
        state = AsyncValue.data([...current, message]);
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

  Future<void> editMessage(
    String messageId,
    String newText,
    String userId,
  ) async {
    try {
      final updated = await _repo.editMessage(
        messageId: messageId,
        content: newText,
        userId: userId,
      );
      state.whenData((current) {
        state = AsyncValue.data(
          current.map((m) => m.id == messageId ? updated : m).toList(),
        );
      });
    } catch (_) {}
  }

  Future<void> deleteMessage(String messageId, String userId) async {
    try {
      await _repo.deleteMessage(messageId: messageId, userId: userId);
      state.whenData((current) {
        state = AsyncValue.data(
          current.where((m) => m.id != messageId).toList(),
        );
      });
    } catch (_) {}
  }

  IChatRepository get _repo => _ref.read(chatRepositoryProvider);
  ChatService get _ws => _ref.read(chatServiceProvider);
}
