class Conversation {
  final String id;
  final String propertyId;
  final String clientId;
  final String sellerId;
  // Optional display fields (may need to fetch separately)
  final String? sellerName;
  final String? sellerAvatar;
  final String? propertyTitle;
  final String? lastMessage;
  final DateTime? lastAt;
  final int unread;

  const Conversation({
    required this.id,
    required this.propertyId,
    required this.clientId,
    required this.sellerId,
    this.sellerName,
    this.sellerAvatar,
    this.propertyTitle,
    this.lastMessage,
    this.lastAt,
    this.unread = 0,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
    id: json['id']?.toString() ?? '',
    propertyId: json['propertyId']?.toString() ?? '',
    clientId: json['clientId']?.toString() ?? '',
    sellerId: json['sellerId']?.toString() ?? '',
    sellerName: json['sellerName']?.toString(),
    sellerAvatar: json['sellerAvatar']?.toString(),
    propertyTitle: json['propertyTitle']?.toString(),
    lastMessage: json['lastMessage']?.toString(),
    lastAt: json['lastMessageAt'] != null 
        ? DateTime.tryParse(json['lastMessageAt'].toString())
        : null,
    unread: json['unreadCount'] ?? json['unread'] ?? 0,
  );
}
