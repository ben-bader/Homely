import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/endpoints.dart';
import '../models/message.dart';
import '../models/conversation.dart';

class ChatRepository {
  // repository now proxies through ApiClient; headers managed globally

  // ✅ FETCH MESSAGES
  Future<List<ChatMessage>> fetchMessages(
      String conversationId) async {
    final data = await ApiClient.get(
      Endpoints.chatMessages,
      queryParams: {'conversationId': conversationId},
      auth: true,
    );

    if (data is List) {
      return data
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (data is Map && data['content'] is List) {
      return (data['content'] as List)
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  // ✅ CREATE CONVERSATION
  Future<Conversation> createConversation(
      String propertyId) async {
    final data = await ApiClient.post(
      Endpoints.createChatConversation(propertyId),
      auth: true,
    );

    return Conversation.fromJson(data as Map<String, dynamic>);
  }

  // ✅ FETCH CONVERSATIONS
  Future<List<Conversation>> fetchConversations() async {
    final data = await ApiClient.get(
      Endpoints.chatConversations,
      auth: true,
    );

    if (data is List) {
      return data
          .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (data is Map && data['content'] is List) {
      return (data['content'] as List)
          .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
  // ✅ EDIT MESSAGE
  Future<ChatMessage> editMessage({
    required String messageId,
    required String content,
    required String userId,
  }) async {
    final data = await ApiClient.put(
      Endpoints.editChatMessage(messageId),
      queryParams: {
        'content': content,
        'userId': userId,
      },
      auth: true,
    );
    return ChatMessage.fromJson(data);
  }

  // ✅ DELETE MESSAGE
  Future<void> deleteMessage({
    required String messageId,
    required String userId,
  }) async {
    await ApiClient.delete(
      Endpoints.deleteChatMessage(messageId),
      queryParams: {'userId': userId},
      auth: true,
    );
  }

  // ✅ DELETE CONVERSATION (only removes if it has no messages)
  Future<void> deleteConversation(String conversationId) async {
    await ApiClient.delete(
      '/chat/conversations/$conversationId',
      auth: true,
    );
  }
}
