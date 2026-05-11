import 'package:homely/core/network/api_client.dart';

abstract class BoostRemoteDatasource {
  Future<List<Map<String, dynamic>>> getBoostPackages();
  Future<Map<String, dynamic>> purchaseBoost(
    String packageId,
    String propertyId,
  );
  Future<List<Map<String, dynamic>>> getMyBoosts();
  Future<Map<String, dynamic>> create({
    required String propertyId,
    required double amount,
    required String currency,
    required int durationDays,
  });
}

class BoostRemoteDatasourceImpl implements BoostRemoteDatasource {
  @override
  Future<List<Map<String, dynamic>>> getBoostPackages() async {
    final response = await ApiClient.get('/boosts/packages');
    return List<Map<String, dynamic>>.from(response ?? []);
  }

  @override
  Future<Map<String, dynamic>> purchaseBoost(
    String packageId,
    String propertyId,
  ) async {
    final response = await ApiClient.post(
      '/boosts/purchase',
      body: {'packageId': packageId, 'propertyId': propertyId},
    );
    return response;
  }

  @override
  Future<List<Map<String, dynamic>>> getMyBoosts() async {
    final response = await ApiClient.get('/boosts/my-boosts');
    return List<Map<String, dynamic>>.from(response ?? []);
  }

  @override
  Future<Map<String, dynamic>> create({
    required String propertyId,
    required double amount,
    required String currency,
    required int durationDays,
  }) async {
    final response = await ApiClient.post(
      '/boosts/create',
      body: {
        'propertyId': propertyId,
        'amount': amount,
        'currency': currency,
        'durationDays': durationDays,
      },
    );
    return response;
  }
}
