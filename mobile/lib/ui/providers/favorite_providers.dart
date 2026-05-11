import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/favorite_remote_datasource.dart';
import '../../data/models/favorite/favorite_model.dart';
import '../../data/repositories/favorite_repository_impl.dart';
import '../../domain/entities/favorite/favorite_entity.dart';
import '../../domain/repositories/i_favorite_repository.dart';

final favoriteRemoteDatasourceProvider =
    Provider<FavoriteRemoteDatasource>(
  (ref) => FavoriteRemoteDatasourceImpl(),
);

final favoriteRepositoryProvider = Provider<IFavoriteRepository>((ref) {
  return FavoriteRepositoryImpl(
      ref.read(favoriteRemoteDatasourceProvider));
});

final favoritesProvider =
    AsyncNotifierProvider<FavoritesNotifier, List<FavoriteEntity>>(
  FavoritesNotifier.new,
);

final isPropertyFavoritedProvider =
    FutureProvider.family<bool, String>((ref, propertyId) async {
  final favorites = await ref.watch(favoritesProvider.future);
  return favorites.any((f) => f.propertyId == propertyId);
});

class FavoritesNotifier
    extends AsyncNotifier<List<FavoriteEntity>> {
  @override
  Future<List<FavoriteEntity>> build() async =>
      _fetchFavorites();

  Future<List<FavoriteEntity>> _fetchFavorites() =>
      ref.read(favoriteRepositoryProvider).getUserFavorites();

  Future<void> addFavorite(String propertyId,
      {String? mediaId}) async {
    final favorite = FavoriteModel(
      id: '',
      userId: '',
      propertyId: propertyId,
      mediaId: mediaId,
    );
    await ref
        .read(favoriteRepositoryProvider)
        .addFavorite(favorite);
    state = AsyncValue.data(await _fetchFavorites());
  }

  Future<void> removeFavorite(String propertyId,
      {String? mediaId}) async {
    await ref
        .read(favoriteRepositoryProvider)
        .removeFavorite(propertyId, mediaId: mediaId);
    state = AsyncValue.data(await _fetchFavorites());
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _fetchFavorites());
  }
}
