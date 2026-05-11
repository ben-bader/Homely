import 'package:homely/core/network/api_client.dart';

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
    final response = await ApiClient.get('/feedback/property/$propertyId');
    return List<Map<String, dynamic>>.from(response ?? []);
  }

  @override
  Future<Map<String, dynamic>> submitFeedback(
    String propertyId,
    Map<String, dynamic> feedback,
  ) async {
    final response = await ApiClient.post(
      '/feedback',
      body: {'propertyId': propertyId, ...feedback},
    );
    return response;
  }

  @override
  Future<Map<String, dynamic>> getPropertyAverageRating(
    String propertyId,
  ) async {
    final response = await ApiClient.get(
      '/feedback/property/$propertyId/rating',
    );
    return response;
  }

  @override
  Future<int> getPropertyReviewCount(String propertyId) async {
    final response = await ApiClient.get(
      '/feedback/property/$propertyId/count',
    );
    return int.tryParse(response['count'].toString()) ?? 0;
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
    return await submitFeedback(propertyId, feedback);
  }

  @override
  Future<List<Map<String, dynamic>>> getByProperty(String propertyId) async {
    return await getPropertyFeedback(propertyId);
  }

  @override
  Future<List<Map<String, dynamic>>> getByUser(String userId) async {
    final response = await ApiClient.get('/feedback/user/$userId');
    return List<Map<String, dynamic>>.from(response ?? []);
  }

  @override
  Future<void> delete(String id) async {
    await ApiClient.delete('/feedback/$id');
  }
}
