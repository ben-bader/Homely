import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/features/visit_requests/models/visit_request.dart';

final visitRequestRepositoryProvider = Provider<VisitRequestRepository>(
  (ref) => VisitRequestRepository(),
);

class VisitRequestRepository {
  Future<VisitRequest> create({
    required String propertyId,
    required DateTime requestedDate,
  }) async {
    final data =
        await ApiClient.post(
              '/visit-requests',
              body: {
                'propertyId': propertyId,
                'requestedDate': requestedDate.toIso8601String().replaceAll(
                  'Z',
                  '',
                ),
              },
            )
            as Map<String, dynamic>;
    return VisitRequest.fromJson(data);
  }

  Future<List<VisitRequest>> getMyRequests() async {
    final data =
        await ApiClient.get('/visit-requests/my-requests') as List<dynamic>;
    return data
        .map((e) => VisitRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<VisitRequest>> getRequestsForProperty(String propertyId) async {
    final data =
        await ApiClient.get('/visit-requests/property/$propertyId/seller')
            as List<dynamic>;
    return data
        .map((e) => VisitRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<VisitRequest> updateStatus({
    required String id,
    required VisitStatus status,
  }) async {
    final data =
        await ApiClient.put(
              '/visit-requests/$id/status',
              queryParams: {'status': status.toJson()},
            )
            as Map<String, dynamic>;
    return VisitRequest.fromJson(data);
  }

  Future<void> delete(String id) async {
    await ApiClient.delete('/visit-requests/$id');
  }
}
