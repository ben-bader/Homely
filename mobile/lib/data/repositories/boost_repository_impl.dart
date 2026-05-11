import '../../domain/entities/boost/boost_package_entity.dart';
import '../../domain/entities/boost/boost_purchase_entity.dart';
import '../../domain/repositories/i_boost_repository.dart';
import '../datasources/remote/boost_remote_datasource.dart';
import '../models/boost/boost_package_model.dart';
import '../models/boost/boost_purchase_model.dart';

class BoostRepositoryImpl implements IBoostRepository {
  final BoostRemoteDatasource _remote;

  BoostRepositoryImpl(this._remote);

  @override
  Future<BoostPurchaseEntity> create({
    required String propertyId,
    required double amount,
    required String currency,
    required int durationDays,
  }) async {
    final data = await _remote.create(
        propertyId: propertyId,
        amount: amount,
        currency: currency,
        durationDays: durationDays);
    return BoostPurchaseModel.fromJson(data);
  }

  @override
  Future<List<BoostPurchaseEntity>> getMyBoosts() async {
    final data = await _remote.getMyBoosts();
    return data
        .map((e) =>
            BoostPurchaseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<BoostPackageEntity>> getBoostPackages() async {
    final data = await _remote.getBoostPackages();
    return data
        .map((e) =>
            BoostPackageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
