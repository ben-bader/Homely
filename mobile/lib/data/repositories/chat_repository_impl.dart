import '../../domain/entities/chat/conversation_entity.dart';
import '../../domain/entities/chat/message_entity.dart';
import '../../domain/repositories/i_chat_repository.dart';
import '../datasources/remote/chat_remote_datasource.dart';
import '../models/chat/conversation_model.dart';
import '../models/chat/message_model.dart';

class ChatRepositoryImpl implements IChatRepository {
  final ChatRemoteDatasource _remote;

  ChatRepositoryImpl(this._remote);

  @override
  Future<List<MessageEntity>> fetchMessages(
      String conversationId, {int page = 0, int size = 50}) async {
    final data = await _remote.fetchMessages(conversationId, page: page, size: size);
    return data
        .map((e) =>
            MessageModel.fromJson(e))
        .toList();
  }

  @override
  Future<ConversationEntity> createConversation(
      String propertyId) async {
    final data = await _remote.createConversation(propertyId);
    return ConversationModel.fromJson(data);
  }

  @override
  Future<ConversationEntity> createChatRoom(String participantId) async {
    final data = await _remote.createChatRoom(participantId);
    return ConversationModel.fromJson(data);
  }

  @override
  Future<List<ConversationEntity>> fetchConversations() async {
    final data = await _remote.fetchConversations();
    return data
        .map((e) =>
            ConversationModel.fromJson(e))
        .toList();
  }

  @override
  Future<MessageEntity> editMessage({
    required String messageId,
    required String content,
    required String userId,
  }) async {
    final data = await _remote.editMessage(
        messageId: messageId, content: content, userId: userId);
    return MessageModel.fromJson(data);
  }

  @override
  Future<void> deleteMessage({
    required String messageId,
    required String userId,
  }) =>
      _remote.deleteMessage(messageId: messageId, userId: userId);

  @override
  Future<void> deleteConversation(String conversationId) =>
      _remote.deleteConversation(conversationId);
}
