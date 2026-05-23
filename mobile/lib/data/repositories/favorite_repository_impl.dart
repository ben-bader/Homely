import '../../domain/entities/favorite/favorite_entity.dart';
import '../../domain/repositories/i_favorite_repository.dart';
import '../datasources/remote/favorite_remote_datasource.dart';
import '../models/favorite/favorite_model.dart';

class FavoriteRepositoryImpl implements IFavoriteRepository {
  final FavoriteRemoteDatasource _remote;

  FavoriteRepositoryImpl(this._remote);

  @override
  Future<List<FavoriteEntity>> getUserFavorites() async {
    final data = await _remote.getUserFavorites();
    return data
        .map((e) =>
            FavoriteModel.fromJson(e))
        .toList();
  }

  @override
  Future<FavoriteEntity> addFavorite(FavoriteEntity favorite) async {
    final model = favorite as FavoriteModel;
    final data = await _remote.addFavorite(model.toJson());
    return FavoriteModel.fromJson(data);
  }

  @override
  Future<void> removeFavorite(String propertyId,
      {String? mediaId}) =>
      _remote.removeFavorite(propertyId, mediaId: mediaId);
}
