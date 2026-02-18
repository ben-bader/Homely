class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String body;
  final Map<String, dynamic>? attachments;
  final DateTime? readAt;
  final DateTime sentAt; // Timestamp when message was sent
  final bool isMe;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.body,
    this.attachments,
    this.readAt,
    required this.sentAt,
    required this.isMe,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, String myId) {
    final senderIdStr = json['senderId']?.toString() ?? '';
    
    // Get createdAt from JSON, fallback to now
    DateTime sentAt = DateTime.now();
    if (json['createdAt'] != null) {
      sentAt = DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now();
    }
    
    return ChatMessage(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversationId']?.toString() ?? '',
      senderId: senderIdStr,
      body: json['body'] ?? '',
      attachments: json['attachments'] as Map<String, dynamic>?,
      readAt: json['readAt'] != null 
          ? DateTime.tryParse(json['readAt'].toString())
          : null,
      sentAt: sentAt,
      isMe: senderIdStr == myId,
    );
  }

  Map<String, dynamic> toJson() => {
    'conversationId': conversationId,
    'body': body,
    if (attachments != null) 'attachments': attachments,
  };
}
