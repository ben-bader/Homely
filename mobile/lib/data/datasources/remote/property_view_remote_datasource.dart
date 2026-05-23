import 'package:homely/core/network/api_client.dart';
import 'package:homely/core/network/endpoints.dart';

abstract class PropertyViewRemoteDatasource {
  Future<Map<String, dynamic>> trackView(String propertyId);
  Future<int> getViewCount(String propertyId);
  Future<List<Map<String, dynamic>>> getViewsByProperty(String propertyId);
  Future<List<Map<String, dynamic>>> getViewsByUser(String userId);
}

class PropertyViewRemoteDatasourceImpl implements PropertyViewRemoteDatasource {
  @override
  Future<Map<String, dynamic>> trackView(String propertyId) async {
    final response = await ApiClient.post(
      Endpoints.trackPropertyView(propertyId),
      body: {},
    );
    return response;
  }

  @override
  Future<int> getViewCount(String propertyId) async {
    final response = await ApiClient.get(
      Endpoints.propertyViewStats(propertyId),
    );
    return int.tryParse(response['count'].toString()) ?? 0;
  }

  @override
  Future<List<Map<String, dynamic>>> getViewsByProperty(
    String propertyId,
  ) async {
    final response = await ApiClient.get(
      Endpoints.propertyViewsByProperty(propertyId),
    );
    return List<Map<String, dynamic>>.from(response ?? []);
  }

  @override
  Future<List<Map<String, dynamic>>> getViewsByUser(String userId) async {
    final response = await ApiClient.get(
      Endpoints.propertyViewsByUser(userId),
    );
    return List<Map<String, dynamic>>.from(response ?? []);
  }
}
