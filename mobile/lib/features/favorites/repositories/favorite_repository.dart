import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/features/favorites/models/favorite.dart';

final favoriteRepositoryProvider = Provider<FavoriteRepository>(
  (ref) => FavoriteRepository(),
);

class FavoriteRepository {
  Future<List<Favorite>> getUserFavorites() async {
    final data = await ApiClient.get('/favorites') as List<dynamic>;
    return data
        .map((e) => Favorite.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Favorite> addFavorite(Favorite favorite) async {
    final data = await ApiClient.post('/favorites', body: favorite.toJson())
        as Map<String, dynamic>;
    return Favorite.fromJson(data);
  }

  Future<void> removeFavorite(String propertyId, {String? mediaId}) async {
    final queryParams = {'propertyId': propertyId};
    if (mediaId != null) {
      queryParams['mediaId'] = mediaId;
    }
    await ApiClient.delete('/favorites', queryParams: queryParams);
  }
}