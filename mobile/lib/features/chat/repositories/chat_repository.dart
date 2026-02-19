import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/storage/secure_storage.dart';
import '../models/message.dart';
import '../models/conversation.dart';

class ChatRepository {
  final String baseUrl =
      "https://unparrying-christene-reductively.ngrok-free.dev";

  final SecureStorage _storage = SecureStorage();

  Future<Map<String, String>> _headers() async {
    final token = await _storage.getToken();

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ✅ FETCH MESSAGES
  Future<List<ChatMessage>> fetchMessages(
      String conversationId) async {
    final response = await http.get(
      Uri.parse(
          "$baseUrl/api/chat/messages?conversationId=$conversationId"),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(
          "Failed to load messages: ${response.statusCode}");
    }

    final decoded = jsonDecode(response.body);

    // If backend returns List
    if (decoded is List) {
      return decoded
          .map((e) =>
              ChatMessage.fromJson(
                  e as Map<String, dynamic>))
          .toList();
    }

    // If backend returns { content: [...] }
    if (decoded is Map &&
        decoded['content'] is List) {
      return (decoded['content'] as List)
          .map((e) =>
              ChatMessage.fromJson(
                  e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  // ✅ CREATE CONVERSATION
  Future<Conversation> createConversation(
      String propertyId) async {
    final response = await http.post(
      Uri.parse(
          "$baseUrl/api/chat/conversations/$propertyId"),
      headers: await _headers(),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception(
          "Failed to create conversation");
    }

    final decoded =
        jsonDecode(response.body);

    return Conversation.fromJson(
        decoded as Map<String, dynamic>);
  }

  // ✅ FETCH CONVERSATIONS
  Future<List<Conversation>>
      fetchConversations() async {
    final response = await http.get(
      Uri.parse(
          "$baseUrl/api/chat/conversations"),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(
          "Failed to load conversations: ${response.statusCode}");
    }

    final decoded =
        jsonDecode(response.body);

    if (decoded is List) {
      return decoded
          .map((e) =>
              Conversation.fromJson(
                  e as Map<String, dynamic>))
          .toList();
    }

    if (decoded is Map &&
        decoded['content'] is List) {
      return (decoded['content'] as List)
          .map((e) =>
              Conversation.fromJson(
                  e as Map<String, dynamic>))
          .toList();
    }

    if (decoded is Map &&
        decoded['data'] is List) {
      return (decoded['data'] as List)
          .map((e) =>
              Conversation.fromJson(
                  e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }
}
