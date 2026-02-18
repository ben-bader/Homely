class Conversation {
  final String id;
  final String sellerId;
  final String sellerName;
  final String? sellerAvatar;
  final String propertyId;
  final String propertyTitle;
  final String lastMessage;
  final DateTime lastAt;
  final int unread;

  const Conversation({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    this.sellerAvatar,
    required this.propertyId,
    required this.propertyTitle,
    required this.lastMessage,
    required this.lastAt,
    this.unread = 0,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
    id: json['id'].toString(),
    sellerId: json['sellerId'].toString(),
    sellerName: json['sellerName'] ?? '',
    sellerAvatar: json['sellerAvatar'],
    propertyId: json['propertyId'].toString(),
    propertyTitle: json['propertyTitle'] ?? '',
    lastMessage: json['lastMessage'] ?? '',
    lastAt: DateTime.tryParse(json['lastAt'] ?? '') ?? DateTime.now(),
    unread: json['unread'] ?? 0,
  );
}
