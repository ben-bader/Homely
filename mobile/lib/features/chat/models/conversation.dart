class Conversation {
  final String id;
  final String propertyId;
  final String clientId;
  final String sellerId;
  final String? sellerName;
  final String? clientName; // ← ADDED
  final String? sellerAvatar;
  final String? clientAvatar; // ← ADDED
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
    this.clientName, // ← ADDED
    this.sellerAvatar,
    this.clientAvatar, // ← ADDED
    this.propertyTitle,
    this.lastMessage,
    this.lastAt,
    this.unread = 0,
  });

  /// Returns the display name of the OTHER person in the conversation.
  /// Pass the current user's ID — it will return the opposite party's name.
  String otherPersonName(String currentUserId) {
    if (currentUserId == sellerId) {
      // I am the seller → the other person is the client
      return clientName ?? 'Client';
    } else {
      // I am the client → the other person is the seller
      return sellerName ?? 'Seller';
    }
  }

  /// Returns the initials of the other person for the avatar.
  String otherPersonInitials(String currentUserId) {
    final name = otherPersonName(currentUserId);
    return name
        .split(" ")
        .where((e) => e.isNotEmpty)
        .take(2)
        .map((e) => e[0].toUpperCase())
        .join();
  }

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
    id: json['id']?.toString() ?? '',
    propertyId: json['propertyId']?.toString() ?? '',
    clientId: json['clientId']?.toString() ?? '',
    sellerId: json['sellerId']?.toString() ?? '',
    sellerName: json['sellerName']?.toString(),
    clientName: json['clientName']?.toString(), // ← ADDED
    sellerAvatar: json['sellerAvatar']?.toString(),
    clientAvatar: json['clientAvatar']?.toString(), // ← ADDED
    propertyTitle: json['propertyTitle']?.toString(),
    lastMessage: json['lastMessage']?.toString(),
    lastAt: json['lastMessageAt'] != null
        ? DateTime.tryParse(json['lastMessageAt'].toString())
        : null,
    unread: json['unreadCount'] ?? json['unread'] ?? 0,
  );
}
