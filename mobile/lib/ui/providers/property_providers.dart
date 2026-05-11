import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/property_remote_datasource.dart';
import '../../data/repositories/property_repository_impl.dart';
import '../../domain/entities/property/property_entity.dart';
import '../../domain/repositories/i_property_repository.dart';

final propertyRemoteDatasourceProvider = Provider<PropertyRemoteDatasource>(
  (ref) => PropertyRemoteDatasourceImpl(),
);

final propertyRepositoryProvider = Provider<IPropertyRepository>((ref) {
  return PropertyRepositoryImpl(ref.read(propertyRemoteDatasourceProvider));
});

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
  }) => PropertyFilter(
    search: clearSearch ? null : (search ?? this.search),
    listingType: clearListingType ? null : (listingType ?? this.listingType),
    propertyType: clearPropertyType
        ? null
        : (propertyType ?? this.propertyType),
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
    AsyncNotifierProvider<PropertiesNotifier, List<PropertyEntity>>(
      PropertiesNotifier.new,
    );

class PropertiesNotifier extends AsyncNotifier<List<PropertyEntity>> {
  @override
  Future<List<PropertyEntity>> build() async {
    final filter = ref.watch(propertyFilterProvider);
    final repo = ref.read(propertyRepositoryProvider);

    if (filter.hasSearch) return repo.search(filter.search!);

    if (filter.isFiltering) {
      final params = <String, String>{};
      if (filter.listingType != null)
        params['listingType'] = filter.listingType!.toJson();
      if (filter.propertyType != null)
        params['propertyType'] = filter.propertyType!.toJson();
      if (filter.minPrice != null)
        params['minPrice'] = filter.minPrice.toString();
      if (filter.maxPrice != null)
        params['maxPrice'] = filter.maxPrice.toString();
      if (filter.city != null && filter.city!.isNotEmpty)
        params['city'] = filter.city!;
      if (filter.fromDate != null)
        params['fromDate'] = filter.fromDate!.toUtc().toIso8601String();
      if (filter.toDate != null)
        params['toDate'] = filter.toDate!.toUtc().toIso8601String();
      return repo.filter(params);
    }

    return repo.getAll();
  }

  Future<void> refresh() async => ref.invalidateSelf();
}

final propertyDetailProvider =
    AsyncNotifierProviderFamily<PropertyDetailNotifier, PropertyEntity, String>(
      PropertyDetailNotifier.new,
    );

class PropertyDetailNotifier
    extends FamilyAsyncNotifier<PropertyEntity, String> {
  @override
  Future<PropertyEntity> build(String arg) =>
      ref.read(propertyRepositoryProvider).getById(arg);
}

final sellerListingsProvider =
    AsyncNotifierProvider<SellerListingsNotifier, List<PropertyEntity>>(
      SellerListingsNotifier.new,
    );

class SellerListingsNotifier extends AsyncNotifier<List<PropertyEntity>> {
  @override
  Future<List<PropertyEntity>> build() =>
      ref.read(propertyRepositoryProvider).getMyListedProperties();

  void onCreated(PropertyEntity property) {
    state.whenData((list) => state = AsyncData([property, ...list]));
  }

  void onUpdated(PropertyEntity updated) {
    state.whenData(
      (list) => state = AsyncData([
        for (final p in list)
          if (p.id == updated.id) updated else p,
      ]),
    );
  }

  Future<void> onDeleted(String id) async {
    // FIX: Capture messenger before async gap in UI layer
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

final featuredCountProvider = FutureProvider<int>((ref) async {
  return 5;
});
