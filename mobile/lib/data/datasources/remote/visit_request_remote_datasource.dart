import 'package:homely/core/network/api_client.dart';
import 'package:homely/core/network/endpoints.dart';

abstract class VisitRequestRemoteDatasource {
  Future<Map<String, dynamic>> create({
    required String propertyId,
    required DateTime requestedDate,
  });
  Future<List<Map<String, dynamic>>> getMyRequests();
  Future<List<Map<String, dynamic>>> getRequestsForProperty(String propertyId);
  Future<Map<String, dynamic>> updateStatus({
    required String id,
    required String status,
  });
  Future<void> delete(String id);
}

class VisitRequestRemoteDatasourceImpl implements VisitRequestRemoteDatasource {
  @override
  Future<Map<String, dynamic>> create({
    required String propertyId,
    required DateTime requestedDate,
  }) async {
    final response = await ApiClient.post(
      Endpoints.requestVisit,
      body: {
        'propertyId': propertyId,
        'requestedDate': requestedDate.toIso8601String(),
      },
    );
    return response;
  }

  @override
  Future<List<Map<String, dynamic>>> getMyRequests() async {
    final response = await ApiClient.get(Endpoints.myVisitRequests);
    return List<Map<String, dynamic>>.from(response ?? []);
  }

  @override
  Future<List<Map<String, dynamic>>> getRequestsForProperty(
    String propertyId,
  ) async {
    final endpoint = '/visits/property/$propertyId/seller';
    final response = await ApiClient.get(endpoint);
    return List<Map<String, dynamic>>.from(response ?? []);
  }

  @override
  Future<Map<String, dynamic>> updateStatus({
    required String id,
    required String status,
  }) async {
    final response = await ApiClient.put(
      Endpoints.updateVisitStatus(id),
      body: {'status': status},
    );
    return response;
  }

  @override
  Future<void> delete(String id) async {
    await ApiClient.delete(Endpoints.deleteVisitRequest(id));
  }
}
