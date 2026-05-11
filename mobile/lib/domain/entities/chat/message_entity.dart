class MessageEntity {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String body;
  final DateTime sentAt;

  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.body,
    required this.sentAt,
  });
}
