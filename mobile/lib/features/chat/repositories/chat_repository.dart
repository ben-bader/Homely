import 'package:mobile/core/storage/secure_storage.dart';
import 'package:mobile/core/network/api_client.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class ChatRepository {
  final _storage = SecureStorage();

  Future<String> _myId() async => (await _storage.getUserId()) ?? '';

  // GET /chat/conversations
  Future<List<Conversation>> fetchConversations() async {
    final data = await ApiClient.get('/chat/conversations');
    final list = data is List
        ? data
        : (data['content'] ?? data['data'] ?? []) as List;
    return list.map((e) => Conversation.fromJson(e)).toList();
  }

  // GET /chat/conversation/{id}/messages
  Future<List<ChatMessage>> fetchMessages(String conversationId) async {
    final myId = await _myId();
    final data = await ApiClient.get(
      '/chat/conversation/$conversationId/messages',
    );
    final list = data is List ? data : (data['content'] ?? []) as List;
    return list.map((e) => ChatMessage.fromJson(e, myId)).toList();
  }

  // POST /chat/conversation
  // Body: ConversationCreateRequest { sellerId, propertyId }
  Future<Conversation> startConversation(
    String sellerId,
    String propertyId,
  ) async {
    final data = await ApiClient.post(
      '/chat/conversation',
      body: {'sellerId': sellerId, 'propertyId': propertyId},
    );
    return Conversation.fromJson(data);
  }

  // POST /chat/message
  // Body: MessageCreateRequest { conversationId, content }
  Future<ChatMessage> sendMessage(String conversationId, String content) async {
    final myId = await _myId();
    final data = await ApiClient.post(
      '/chat/message',
      body: {'conversationId': conversationId, 'content': content},
    );
    return ChatMessage.fromJson(data, myId);
  }
}
