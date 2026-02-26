// lib/features/property/repositories/property_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/endpoints.dart';
import 'package:mobile/features/property/models/property.dart';

// ── Provider ──────────────────────────────────────────────────────────────────

final propertyRepositoryProvider =
    Provider<PropertyRepository>((ref) => PropertyRepository());

// ── Repository ────────────────────────────────────────────────────────────────

class PropertyRepository {
  // GET /api/properties
  Future<List<Property>> getAll() async {
    final data = await ApiClient.get(Endpoints.properties) as List<dynamic>;
    return data.map((e) => Property.fromJson(e as Map<String, dynamic>)).toList();
  }

  // GET /api/properties/{id}
  Future<Property> getById(String id) async {
    final data = await ApiClient.get(Endpoints.propertyById(id)) as Map<String, dynamic>;
    return Property.fromJson(data);
  }

  // GET /api/properties/search?keyword=...
  Future<List<Property>> search(String keyword) async {
    final data = await ApiClient.get(
      Endpoints.searchProperties,
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
      Endpoints.filterProperties,
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

  // GET /api/properties/my-listed (seller's properties)
  Future<List<Property>> getSellerListings() async {
    final data = await ApiClient.get(Endpoints.sellerListings) as List<dynamic>;
    return data.map((e) => Property.fromJson(e as Map<String, dynamic>)).toList();
  }
}