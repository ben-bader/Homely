// lib/features/seller/providers/seller_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/property/models/property.dart';
import 'package:mobile/features/property/repositories/property_repository.dart';

// ── Seller's Listings Provider ────────────────────────────────────────────────
final sellerListingsProvider =
    FutureProvider.autoDispose<List<Property>>((ref) async {
  final repo = ref.watch(propertyRepositoryProvider);
  return repo.getSellerListings();
});

// ── Refresh seller listings ───────────────────────────────────────────────────
final refreshSellerListingsProvider = FutureProvider((ref) async {
  return ref.invalidate(sellerListingsProvider);
});
