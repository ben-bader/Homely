// lib/features/property/repositories/property_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/features/property/models/property.dart';

// ── Provider ──────────────────────────────────────────────────────────────────

final propertyRepositoryProvider =
    Provider<PropertyRepository>((ref) => PropertyRepository());

// ── Repository ────────────────────────────────────────────────────────────────

class PropertyRepository {
  static const _base = '/api/properties';

  // GET /api/properties
  Future<List<Property>> getAll() async {
    final data = await ApiClient.get(_base) as List<dynamic>;
    return data.map((e) => Property.fromJson(e as Map<String, dynamic>)).toList();
  }

  // GET /api/properties/{id}
  Future<Property> getById(String id) async {
    final data = await ApiClient.get('$_base/$id') as Map<String, dynamic>;
    return Property.fromJson(data);
  }

  // GET /api/properties/search?keyword=...
  Future<List<Property>> search(String keyword) async {
    final data = await ApiClient.get(
      '$_base/search',
      queryParams: {'keyword': keyword},
    ) as List<dynamic>;
    return data.map((e) => Property.fromJson(e as Map<String, dynamic>)).toList();
  }

  // GET /api/properties/filter?listingType=...&propertyType=...&city=...&minPrice=...&maxPrice=...
  Future<List<Property>> filter({
    String? listingType,
    String? propertyType,
    String? city,
    double? minPrice,
    double? maxPrice,
  }) async {
    final data = await ApiClient.get(
      '$_base/filter',
      queryParams: {
        if (listingType != null) 'listingType': listingType,
        if (propertyType != null) 'propertyType': propertyType,
        if (city != null) 'city': city,
        if (minPrice != null) 'minPrice': minPrice.toString(),
        if (maxPrice != null) 'maxPrice': maxPrice.toString(),
      },
    ) as List<dynamic>;
    return data.map((e) => Property.fromJson(e as Map<String, dynamic>)).toList();
  }
}