class ConversationEntity {
  final String id;
  final String propertyId;
  final String participantOneId;
  final String participantTwoId;
  final String? participantOneName;
  final String? participantTwoName;
  final String? participantOneAvatar;
  final String? participantTwoAvatar;
  final String? propertyTitle;
  final String? lastMessage;
  final String? lastMessageType;
  final DateTime? lastAt;
  final int unread;

  const ConversationEntity({
    required this.id,
    required this.propertyId,
    required this.participantOneId,
    required this.participantTwoId,
    this.participantOneName,
    this.participantTwoName,
    this.participantOneAvatar,
    this.participantTwoAvatar,
    this.propertyTitle,
    this.lastMessage,
    this.lastMessageType,
    this.lastAt,
    this.unread = 0,
  });

  String otherPersonName(String currentUserId) {
    if (currentUserId == participantOneId) return participantTwoName ?? 'User';
    return participantOneName ?? 'User';
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

  String get lastMessagePreview {
    if (lastMessageType == 'PROPERTY_SHARE') {
      return 'Shared a property';
    }
    return lastMessage ?? '';
  }
}
