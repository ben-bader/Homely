import 'package:homely/core/network/api_client.dart';

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
      '/properties/$propertyId/views',
      body: {},
    );
    return response;
  }

  @override
  Future<int> getViewCount(String propertyId) async {
    final response = await ApiClient.get('/properties/$propertyId/views');
    return int.tryParse(response['count'].toString()) ?? 0;
  }

  @override
  Future<List<Map<String, dynamic>>> getViewsByProperty(
    String propertyId,
  ) async {
    final response = await ApiClient.get('/properties/$propertyId/views/list');
    return List<Map<String, dynamic>>.from(response ?? []);
  }

  @override
  Future<List<Map<String, dynamic>>> getViewsByUser(String userId) async {
    final response = await ApiClient.get('/users/$userId/views');
    return List<Map<String, dynamic>>.from(response ?? []);
  }
}
