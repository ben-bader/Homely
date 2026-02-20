import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/property.dart';
import '../repositories/property_repository.dart';

final propertyRepositoryProvider = Provider<PropertyRepository>(
  (_) => PropertyRepository(),
);

class PropertyFilter {
  final String type; 
  final String status; 
  final String search;

  const PropertyFilter({
    this.type = 'Any type',
    this.status = 'All',
    this.search = '',
  });

  PropertyFilter copyWith({String? type, String? status, String? search}) =>
      PropertyFilter(
        type: type ?? this.type,
        status: status ?? this.status,
        search: search ?? this.search,
      );
}

final propertyFilterProvider = StateProvider<PropertyFilter>(
  (_) => const PropertyFilter(),
);

final propertiesProvider = FutureProvider.autoDispose<List<Property>>((ref) {
  final filter = ref.watch(propertyFilterProvider);
  final repo = ref.watch(propertyRepositoryProvider);
  return repo.fetchProperties(
    type: filter.type,
    status: filter.status,
    search: filter.search.isEmpty ? null : filter.search,
  );
});

final propertyDetailProvider = FutureProvider.autoDispose
    .family<Property, String>((ref, id) {
      return ref.watch(propertyRepositoryProvider).fetchProperty(id);
    });



class FavoritesNotifier extends AsyncNotifier<List<Property>> {
  @override
  Future<List<Property>> build() =>
      ref.read(propertyRepositoryProvider).fetchFavorites();

  Future<void> toggle(Property property) async {
    final repo = ref.read(propertyRepositoryProvider);
    final current = state.valueOrNull ?? [];
    final isAlreadyFav = current.any((p) => p.id == property.id);
    final addFav = !isAlreadyFav;

    state = AsyncData(
      addFav
          ? [...current, property..isFavorite = true]
          : current.where((p) => p.id != property.id).toList(),
    );

    try {
      await repo.toggleFavorite(property.id, add: addFav);
    } catch (_) {
      state = AsyncData(current); 
    }
  }
}
