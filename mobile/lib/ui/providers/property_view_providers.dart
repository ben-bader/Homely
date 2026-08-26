import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/property_view_remote_datasource.dart';
import '../../data/repositories/property_view_repository_impl.dart';
import '../../domain/repositories/i_property_view_repository.dart';

final propertyViewRemoteDatasourceProvider =
    Provider<PropertyViewRemoteDatasource>(
      (ref) => PropertyViewRemoteDatasourceImpl(),
    );

final propertyViewRepositoryProvider = Provider<IPropertyViewRepository>((ref) {
  return PropertyViewRepositoryImpl(
    ref.read(propertyViewRemoteDatasourceProvider),
  );
});

final propertyViewCountProvider = FutureProvider.autoDispose
    .family<int, String>((ref, propertyId) async {
      return ref.read(propertyViewRepositoryProvider).getViewCount(propertyId);
    });

final trackPropertyViewProvider = FutureProvider.autoDispose
    .family<void, String>((ref, propertyId) async {
      try {
        await ref.read(propertyViewRepositoryProvider).trackView(propertyId);
        ref.invalidate(propertyViewCountProvider(propertyId));
      } catch (_) {}
    });
