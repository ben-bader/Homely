// lib/features/seller/providers/seller_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/property/models/property.dart';
import 'package:mobile/features/property/providers/property_providers.dart';
import 'package:mobile/features/property/repositories/property_repository.dart';

// ── Seller's Listings Provider ────────────────────────────────────────────────
// FIX: was repo.getSellerListings() — correct method name is getMyListedProperties()
final sellerListingsProvider =
    FutureProvider.autoDispose<List<Property>>((ref) async {
  final repo = ref.watch(propertyRepositoryProvider);
  return repo.getMyListedProperties();
});

// lib/features/seller/providers/seller_providers.dart


// FIX: removed refreshSellerListingsProvider — invalidate(sellerListingsProvider) returns
// void, not a Future, so wrapping it in FutureProvider caused a type mismatch.
// Call ref.invalidate(sellerListingsProvider) directly wherever a refresh is needed.