// lib/features/property/providers/property_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/property/models/property.dart';
import 'package:mobile/features/property/repositories/property_repository.dart';

// ── Filter State ──────────────────────────────────────────────────────────────

class PropertyFilter {
  final String? type;         // propertyType: 'HOUSE', 'APARTMENT', etc.
  final String? status;       // listingType:  'RENT', 'BUY'
  final String? search;       // triggers /search endpoint
  final String? city;         // city name substring match
  final double? minPrice;
  final double? maxPrice;

  const PropertyFilter({
    this.type,
    this.status,
    this.search,
    this.city,
    this.minPrice,
    this.maxPrice,
  });

  PropertyFilter copyWith({
    String? type,
    String? status,
    String? search,
    String? city,
    double? minPrice,
    double? maxPrice,
    bool clearSearch = false,
    bool clearType = false,
    bool clearCity = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
  }) =>
      PropertyFilter(
        type: clearType ? null : (type ?? this.type),
        status: status ?? this.status,
        search: clearSearch ? null : (search ?? this.search),
        city: clearCity ? null : (city ?? this.city),
        minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
        maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      );

  /// Returns a fully reset filter, preserving only the search term.
  PropertyFilter resetFilters() => PropertyFilter(search: search);

  bool get isFiltering =>
      (type != null && type != 'Any type') ||
      (status != null && status != 'All') ||
      (city != null && city!.isNotEmpty) ||
      minPrice != null ||
      maxPrice != null;

  int get activeFilterCount {
    int count = 0;
    if (status != null && status != 'All') count++;
    if (type != null && type != 'Any type') count++;
    if (city != null && city!.isNotEmpty) count++;
    if (minPrice != null || maxPrice != null) count++;
    return count;
  }
}

final propertyFilterProvider =
    StateProvider<PropertyFilter>((ref) => const PropertyFilter());

// ── Properties Provider ───────────────────────────────────────────────────────

final propertiesProvider = FutureProvider.autoDispose<List<Property>>((ref) async {
  final filter = ref.watch(propertyFilterProvider);
  final repo = ref.watch(propertyRepositoryProvider);

  // 1. Search takes priority
  if (filter.search != null && filter.search!.trim().isNotEmpty) {
    return repo.search(filter.search!.trim());
  }

  // 2. Any active filter → use filter endpoint
  final typeParam = _toPropertyType(filter.type);
  final listingParam = _toListingType(filter.status);

  if (typeParam != null ||
      listingParam != null ||
      filter.city != null ||
      filter.minPrice != null ||
      filter.maxPrice != null) {
    return repo.filter(
      propertyType: typeParam,
      listingType: listingParam,
      city: filter.city,
      minPrice: filter.minPrice,
      maxPrice: filter.maxPrice,
    );
  }

  // 3. Default: load all
  return repo.getAll();
});

// ── Property Detail Provider ──────────────────────────────────────────────────

final propertyDetailProvider =
    FutureProvider.autoDispose.family<Property, String>((ref, id) async {
  final repo = ref.watch(propertyRepositoryProvider);
  return repo.getById(id);
});

// ── Helpers ───────────────────────────────────────────────────────────────────

String? _toPropertyType(String? label) {
  if (label == null || label == 'Any type') return null;
  if (label == 'Rent' || label == 'Buy') return null;
  return label.toUpperCase();
}

String? _toListingType(String? label) {
  if (label == null || label == 'All') return null;
  return label.toUpperCase();
}