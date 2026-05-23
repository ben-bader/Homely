import '../../domain/entities/media/property_media_entity.dart';
import '../../domain/entities/property/property_entity.dart';
import '../../domain/repositories/i_property_repository.dart';
import '../datasources/remote/property_remote_datasource.dart';
import '../models/media/property_media_model.dart';
import '../models/property/property_model.dart';

class PropertyRepositoryImpl implements IPropertyRepository {
  final PropertyRemoteDatasource _remote;

  PropertyRepositoryImpl(this._remote);

  @override
  Future<List<PropertyEntity>> getAll() async {
    final data = await _remote.getAll();
    return data
        .map((e) =>
            PropertyModel.fromJson(e))
        .toList();
  }

  @override
  Future<PropertyEntity> getById(String id) async {
    final data = await _remote.getById(id);
    return PropertyModel.fromJson(data);
  }

  @override
  Future<List<PropertyEntity>> filter(
      Map<String, String> params) async {
    final data = await _remote.filter(params);
    return data
        .map((e) =>
            PropertyModel.fromJson(e))
        .toList();
  }

  @override
  Future<List<PropertyEntity>> search(String keyword) async {
    final data = await _remote.search(keyword);
    return data
        .map((e) =>
            PropertyModel.fromJson(e))
        .toList();
  }

  @override
  Future<List<PropertyEntity>> getMyListedProperties() async {
    final data = await _remote.getMyListedProperties();
    return data
        .map((e) =>
            PropertyModel.fromJson(e))
        .toList();
  }

  @override
  Future<PropertyEntity> create(Map<String, dynamic> body) async {
    final data = await _remote.create(body);
    return PropertyModel.fromJson(data);
  }

  @override
  Future<PropertyEntity> update(
      String id, Map<String, dynamic> body) async {
    final data = await _remote.update(id, body);
    return PropertyModel.fromJson(data);
  }

  @override
  Future<PropertyEntity> updateStatus(
      String id, PropertyStatus status) async {
    final data = await _remote.updateStatus(id, status.toJson());
    return PropertyModel.fromJson(data);
  }

  @override
  Future<void> delete(String id) => _remote.delete(id);

  @override
  Future<List<PropertyMediaEntity>> getPropertyMedia(
      String propertyId) async {
    final data = await _remote.getPropertyMedia(propertyId);
    return data
        .map((e) =>
            PropertyMediaModel.fromJson(e))
        .toList();
  }
}
