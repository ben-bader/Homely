import 'package:mobile/core/network/api_client.dart';
import '../models/property.dart';

class PropertyRepository {
  Future<List<Property>> fetchProperties({
    String? type,
    String? status,
    String? search,
    int page = 0,
    int size = 20,
  }) async {
    final params = <String, String>{
      if (type != null && type != 'Any type') 'type': type.toLowerCase(),
      if (status != null && status != 'All') 'status': status.toLowerCase(),
      if (search != null && search.isNotEmpty) 'search': search,
      'page': '$page',
      'size': '$size',
    };
    final data = await ApiClient.get('/properties', queryParams: params);
    final list = data is List ? data : (data['content'] ?? data['data'] ?? []);
    return (list as List).map((e) => Property.fromJson(e)).toList();
  }

  Future<Property> fetchProperty(String id) async {
    final data = await ApiClient.get('/properties/$id');
    return Property.fromJson(data);
  }

  
  Future<void> toggleFavorite(String propertyId, {required bool add}) async {
    if (add) {
      await ApiClient.post('/favorites/$propertyId');
    } else {
      await ApiClient.delete('/favorites/$propertyId');
    }
  }

  Future<List<Property>> fetchFavorites() async {
    final data = await ApiClient.get('/favorites');
    final list = data is List ? data : (data['content'] ?? data['data'] ?? []);
    return (list as List).map((e) => Property.fromJson(e)).toList();
  }
}
