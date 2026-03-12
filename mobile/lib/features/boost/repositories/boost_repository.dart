import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/features/boost/models/boost_purchase.dart';
import 'package:mobile/features/boost/models/boost_package.dart';

final boostRepositoryProvider = Provider<BoostRepository>(
  (ref) => BoostRepository(),
);

class BoostRepository {
  Future<BoostPurchase> create({
    required String propertyId,
    required double amount,
    required String currency,
    required int durationDays,
  }) async {
    final data =
        await ApiClient.post(
              '/boost',
              body: {
                'propertyId': propertyId,
                'amount': amount,
                'currency': currency,
                'durationDays': durationDays,
              },
            )
            as Map<String, dynamic>;
    return BoostPurchase.fromJson(data);
  }

  Future<List<BoostPurchase>> getMyBoosts() async {
    final data = await ApiClient.get('/boost/my-boosts') as List<dynamic>;
    return data
        .map((e) => BoostPurchase.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<BoostPurchase> getById(String id) async {
    final data = await ApiClient.get('/boost/$id') as Map<String, dynamic>;
    return BoostPurchase.fromJson(data);
  }

  Future<List<BoostPackage>> getBoostPackages() async {
    final data = await ApiClient.get('/boost/packages') as List<dynamic>;
    return data
        .map((e) => BoostPackage.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
