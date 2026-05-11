import '../entities/chat/conversation_entity.dart';
import '../entities/chat/message_entity.dart';

abstract class IChatRepository {
  Future<List<MessageEntity>> fetchMessages(String conversationId);
  Future<ConversationEntity> createConversation(String propertyId);
  Future<List<ConversationEntity>> fetchConversations();
  Future<MessageEntity> editMessage({
    required String messageId,
    required String content,
    required String userId,
  });
  Future<void> deleteMessage({
    required String messageId,
    required String userId,
  });
  Future<void> deleteConversation(String conversationId);
}
