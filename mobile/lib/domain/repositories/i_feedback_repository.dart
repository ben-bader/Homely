import '../entities/feedback/feedback_entity.dart';

abstract class IFeedbackRepository {
  Future<FeedbackEntity> create({
    required String propertyId,
    required int rating,
    String? comment,
  });
  Future<List<FeedbackEntity>> getByProperty(String propertyId);
  Future<List<FeedbackEntity>> getByUser(String userId);
  Future<void> delete(String id);
}
