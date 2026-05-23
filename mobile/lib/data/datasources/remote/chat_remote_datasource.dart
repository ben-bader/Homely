import 'package:homely/core/network/api_client.dart';
import 'package:homely/core/network/endpoints.dart';

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
  final Set<String> _inFlightSends = {};
  @override
  Future<List<Map<String, dynamic>>> getChatRooms() async {
    try {
      final response = await ApiClient.get(Endpoints.chatConversations);
      return List<Map<String, dynamic>>.from(response ?? []);
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  @override
  Future<Map<String, dynamic>> createChatRoom(String participantId) async {
    try {
      final response = await ApiClient.post(
        Endpoints.createChatConversation(participantId),
        body: {'participantId': participantId},
      );
      return response as Map<String, dynamic>? ?? <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getChatMessages(String roomId) async {
    try {
      final response = await ApiClient.get(
        Endpoints.chatMessages,
        queryParams: {'conversationId': roomId},
      );
      return List<Map<String, dynamic>>.from(response ?? []);
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  @override
  Future<Map<String, dynamic>> sendMessage(
    String roomId,
    String message,
    String senderId,
  ) async {
    if (message.trim().isEmpty) return <String, dynamic>{};
    final key = '$roomId:${message.hashCode}';
    if (_inFlightSends.contains(key)) return <String, dynamic>{};
    _inFlightSends.add(key);
    try {
      final response = await ApiClient.post(
        Endpoints.chatMessages,
        body: {'roomId': roomId, 'content': message, 'senderId': senderId},
      );
      return response as Map<String, dynamic>? ?? <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    } finally {
      _inFlightSends.remove(key);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchMessages(
    String conversationId,
  ) async {
    return await getChatMessages(conversationId);
  }

  @override
  Future<Map<String, dynamic>> createConversation(String propertyId) async {
    try {
      final response = await ApiClient.post(
        Endpoints.createChatConversation(propertyId),
        body: {'propertyId': propertyId},
      );
      return response as Map<String, dynamic>? ?? <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
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
    try {
      final response = await ApiClient.put(
        Endpoints.editChatMessage(messageId),
        queryParams: {'content': content, 'userId': userId},
      );
      return response as Map<String, dynamic>? ?? <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  @override
  Future<void> deleteMessage({
    required String messageId,
    required String userId,
  }) async {
    try {
      await ApiClient.delete(
        Endpoints.deleteChatMessage(messageId),
        queryParams: {'userId': userId},
      );
    } catch (_) {
      // ignore
    }
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    try {
      await ApiClient.delete('/chat/conversations/$conversationId');
    } catch (_) {
      // ignore
    }
  }
}
