class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName; // ⭐ ADD
  final String body;
  final DateTime sentAt;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.body,
    required this.sentAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'].toString(),
      conversationId: json['conversationId'].toString(),
      senderId: json['senderId'].toString(),
      senderName: json['senderName'] ?? "",
      body: json['body'] ?? "",
      sentAt: DateTime.tryParse(json['sentAt'] ?? "") ??
          DateTime.now(),
    );
  }
}