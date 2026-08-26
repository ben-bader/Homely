import '../entities/boost/boost_package_entity.dart';
import '../entities/boost/boost_purchase_entity.dart';

abstract class IBoostRepository {
  Future<BoostPurchaseEntity> create({
    required String propertyId,
    required double amount,
    required String currency,
    required int durationDays,
  });
  Future<List<BoostPurchaseEntity>> getMyBoosts();
  Future<List<BoostPackageEntity>> getBoostPackages();
}
