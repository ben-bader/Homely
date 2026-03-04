import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/features/feedback/models/feedback.dart';

final feedbackRepositoryProvider = Provider<FeedbackRepository>(
  (ref) => FeedbackRepository(),
);

class FeedbackRepository {
  Future<Feedback> create({
    required String propertyId,
    required int rating,
    String? comment,
  }) async {
    final data =
        await ApiClient.post(
              '/feedbacks',
              body: {
                'propertyId': propertyId,
                'rating': rating,
                if (comment != null && comment.isNotEmpty) 'comment': comment,
              },
            )
            as Map<String, dynamic>;
    return Feedback.fromJson(data);
  }

  Future<List<Feedback>> getByProperty(String propertyId) async {
    final data =
        await ApiClient.get('/feedbacks/property/$propertyId') as List<dynamic>;
    return data
        .map((e) => Feedback.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Feedback>> getByUser(String userId) async {
    final data =
        await ApiClient.get('/feedbacks/user/$userId') as List<dynamic>;
    return data
        .map((e) => Feedback.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> delete(String id) async {
    await ApiClient.delete('/feedbacks/$id');
  }
}
