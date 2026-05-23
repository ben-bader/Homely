import 'dart:io';
import '../../domain/entities/media/property_media_entity.dart';
import '../../domain/repositories/i_media_repository.dart';
import '../datasources/remote/media_remote_datasource.dart';
import '../models/media/property_media_model.dart';

class MediaRepositoryImpl implements IMediaRepository {
  final MediaRemoteDatasource _remote;

  MediaRepositoryImpl(this._remote);

  @override
  Future<List<PropertyMediaEntity>> getByPropertyId(String propertyId) async {
    final data = await _remote.getByPropertyId(propertyId);
    return (data
        .map((e) => PropertyMediaModel.fromJson(e))
        .toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder)));
  }

  @override
  Future<PropertyMediaEntity> create(Map<String, dynamic> request) async {
    final data = await _remote.create(request);
    return PropertyMediaModel.fromJson(data);
  }

  @override
  Future<void> delete(String id) => _remote.delete(id);

  @override
  Future<String> uploadImage({
    required File file,
    required String propertyId,
    required int displayOrder,
  }) => _remote.uploadImage(
    file: file,
    propertyId: propertyId,
    displayOrder: displayOrder,
  );

  @override
  Future<String> uploadVideo({
    required File file,
    required String propertyId,
    required int displayOrder,
  }) => _remote.uploadVideo(
    file: file,
    propertyId: propertyId,
    displayOrder: displayOrder,
  );
}
