import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/property/models/property.dart';
import 'package:mobile/features/property/repositories/property_repository.dart';


class PropertyFilter {
  final String? search;
  final ListingType? listingType;
  final PropertyType? propertyType;
  final String? city;
  final double? minPrice;
  final double? maxPrice;
  final DateTime? fromDate;
  final DateTime? toDate;

  const PropertyFilter({
    this.search,
    this.listingType,
    this.propertyType,
    this.city,
    this.minPrice,
    this.maxPrice,
    this.fromDate,
    this.toDate,
  });

  bool get isFiltering =>
      listingType != null ||
      propertyType != null ||
      (city != null && city!.isNotEmpty) ||
      minPrice != null ||
      maxPrice != null ||
      fromDate != null ||
      toDate != null;

  bool get hasSearch => search != null && search!.isNotEmpty;

  int get activeFilterCount {
    int n = 0;
    if (listingType != null) n++;
    if (propertyType != null) n++;
    if (city != null && city!.isNotEmpty) n++;
    if (minPrice != null) n++;
    if (maxPrice != null) n++;
    if (fromDate != null) n++;
    if (toDate != null) n++;
    return n;
  }

  PropertyFilter copyWith({
    String? search,
    ListingType? listingType,
    PropertyType? propertyType,
    String? city,
    double? minPrice,
    double? maxPrice,
    DateTime? fromDate,
    DateTime? toDate,
    bool clearSearch = false,
    bool clearListingType = false,
    bool clearPropertyType = false,
    bool clearCity = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearFromDate = false,
    bool clearToDate = false,
  }) =>
      PropertyFilter(
        search: clearSearch ? null : (search ?? this.search),
        listingType:
            clearListingType ? null : (listingType ?? this.listingType),
        propertyType:
            clearPropertyType ? null : (propertyType ?? this.propertyType),
        city: clearCity ? null : (city ?? this.city),
        minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
        maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
        fromDate: clearFromDate ? null : (fromDate ?? this.fromDate),
        toDate: clearToDate ? null : (toDate ?? this.toDate),
      );

  PropertyFilter clearFilters() => PropertyFilter(search: search);
}

final propertyFilterProvider = StateProvider<PropertyFilter>(
  (ref) => const PropertyFilter(),
);


final propertiesProvider =
    AsyncNotifierProvider<PropertiesNotifier, List<Property>>(
      PropertiesNotifier.new,
    );

class PropertiesNotifier extends AsyncNotifier<List<Property>> {
  @override
  Future<List<Property>> build() async {
    final filter = ref.watch(propertyFilterProvider);
    final repo = ref.read(propertyRepositoryProvider);

    if (filter.hasSearch) return repo.search(filter.search!);

    if (filter.isFiltering) {
      return repo.filter(
        listingType: filter.listingType,
        propertyType: filter.propertyType,
        minPrice: filter.minPrice,
        maxPrice: filter.maxPrice,
        city: filter.city,
        fromDate: filter.fromDate,
        toDate: filter.toDate,
      );
    }

    return repo.getAll();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}


final propertyDetailProvider =
    AsyncNotifierProviderFamily<PropertyDetailNotifier, Property, String>(
      PropertyDetailNotifier.new,
    );

class PropertyDetailNotifier extends FamilyAsyncNotifier<Property, String> {
  @override
  Future<Property> build(String arg) =>
      ref.read(propertyRepositoryProvider).getById(arg);
}


final sellerListingsProvider =
    AsyncNotifierProvider<SellerListingsNotifier, List<Property>>(
      SellerListingsNotifier.new,
    );

class SellerListingsNotifier extends AsyncNotifier<List<Property>> {
  @override
  Future<List<Property>> build() =>
      ref.read(propertyRepositoryProvider).getMyListedProperties();

  void onCreated(Property property) {
    state.whenData((list) => state = AsyncData([property, ...list]));
  }

  void onUpdated(Property updated) {
    state.whenData(
      (list) => state = AsyncData([
        for (final p in list)
          if (p.id == updated.id) updated else p,
      ]),
    );
  }

  Future<void> onDeleted(String id) async {
    await ref.read(propertyRepositoryProvider).delete(id);
    state.whenData(
      (list) => state = AsyncData(list.where((p) => p.id != id).toList()),
    );
  }

  Future<void> changeStatus(String id, PropertyStatus status) async {
    final updated = await ref
        .read(propertyRepositoryProvider)
        .updateStatus(id, status);
    onUpdated(updated);
  }
}

final sellerPropertiesProvider = sellerListingsProvider;