class ChatMessage {
  final String id;
  final String senderId;
  final String content;
  final DateTime sentAt;
  final bool isMe;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.sentAt,
    required this.isMe,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, String myId) =>
      ChatMessage(
        id: json['id'].toString(),
        senderId: json['senderId'].toString(),
        content: json['content'] ?? '',
        sentAt: DateTime.tryParse(json['sentAt'] ?? '') ?? DateTime.now(),
        isMe: json['senderId'].toString() == myId,
      );
}
