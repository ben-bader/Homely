import 'dart:io';
import 'package:homely/core/network/api_client.dart';
import 'package:homely/core/network/endpoints.dart';
import 'cloudinary_datasource.dart';

abstract class MediaRemoteDatasource {
  Future<List<Map<String, dynamic>>> getByPropertyId(String propertyId);
  Future<Map<String, dynamic>> create(Map<String, dynamic> body);
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

class MediaRemoteDatasourceImpl implements MediaRemoteDatasource {
  final CloudinaryDatasource _cloudinary = CloudinaryDatasource();

  @override
  Future<List<Map<String, dynamic>>> getByPropertyId(String propertyId) async {
    final response = await ApiClient.get(
      Endpoints.getMediaByPropertyId(propertyId),
    );
    return List<Map<String, dynamic>>.from(response ?? []);
  }

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    final response = await ApiClient.post(Endpoints.createMedia, body: body);
    return response;
  }

  @override
  Future<void> delete(String id) async {
    await ApiClient.delete(Endpoints.deleteMediaById(id));
  }

  @override
  Future<String> uploadImage({
    required File file,
    required String propertyId,
    required int displayOrder,
  }) async {
    final result = await _cloudinary.upload(
      file: file,
      propertyId: propertyId,
      displayOrder: displayOrder,
    );
    await create({
      'propertyId': propertyId,
      'mediaType': 'IMAGE',
      'url': result.url,
      'displayOrder': displayOrder,
    });
    return result.url;
  }

  @override
  Future<String> uploadVideo({
    required File file,
    required String propertyId,
    required int displayOrder,
  }) async {
    final result = await _cloudinary.upload(
      file: file,
      propertyId: propertyId,
      displayOrder: displayOrder,
    );
    await create({
      'propertyId': propertyId,
      'mediaType': 'VIDEO',
      'url': result.url,
      if (result.thumbnailUrl != null) 'thumbnailUrl': result.thumbnailUrl,
      'displayOrder': displayOrder,
    });
    return result.url;
  }
}
