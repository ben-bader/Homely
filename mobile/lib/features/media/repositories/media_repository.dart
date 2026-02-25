
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/storage/secure_storage.dart';
import 'package:mobile/features/media/models/property_media.dart';

final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  return MediaRepository();
});

class MediaRepository {
  final _storage = SecureStorage();
  Future<List<PropertyMedia>> getByPropertyId(String propertyId) async {
    final data = await ApiClient.get('/api/media/$propertyId/media');
    final list = data as List<dynamic>;
    return list
        .map((e) => PropertyMedia.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
  }
  Future<PropertyMedia> create(PropertyMediaCreateRequest request) async {
    final data = await ApiClient.post('/api/media', body: request.toJson());
    return PropertyMedia.fromJson(data as Map<String, dynamic>);
  }
  Future<void> delete(String id) async {
    await ApiClient.delete('/api/media/$id');
  }
  Future<String> uploadVideo(VideoUploadRequest request) async {
    final uri = Uri.parse('${ApiClient.baseUrl}/api/media/upload').replace(
      queryParameters: {
        'propertyId': request.propertyId,
        'displayOrder': request.displayOrder.toString(),
      },
    );

    final multipartRequest = http.MultipartRequest('POST', uri);

    final token = await _storage.getToken();
    if (token != null) {
      multipartRequest.headers['Authorization'] = 'Bearer $token';
    }
    final multipartFile = await http.MultipartFile.fromPath(
      'file',
      request.file.path,
      contentType: http_parser.MediaType('video', 'mp4'),
    );
    multipartRequest.files.add(multipartFile);

    final streamed = await multipartRequest.send().timeout(
      const Duration(seconds: 120),
    );
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body.replaceAll('"', '').trim();
    }
    final message = response.body.isNotEmpty
        ? response.body
        : 'Upload failed (${response.statusCode})';

    switch (response.statusCode) {
      case 400:
        throw ApiException('Invalid upload data: $message', 400);
      case 401:
        throw ApiException('Unauthorized. Please log in again.', 401);
      case 403:
        throw ApiException('Access denied.', 403);
      case 413:
        throw ApiException(
          'File too large. Please choose a smaller video.',
          413,
        );
      case 500:
        throw ApiException(
          'Server error during upload. Please try again.',
          500,
        );
      default:
        throw ApiException(message, response.statusCode);
    }
  }
}
