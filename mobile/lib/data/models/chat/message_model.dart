import '../../../domain/entities/chat/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.senderName,
    required super.body,
    required super.sentAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      MessageModel(
        id: json['id'].toString(),
        conversationId: json['conversationId'].toString(),
        senderId: json['senderId'].toString(),
        senderName: json['senderName'] ?? '',
        body: json['body'] ?? '',
        sentAt: DateTime.tryParse(json['sentAt'] ?? '') ?? DateTime.now(),
      );
}
