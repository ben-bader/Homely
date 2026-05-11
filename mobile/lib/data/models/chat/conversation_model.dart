import '../../../domain/entities/chat/conversation_entity.dart';

class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    required super.propertyId,
    required super.clientId,
    required super.sellerId,
    super.sellerName,
    super.clientName,
    super.sellerAvatar,
    super.clientAvatar,
    super.propertyTitle,
    super.lastMessage,
    super.lastAt,
    super.unread,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      ConversationModel(
        id: json['id']?.toString() ?? '',
        propertyId: json['propertyId']?.toString() ?? '',
        clientId: json['clientId']?.toString() ?? '',
        sellerId: json['sellerId']?.toString() ?? '',
        sellerName: json['sellerName']?.toString(),
        clientName: json['clientName']?.toString(),
        sellerAvatar: json['sellerAvatar']?.toString(),
        clientAvatar: json['clientAvatar']?.toString(),
        propertyTitle: json['propertyTitle']?.toString(),
        lastMessage: json['lastMessage']?.toString(),
        lastAt: json['lastMessageAt'] != null
            ? DateTime.tryParse(json['lastMessageAt'].toString())
            : null,
        unread: json['unreadCount'] ?? json['unread'] ?? 0,
      );
}
