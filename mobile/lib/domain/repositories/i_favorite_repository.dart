import '../entities/favorite/favorite_entity.dart';

abstract class IFavoriteRepository {
  Future<List<FavoriteEntity>> getUserFavorites();
  Future<FavoriteEntity> addFavorite(FavoriteEntity favorite);
  Future<void> removeFavorite(String propertyId, {String? mediaId});
}
