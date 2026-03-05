import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/features/property/models/property.dart';

final propertyRepositoryProvider = Provider<PropertyRepository>(
  (ref) => PropertyRepository(),
);

class PropertyRepository {
  Future<List<Property>> getAll() async {
    final data = await ApiClient.get('/properties') as List<dynamic>;
    return data
        .map((e) => Property.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Property> getById(String id) async {
    final data = await ApiClient.get('/properties/$id') as Map<String, dynamic>;
    return Property.fromJson(data);
  }

  Future<List<Property>> filter({
    ListingType? listingType,
    PropertyType? propertyType,
    double? minPrice,
    double? maxPrice,
    String? city,
  }) async {
    final params = <String, String>{};
    if (listingType != null) params['listingType'] = listingType.toJson();
    if (propertyType != null) params['propertyType'] = propertyType.toJson();
    if (minPrice != null) params['minPrice'] = minPrice.toString();
    if (maxPrice != null) params['maxPrice'] = maxPrice.toString();
    if (city != null && city.isNotEmpty) params['city'] = city;

    final data =
        await ApiClient.get('/properties/filter', queryParams: params)
            as List<dynamic>;
    return data
        .map((e) => Property.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Property>> search(String keyword) async {
    final data =
        await ApiClient.get(
              '/properties/search',
              queryParams: {'keyword': keyword},
            )
            as List<dynamic>;
    return data
        .map((e) => Property.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Property>> getMyListedProperties() async {
    final data = await ApiClient.get('/properties/my-listed') as List<dynamic>;
    return data
        .map((e) => Property.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Property> create(Map<String, dynamic> body) async {
    final data =
        await ApiClient.post('/properties', body: body) as Map<String, dynamic>;
    return Property.fromJson(data);
  }

  Future<Property> update(String id, Map<String, dynamic> body) async {
    final data =
        await ApiClient.put('/properties/$id', body: body)
            as Map<String, dynamic>;
    return Property.fromJson(data);
  }

  Future<Property> updateStatus(String id, PropertyStatus status) async {
    final data =
        await ApiClient.patch(
              '/properties/$id/status',
              queryParams: {'status': status.toJson()},
            )
            as Map<String, dynamic>;
    return Property.fromJson(data);
  }

  Future<void> delete(String id) async {
    await ApiClient.delete('/properties/$id');
  }
}
