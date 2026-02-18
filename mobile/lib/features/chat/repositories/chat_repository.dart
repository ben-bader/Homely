import 'package:mobile/core/storage/secure_storage.dart';
import 'package:mobile/core/network/api_client.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class ChatRepository {
  final _storage = SecureStorage();

  Future<String> _myId() async => (await _storage.getUserId()) ?? '';

  // POST /api/chat/conversations/{propertyId}
  // Creates or gets existing conversation for a property
  Future<Conversation> createConversation(String propertyId) async {
    final data = await ApiClient.post('/api/chat/conversations/$propertyId');
    return Conversation.fromJson(data);
  }

  // GET /api/chat/conversations
  // Fetches all conversations for the current user
  Future<List<Conversation>> fetchConversations() async {
    final data = await ApiClient.get('/api/chat/conversations');
    final list = data is List ? data : [];
    return list.map((e) => Conversation.fromJson(e)).toList();
  }

  // GET /api/chat/messages?conversationId={conversationId}
  Future<List<ChatMessage>> fetchMessages(String conversationId) async {
    final myId = await _myId();
    final data = await ApiClient.get(
      '/api/chat/messages',
      queryParams: {'conversationId': conversationId},
    );
    final list = data is List ? data : [];
    return list.map((e) => ChatMessage.fromJson(e, myId)).toList();
  }
}
