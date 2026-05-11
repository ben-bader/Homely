import '../../../domain/entities/feedback/feedback_entity.dart';

class FeedbackModel extends FeedbackEntity {
  const FeedbackModel({
    required super.id,
    required super.userId,
    required super.propertyId,
    required super.rating,
    super.comment,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) =>
      FeedbackModel(
        id: json['id']?.toString() ?? '',
        userId: json['userId']?.toString() ?? '',
        propertyId: json['propertyId']?.toString() ?? '',
        rating: (json['rating'] as num?)?.toInt() ?? 0,
        comment: json['comment']?.toString(),
      );
}
