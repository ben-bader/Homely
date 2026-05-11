import 'package:homely/core/network/api_client.dart';

abstract class ChatRemoteDatasource {
  Future<List<Map<String, dynamic>>> getChatRooms();
  Future<Map<String, dynamic>> createChatRoom(String participantId);
  Future<List<Map<String, dynamic>>> getChatMessages(String roomId);
  Future<Map<String, dynamic>> sendMessage(
    String roomId,
    String message,
    String senderId,
  );
  Future<List<Map<String, dynamic>>> fetchMessages(String conversationId);
  Future<Map<String, dynamic>> createConversation(String propertyId);
  Future<List<Map<String, dynamic>>> fetchConversations();
  Future<Map<String, dynamic>> editMessage({
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

class ChatRemoteDatasourceImpl implements ChatRemoteDatasource {
  @override
  Future<List<Map<String, dynamic>>> getChatRooms() async {
    final response = await ApiClient.get('/chat/rooms');
    return List<Map<String, dynamic>>.from(response ?? []);
  }

  @override
  Future<Map<String, dynamic>> createChatRoom(String participantId) async {
    final response = await ApiClient.post(
      '/chat/rooms',
      body: {'participantId': participantId},
    );
    return response;
  }

  @override
  Future<List<Map<String, dynamic>>> getChatMessages(String roomId) async {
    final response = await ApiClient.get('/chat/rooms/$roomId/messages');
    return List<Map<String, dynamic>>.from(response ?? []);
  }

  @override
  Future<Map<String, dynamic>> sendMessage(
    String roomId,
    String message,
    String senderId,
  ) async {
    final response = await ApiClient.post(
      '/chat/messages',
      body: {'roomId': roomId, 'content': message, 'senderId': senderId},
    );
    return response;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchMessages(
    String conversationId,
  ) async {
    return await getChatMessages(conversationId);
  }

  @override
  Future<Map<String, dynamic>> createConversation(String propertyId) async {
    final response = await ApiClient.post(
      '/chat/conversations',
      body: {'propertyId': propertyId},
    );
    return response;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchConversations() async {
    return await getChatRooms();
  }

  @override
  Future<Map<String, dynamic>> editMessage({
    required String messageId,
    required String content,
    required String userId,
  }) async {
    final response = await ApiClient.put(
      '/chat/messages/$messageId',
      body: {'content': content, 'userId': userId},
    );
    return response;
  }

  @override
  Future<void> deleteMessage({
    required String messageId,
    required String userId,
  }) async {
    await ApiClient.delete('/chat/messages/$messageId?userId=$userId');
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    await ApiClient.delete('/chat/conversations/$conversationId');
  }
}
