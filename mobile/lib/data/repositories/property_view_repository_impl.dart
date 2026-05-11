import '../../domain/entities/property_view/property_view_entity.dart';
import '../../domain/repositories/i_property_view_repository.dart';
import '../datasources/remote/property_view_remote_datasource.dart';
import '../models/property_view/property_view_model.dart';

class PropertyViewRepositoryImpl implements IPropertyViewRepository {
  final PropertyViewRemoteDatasource _remote;

  PropertyViewRepositoryImpl(this._remote);

  @override
  Future<PropertyViewEntity> trackView(String propertyId) async {
    final data = await _remote.trackView(propertyId);
    return PropertyViewModel.fromJson(data);
  }

  @override
  Future<int> getViewCount(String propertyId) =>
      _remote.getViewCount(propertyId);

  @override
  Future<List<PropertyViewEntity>> getViewsByProperty(
      String propertyId) async {
    final data = await _remote.getViewsByProperty(propertyId);
    return data
        .map((e) =>
            PropertyViewModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<PropertyViewEntity>> getViewsByUser(
      String userId) async {
    final data = await _remote.getViewsByUser(userId);
    return data
        .map((e) =>
            PropertyViewModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
