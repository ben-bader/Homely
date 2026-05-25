import '../../../domain/entities/chat/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.senderName,
    required super.body,
    required super.sentAt,
    super.messageType,
    super.propertyId,
    super.propertyTitle,
    super.propertyImageUrl,
    super.propertyPrice,
    super.propertyLocation,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      MessageModel(
        id: json['id'].toString(),
        conversationId: json['conversationId'].toString(),
        senderId: json['senderId'].toString(),
        senderName: json['senderName'] ?? '',
        body: json['body'] ?? '',
        sentAt: DateTime.tryParse(json['sentAt'] ?? '') ?? DateTime.now(),
        messageType: json['messageType']?.toString(),
        propertyId: json['propertyId']?.toString(),
        propertyTitle: json['propertyTitle']?.toString(),
        propertyImageUrl: json['propertyImageUrl']?.toString(),
        propertyPrice: json['propertyPrice']?.toString(),
        propertyLocation: json['propertyLocation']?.toString(),
      );
}
