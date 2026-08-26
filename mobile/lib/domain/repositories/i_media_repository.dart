import 'dart:io';
import '../entities/media/property_media_entity.dart';

abstract class IMediaRepository {
  Future<List<PropertyMediaEntity>> getByPropertyId(String propertyId);
  Future<PropertyMediaEntity> create(Map<String, dynamic> request);
  Future<void> delete(String id);
  Future<String> uploadImage({
    required File file,
    required String propertyId,
    required int displayOrder,
  });
  Future<String> uploadVideo({
    required File file,
    required String propertyId,
    required int displayOrder,
  });
}
