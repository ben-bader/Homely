import 'package:homely/core/network/api_client.dart';
import 'package:homely/core/network/endpoints.dart';

abstract class FeedbackRemoteDatasource {
  Future<List<Map<String, dynamic>>> getPropertyFeedback(String propertyId);
  Future<Map<String, dynamic>> submitFeedback(
    String propertyId,
    Map<String, dynamic> feedback,
  );
  Future<Map<String, dynamic>> getPropertyAverageRating(String propertyId);
  Future<int> getPropertyReviewCount(String propertyId);
  Future<Map<String, dynamic>> create({
    required String propertyId,
    required int rating,
    String? comment,
  });
  Future<List<Map<String, dynamic>>> getByProperty(String propertyId);
  Future<List<Map<String, dynamic>>> getByUser(String userId);
  Future<void> delete(String id);
}

class FeedbackRemoteDatasourceImpl implements FeedbackRemoteDatasource {
  @override
  Future<List<Map<String, dynamic>>> getPropertyFeedback(
    String propertyId,
  ) async {
    try {
      final response = await ApiClient.get('/feedbacks/property/$propertyId');
      return List<Map<String, dynamic>>.from(response ?? []);
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  @override
  Future<Map<String, dynamic>> submitFeedback(
    String propertyId,
    Map<String, dynamic> feedback,
  ) async {
    try {
      final response = await ApiClient.post(
        Endpoints.submitFeedback,
        body: {'propertyId': propertyId, ...feedback},
      );
      return response as Map<String, dynamic>? ?? <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  @override
  Future<Map<String, dynamic>> getPropertyAverageRating(
    String propertyId,
  ) async {
    try {
      final response = await ApiClient.get('/feedbacks/property/$propertyId/rating');
      return response as Map<String, dynamic>? ?? <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  @override
  Future<int> getPropertyReviewCount(String propertyId) async {
    try {
      final response = await ApiClient.get('/feedbacks/property/$propertyId/count');
      return int.tryParse(response['count'].toString()) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<Map<String, dynamic>> create({
    required String propertyId,
    required int rating,
    String? comment,
  }) async {
    final feedback = <String, dynamic>{'rating': rating};
    if (comment != null) {
      feedback['comment'] = comment;
    }
    try {
      return await submitFeedback(propertyId, feedback);
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getByProperty(String propertyId) async {
    return await getPropertyFeedback(propertyId);
  }

  @override
  Future<List<Map<String, dynamic>>> getByUser(String userId) async {
    try {
      final response = await ApiClient.get('/feedbacks/user/$userId');
      return List<Map<String, dynamic>>.from(response ?? []);
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await ApiClient.delete('/feedbacks/$id');
    } catch (_) {
      // ignore
    }
  }
}
