class ConversationEntity {
  final String id;
  final String propertyId;
  final String clientId;
  final String sellerId;
  final String? sellerName;
  final String? clientName;
  final String? sellerAvatar;
  final String? clientAvatar;
  final String? propertyTitle;
  final String? lastMessage;
  final DateTime? lastAt;
  final int unread;

  const ConversationEntity({
    required this.id,
    required this.propertyId,
    required this.clientId,
    required this.sellerId,
    this.sellerName,
    this.clientName,
    this.sellerAvatar,
    this.clientAvatar,
    this.propertyTitle,
    this.lastMessage,
    this.lastAt,
    this.unread = 0,
  });

  String otherPersonName(String currentUserId) {
    if (currentUserId == sellerId) return clientName ?? 'Client';
    return sellerName ?? 'Seller';
  }

  String otherPersonInitials(String currentUserId) {
    final name = otherPersonName(currentUserId);
    return name
        .split(' ')
        .where((e) => e.isNotEmpty)
        .take(2)
        .map((e) => e[0].toUpperCase())
        .join();
  }
}
