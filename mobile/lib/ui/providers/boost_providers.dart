import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/boost_remote_datasource.dart';
import '../../data/repositories/boost_repository_impl.dart';
import '../../domain/entities/boost/boost_package_entity.dart';
import '../../domain/entities/boost/boost_purchase_entity.dart';
import '../../domain/repositories/i_boost_repository.dart';

final boostRemoteDatasourceProvider = Provider<BoostRemoteDatasource>(
  (ref) => BoostRemoteDatasourceImpl(),
);

final boostRepositoryProvider = Provider<IBoostRepository>((ref) {
  return BoostRepositoryImpl(ref.read(boostRemoteDatasourceProvider));
});

final myBoostsProvider =
    AsyncNotifierProvider<MyBoostsNotifier, List<BoostPurchaseEntity>>(
  MyBoostsNotifier.new,
);

class MyBoostsNotifier
    extends AsyncNotifier<List<BoostPurchaseEntity>> {
  @override
  Future<List<BoostPurchaseEntity>> build() =>
      ref.read(boostRepositoryProvider).getMyBoosts();

  Future<void> purchase({
    required String propertyId,
    required double amount,
    required String currency,
    required int durationDays,
  }) async {
    final previous = state;
    try {
      final created =
          await ref.read(boostRepositoryProvider).create(
                propertyId: propertyId,
                amount: amount,
                currency: currency,
                durationDays: durationDays,
              );
      state.whenData(
          (list) => state = AsyncData([created, ...list]));
    } catch (e, st) {
      state = previous;
      Error.throwWithStackTrace(e, st);
    }
  }
}

final boostPackagesProvider =
    FutureProvider<List<BoostPackageEntity>>((ref) async {
  return ref.read(boostRepositoryProvider).getBoostPackages();
});
