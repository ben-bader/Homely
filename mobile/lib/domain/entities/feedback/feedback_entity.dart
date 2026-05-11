class FeedbackEntity {
  final String id;
  final String userId;
  final String propertyId;
  final int rating;
  final String? comment;

  const FeedbackEntity({
    required this.id,
    required this.userId,
    required this.propertyId,
    required this.rating,
    this.comment,
  });
}
