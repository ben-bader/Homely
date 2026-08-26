import 'package:homely/core/network/api_client.dart';

abstract class PropertyRemoteDatasource {
  Future<List<Map<String, dynamic>>> getProperties({
    int page = 1,
    int limit = 20,
  });
  Future<Map<String, dynamic>> getPropertyDetails(String propertyId);
  Future<Map<String, dynamic>> createProperty(Map<String, dynamic> data);
  Future<Map<String, dynamic>> updateProperty(
    String propertyId,
    Map<String, dynamic> data,
  );
  Future<Map<String, dynamic>> deleteProperty(String propertyId);
  Future<List<Map<String, dynamic>>> searchProperties(String query);
  Future<List<Map<String, dynamic>>> search(String query);
  Future<List<Map<String, dynamic>>> getAll();
  Future<Map<String, dynamic>> getById(String id);
  Future<List<Map<String, dynamic>>> filter(Map<String, String> params);
  Future<List<Map<String, dynamic>>> getMyListedProperties();
  Future<List<Map<String, dynamic>>> getPropertiesByUserId(String userId);
  Future<Map<String, dynamic>> create(Map<String, dynamic> data);
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> data);
  Future<Map<String, dynamic>> updateStatus(String id, String status);
  Future<void> delete(String id);
  Future<List<Map<String, dynamic>>> getPropertyMedia(String propertyId);
}

class PropertyRemoteDatasourceImpl implements PropertyRemoteDatasource {
  @override
  Future<List<Map<String, dynamic>>> getProperties({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await ApiClient.get('/properties?page=$page&limit=$limit');
    return List<Map<String, dynamic>>.from(response ?? []);
  }

  @override
  Future<Map<String, dynamic>> getPropertyDetails(String propertyId) async {
    final response = await ApiClient.get('/properties/$propertyId');
    return response;
  }

  @override
  Future<Map<String, dynamic>> createProperty(Map<String, dynamic> data) async {
    final response = await ApiClient.post('/properties', body: data);
    return response;
  }

  @override
  Future<Map<String, dynamic>> updateProperty(
    String propertyId,
    Map<String, dynamic> data,
  ) async {
    final response = await ApiClient.put('/properties/$propertyId', body: data);
    return response;
  }

  @override
  Future<Map<String, dynamic>> deleteProperty(String propertyId) async {
    final response = await ApiClient.delete('/properties/$propertyId');
    return response;
  }

  @override
  Future<List<Map<String, dynamic>>> searchProperties(String query) async {
    final response = await ApiClient.get('/properties/search?q=$query');
    return List<Map<String, dynamic>>.from(response ?? []);
  }

  @override
  Future<List<Map<String, dynamic>>> search(String query) async {
    return await searchProperties(query);
  }

  @override
  Future<List<Map<String, dynamic>>> getAll() async {
    return await getProperties();
  }

  @override
  Future<Map<String, dynamic>> getById(String id) async {
    return await getPropertyDetails(id);
  }

  @override
  Future<List<Map<String, dynamic>>> filter(Map<String, String> params) async {
    final queryParams = params.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    final response = await ApiClient.get('/properties/filter?$queryParams');
    return List<Map<String, dynamic>>.from(response ?? []);
  }

  @override
  Future<List<Map<String, dynamic>>> getMyListedProperties() async {
    final response = await ApiClient.get('/properties/my-listed');
    return List<Map<String, dynamic>>.from(response ?? []);
  }

  @override
  Future<List<Map<String, dynamic>>> getPropertiesByUserId(String userId) async {
    final response = await ApiClient.get('/properties/seller/$userId');
    final raw = response is List
        ? response
        : (response['content'] ?? response['data'] ?? response ?? []);
    return List<Map<String, dynamic>>.from(raw);
  }

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    return await createProperty(data);
  }

  @override
  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await updateProperty(id, data);
  }

  @override
  Future<Map<String, dynamic>> updateStatus(String id, String status) async {
    final response = await ApiClient.put(
      '/properties/$id/status',
      body: {'status': status},
    );
    return response;
  }

  @override
  Future<void> delete(String id) async {
    await deleteProperty(id);
  }

  @override
  Future<List<Map<String, dynamic>>> getPropertyMedia(String propertyId) async {
    final response = await ApiClient.get('/media/property/$propertyId');
    return List<Map<String, dynamic>>.from(response ?? []);
  }
}
