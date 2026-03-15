import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_client.dart';  // ← correct import
import 'package:mobile/core/network/endpoints.dart';
import 'package:mobile/core/services/cloudinary_service.dart';
import 'package:mobile/core/storage/secure_storage.dart';
import 'package:mobile/features/media/models/property_media.dart';

final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  return MediaRepository();
});

class MediaRepository {
  final _storage = SecureStorage();
  final _cloudinary = CloudinaryService();

  // ── GET ───────────────────────────────────────────────────────────
  Future<List<PropertyMedia>> getByPropertyId(String propertyId) async {
    final data = await ApiClient.get(Endpoints.getMediaByPropertyId(propertyId));
    final list = data as List<dynamic>;
    return list
        .map((e) => PropertyMedia.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
  }

  // ── CREATE ────────────────────────────────────────────────────────
  Future<PropertyMedia> create(PropertyMediaCreateRequest request) async {
    final data = await ApiClient.post(
      Endpoints.createMedia,
      body: request.toJson(),
    );
    return PropertyMedia.fromJson(data as Map<String, dynamic>);
  }

  // ── DELETE ────────────────────────────────────────────────────────
  Future<void> delete(String id) async {
    await ApiClient.delete(Endpoints.deleteMediaById(id));
  }

  // ── UPLOAD IMAGE ──────────────────────────────────────────────────
 Future<String> uploadImage(ImageUploadRequest request) async {
  final result = await _cloudinary.upload(
    file: request.file,
    propertyId: request.propertyId,
    displayOrder: request.displayOrder,
  );

  await create(PropertyMediaCreateRequest(
    propertyId: request.propertyId,
    mediaType: MediaType.IMAGE,
    url: result.url,
    displayOrder: request.displayOrder,
  ));

  return result.url;
}

Future<String> uploadVideo(VideoUploadRequest request) async {
  final result = await _cloudinary.upload(
    file: request.file,
    propertyId: request.propertyId,
    displayOrder: request.displayOrder,
  );

  await create(PropertyMediaCreateRequest(
    propertyId: request.propertyId,
    mediaType: MediaType.VIDEO,
    url: result.url,
    thumbnailUrl: result.thumbnailUrl,
    displayOrder: request.displayOrder,
  ));

  return result.url;
}
}