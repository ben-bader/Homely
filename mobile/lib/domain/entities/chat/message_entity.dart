class MessageEntity {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String body;
  final DateTime sentAt;
  final String? messageType;
  final String? propertyId;
  final String? propertyTitle;
  final String? propertyImageUrl;
  final String? propertyPrice;
  final String? propertyLocation;

  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.body,
    required this.sentAt,
    this.messageType,
    this.propertyId,
    this.propertyTitle,
    this.propertyImageUrl,
    this.propertyPrice,
    this.propertyLocation,
  });

  bool get isPropertyShare => messageType == 'PROPERTY_SHARE' && propertyId != null;
}
