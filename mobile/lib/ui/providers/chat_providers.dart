import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/chat_remote_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/chat/conversation_entity.dart';
import '../../domain/entities/chat/message_entity.dart';
import '../../domain/repositories/i_chat_repository.dart';
import '../../infrastructure/services/chat_service.dart';
import '../../infrastructure/services/notification_service.dart';

final chatRemoteDatasourceProvider = Provider<ChatRemoteDatasource>(
  (ref) => ChatRemoteDatasourceImpl(),
);

final chatRepositoryProvider = Provider<IChatRepository>((ref) {
  return ChatRepositoryImpl(ref.read(chatRemoteDatasourceProvider));
});

final chatServiceProvider = Provider<ChatService>((ref) => ChatService());

final notificationStreamProvider = StreamProvider.autoDispose<Map<String, dynamic>>(
  (ref) => NotificationService().notificationStream,
);

final chatEventStreamProvider = StreamProvider.autoDispose<Map<String, dynamic>>(
  (ref) => ref.read(chatServiceProvider).messageStream,
);

final conversationsProvider = FutureProvider<List<ConversationEntity>>(
  (ref) async {
    return ref.read(chatRepositoryProvider).fetchConversations();
  },
);

/// Find an existing conversation between current user and [otherUserId],
/// or create one (by property or direct chat) and return its id.
Future<String?> findOrCreateConversation(WidgetRef ref, String currentUserId, String otherUserId, {String? propertyId}) async {
  try {
    final repo = ref.read(chatRepositoryProvider);
    final convs = await repo.fetchConversations();
    for (final c in convs) {
      if ((c.participantOneId == currentUserId && c.participantTwoId == otherUserId) ||
          (c.participantOneId == otherUserId && c.participantTwoId == currentUserId)) {
        return c.id;
      }
    }

    if (propertyId != null && propertyId.isNotEmpty) {
      final conv = await repo.createConversation(propertyId);
      return conv.id;
    }

    final conv = await repo.createChatRoom(otherUserId);
    return conv.id;
  } catch (_) {
    return null;
  }
}

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
  late final void Function(Map<String, dynamic>) _wsCallback;
  int _page = 0;
  static const int _pageSize = 50;
  bool _hasMore = true;

  ChatNotifier(this._ref, this.conversationId)
    : super(const AsyncValue.loading()) {
    _wsCallback = _onMessageReceived;
    _init();
  }

  Future<void> _init() async {
    try {
      final messages = await _loadPage(_page);
      if (mounted) {
        state = AsyncValue.data(messages);
      }

      if (!_ws.isConnected) {
        await _ws.connect(onConnected: () {
          if (mounted) _subscribe();
        });
      } else {
        if (mounted) _subscribe();
      }
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }

  Future<List<MessageEntity>> _loadPage(int page) async {
    final messages = await _repo.fetchMessages(
      conversationId,
      page: page,
      size: _pageSize,
    );
    if (messages.length < _pageSize) {
      _hasMore = false;
    }
    return messages;
  }

  Future<void> loadMoreMessages() async {
    if (!_hasMore || !mounted) return;
    _page += 1;
    final nextPage = await _loadPage(_page);
    if (!mounted || nextPage.isEmpty) return;
    state.whenData((current) {
      state = AsyncValue.data([...current, ...nextPage]);
    });
  }

  void _subscribe() {
    if (_subscribed || !mounted) return;
    _subscribed = true;
    _ws.subscribe(conversationId, _wsCallback);
  }

  void _onMessageReceived(Map<String, dynamic> incoming) {
    final message = MessageEntity(
      id: incoming['id']?.toString() ?? '',
      conversationId: incoming['conversationId']?.toString() ?? '',
      senderId: incoming['senderId']?.toString() ?? '',
      senderName: incoming['senderName']?.toString() ?? '',
      body: incoming['body']?.toString() ?? '',
      sentAt: DateTime.tryParse(incoming['sentAt']?.toString() ?? '') ??
          DateTime.now(),
      messageType: incoming['messageType']?.toString(),
      propertyId: incoming['propertyId']?.toString(),
      propertyTitle: incoming['propertyTitle']?.toString(),
      propertyImageUrl: incoming['propertyImageUrl']?.toString(),
      propertyPrice: incoming['propertyPrice']?.toString(),
      propertyLocation: incoming['propertyLocation']?.toString(),
    );
    if (!mounted) return;

    state.when(
      data: (current) {
        final alreadyExists = current.any((m) => m.id == message.id);
        if (!alreadyExists) {
          state = AsyncValue.data([...current, message]);
        }
      },
      loading: () {
        state = AsyncValue.data([message]);
      },
      error: (error, stack) {
        state = AsyncValue.data([message]);
      },
    );
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

  @override
  void dispose() {
    if (_subscribed) {
      _ws.unsubscribe(conversationId, _wsCallback);
      _subscribed = false;
    }
    super.dispose();
  }

  IChatRepository get _repo => _ref.read(chatRepositoryProvider);
  ChatService get _ws => _ref.read(chatServiceProvider);
}
