import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/property_views/repositories/property_view_repository.dart';

final propertyViewCountProvider =
    FutureProvider.autoDispose.family<int, String>((ref, propertyId) async {
  final repo = ref.read(propertyViewRepositoryProvider);
  return repo.getViewCount(propertyId);
});

final trackPropertyViewProvider =
    FutureProvider.autoDispose.family<void, String>((ref, propertyId) async {
  final repo = ref.read(propertyViewRepositoryProvider);
  try {
    await repo.trackView(propertyId);
    ref.invalidate(propertyViewCountProvider(propertyId));
  } catch (_) {
  }
});