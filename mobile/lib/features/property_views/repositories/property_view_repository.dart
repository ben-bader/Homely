import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/features/property_views/models/property_view.dart';

final propertyViewRepositoryProvider = Provider<PropertyViewRepository>(
  (ref) => PropertyViewRepository(),
);

class PropertyViewRepository {
  Future<PropertyView> trackView(String propertyId) async {
    final data =
        await ApiClient.post(
              '/property-views',
              body: {'propertyId': propertyId},
            )
            as Map<String, dynamic>;
    return PropertyView.fromJson(data);
  }

  Future<int> getViewCount(String propertyId) async {
    final data = await ApiClient.get(
      '/property-views/property/$propertyId/count',
    );
    return (data as num).toInt();
  }

  Future<List<PropertyView>> getViewsByProperty(String propertyId) async {
    final data =
        await ApiClient.get('/property-views/property/$propertyId')
            as List<dynamic>;
    return data
        .map((e) => PropertyView.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<PropertyView>> getViewsByUser(String userId) async {
    final data =
        await ApiClient.get('/property-views/user/$userId') as List<dynamic>;
    return data
        .map((e) => PropertyView.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
