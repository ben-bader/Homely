class Feedback {
  final String id;
  final String userId;
  final String propertyId;
  final int rating;
  final String? comment;

  const Feedback({
    required this.id,
    required this.userId,
    required this.propertyId,
    required this.rating,
    this.comment,
  });

  factory Feedback.fromJson(Map<String, dynamic> json) => Feedback(
    id: json['id']?.toString() ?? '',
    userId: json['userId']?.toString() ?? '',
    propertyId: json['propertyId']?.toString() ?? '',
    rating: (json['rating'] as num?)?.toInt() ?? 0,
    comment: json['comment']?.toString(),
  );
}
