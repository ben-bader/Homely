class Feedback {
  final String id;
  final String propertyId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Feedback({
    required this.id,
    required this.propertyId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      id: json['id'] ?? '',
      propertyId: json['propertyId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      comment: json['comment'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
