import '../../domain/entities/feedback/feedback_entity.dart';
import '../../domain/repositories/i_feedback_repository.dart';
import '../datasources/remote/feedback_remote_datasource.dart';
import '../models/feedback/feedback_model.dart';

class FeedbackRepositoryImpl implements IFeedbackRepository {
  final FeedbackRemoteDatasource _remote;

  FeedbackRepositoryImpl(this._remote);

  @override
  Future<FeedbackEntity> create({
    required String propertyId,
    required int rating,
    String? comment,
  }) async {
    final data = await _remote.create(
        propertyId: propertyId, rating: rating, comment: comment);
    return FeedbackModel.fromJson(data);
  }

  @override
  Future<List<FeedbackEntity>> getByProperty(
      String propertyId) async {
    final data = await _remote.getByProperty(propertyId);
    return data
        .map((e) =>
            FeedbackModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<FeedbackEntity>> getByUser(String userId) async {
    final data = await _remote.getByUser(userId);
    return data
        .map((e) =>
            FeedbackModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> delete(String id) => _remote.delete(id);
}
