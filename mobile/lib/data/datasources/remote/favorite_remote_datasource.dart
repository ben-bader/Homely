import 'package:homely/core/network/api_client.dart';

abstract class FavoriteRemoteDatasource {
  Future<Map<String, dynamic>> addFavorite(Map<String, dynamic> favoriteData);
  Future<void> removeFavorite(String propertyId, {String? mediaId});
  Future<List<Map<String, dynamic>>> getFavorites();
  Future<bool> isFavorited(String propertyId);
  Future<List<Map<String, dynamic>>> getUserFavorites();
}

class FavoriteRemoteDatasourceImpl implements FavoriteRemoteDatasource {
  @override
  Future<Map<String, dynamic>> addFavorite(
    Map<String, dynamic> favoriteData,
  ) async {
    final response = await ApiClient.post('/favorites', body: favoriteData);
    return response;
  }

  @override
  Future<void> removeFavorite(String propertyId, {String? mediaId}) async {
    if (mediaId != null) {
      await ApiClient.delete('/favorites/$propertyId/media/$mediaId');
    } else {
      await ApiClient.delete('/favorites/$propertyId');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getFavorites() async {
    final response = await ApiClient.get('/favorites');
    return List<Map<String, dynamic>>.from(response ?? []);
  }

  @override
  Future<bool> isFavorited(String propertyId) async {
    final response = await ApiClient.get('/favorites/$propertyId/check');
    return response['isFavorited'] ?? false;
  }

  @override
  Future<List<Map<String, dynamic>>> getUserFavorites() async {
    return await getFavorites();
  }
}
