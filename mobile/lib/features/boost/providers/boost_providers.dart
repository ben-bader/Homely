import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/boost/models/boost_purchase.dart';
import 'package:mobile/features/boost/models/boost_package.dart';
import 'package:mobile/features/boost/repositories/boost_repository.dart';

final myBoostsProvider =
    AsyncNotifierProvider<MyBoostsNotifier, List<BoostPurchase>>(
      MyBoostsNotifier.new,
    );

class MyBoostsNotifier extends AsyncNotifier<List<BoostPurchase>> {
  @override
  Future<List<BoostPurchase>> build() =>
      ref.read(boostRepositoryProvider).getMyBoosts();

  Future<void> purchase({
    required String propertyId,
    required double amount,
    required String currency,
    required int durationDays,
  }) async {
    final previous = state;
    try {
      final created = await ref
          .read(boostRepositoryProvider)
          .create(
            propertyId: propertyId,
            amount: amount,
            currency: currency,
            durationDays: durationDays,
          );
      state.whenData((list) => state = AsyncData([created, ...list]));
    } catch (e, st) {
      state = previous;
      Error.throwWithStackTrace(e, st);
    }
  }
}

// Boost Packages Provider
final boostPackagesProvider =
    FutureProvider<List<BoostPackage>>((ref) async {
  return ref.read(boostRepositoryProvider).getBoostPackages();
});

class BoostPlan {
  final String label;
  final String description;
  final double amount;
  final String currency;
  final int durationDays;
  final String badge;

  const BoostPlan({
    required this.label,
    required this.description,
    required this.amount,
    required this.currency,
    required this.durationDays,
    this.badge = '',
  });
}
