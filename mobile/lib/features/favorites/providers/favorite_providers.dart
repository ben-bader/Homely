import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/favorites/models/favorite.dart';
import 'package:mobile/features/favorites/repositories/favorite_repository.dart';

final favoritesProvider =
    AsyncNotifierProvider<FavoritesNotifier, List<Favorite>>(
      FavoritesNotifier.new,
    );

final isPropertyFavoritedProvider = FutureProvider.family<bool, String>((ref, propertyId) async {
  final favorites = await ref.watch(favoritesProvider.future);
  return favorites.any((f) => f.propertyId == propertyId);
});

class FavoritesNotifier extends AsyncNotifier<List<Favorite>> {
  @override
  Future<List<Favorite>> build() async {
    return _fetchFavorites();
  }

  Future<List<Favorite>> _fetchFavorites() async {
    final repo = ref.read(favoriteRepositoryProvider);
    return repo.getUserFavorites();
  }

  Future<void> addFavorite(String propertyId, {String? mediaId}) async {
    final repo = ref.read(favoriteRepositoryProvider);
    final favorite = Favorite(
      id: '', // Will be set by backend
      userId: '', // Will be set by backend
      propertyId: propertyId,
      mediaId: mediaId,
    );
    await repo.addFavorite(favorite);
    // Refresh the list
    state = AsyncValue.data(await _fetchFavorites());
  }

  Future<void> removeFavorite(String propertyId, {String? mediaId}) async {
    final repo = ref.read(favoriteRepositoryProvider);
    await repo.removeFavorite(propertyId, mediaId: mediaId);
    // Refresh the list
    state = AsyncValue.data(await _fetchFavorites());
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _fetchFavorites());
  }
}