import '../../../domain/entities/chat/conversation_entity.dart';

class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    required super.propertyId,
    required super.participantOneId,
    required super.participantTwoId,
    super.participantOneName,
    super.participantTwoName,
    super.participantOneAvatar,
    super.participantTwoAvatar,
    super.propertyTitle,
    super.lastMessage,
    super.lastMessageType,
    super.lastAt,
    super.unread,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      ConversationModel(
        id: json['id']?.toString() ?? '',
        propertyId: json['propertyId']?.toString() ?? '',
        participantOneId: json['participantOneId']?.toString() ?? '',
        participantTwoId: json['participantTwoId']?.toString() ?? '',
        participantOneName: json['participantOneName']?.toString(),
        participantTwoName: json['participantTwoName']?.toString(),
        participantOneAvatar: json['participantOneAvatar']?.toString(),
        participantTwoAvatar: json['participantTwoAvatar']?.toString(),
        propertyTitle: json['propertyTitle']?.toString(),
        lastMessage: json['lastMessage']?.toString(),
        lastMessageType: json['lastMessageType']?.toString(),
        lastAt: json['lastMessageAt'] != null
            ? DateTime.tryParse(json['lastMessageAt'].toString())
            : null,
        unread: json['unreadCount'] ?? json['unread'] ?? 0,
      );
}
