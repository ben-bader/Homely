import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/storage/secure_storage.dart';

class ApiClient {
  static const String baseUrl =
      'https://unparrying-christene-reductively.ngrok-free.dev';

  static final _storage = SecureStorage();

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = await _storage.getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<dynamic> get(
    String path, {
    Map<String, String>? queryParams,
    bool auth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: queryParams);
    final res = await http
        .get(uri, headers: await _headers(auth: auth))
        .timeout(const Duration(seconds: 15));
    return _handle(res);
  }

  static Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final res = await http
        .post(
          Uri.parse('$baseUrl$path'),
          headers: await _headers(auth: auth),
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(const Duration(seconds: 15));
    return _handle(res);
  }

  static Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final res = await http
        .put(
          Uri.parse('$baseUrl$path'),
          headers: await _headers(),
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(const Duration(seconds: 15));
    return _handle(res);
  }

  static Future<dynamic> delete(String path) async {
    final res = await http
        .delete(Uri.parse('$baseUrl$path'), headers: await _headers())
        .timeout(const Duration(seconds: 15));
    return _handle(res);
  }

  // ── User ──────────────────────────────────────────────────
  static Future<Map<String, dynamic>> fetchUserById(String userId) async {
    final data = await get('/api/users/$userId');
    return data as Map<String, dynamic>;
  }

  // ── Response handler ──────────────────────────────────────
  static dynamic _handle(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      try {
        return jsonDecode(utf8.decode(res.bodyBytes));
      } catch (_) {
        return res.body;
      }
    }
    String message;
    try {
      final json = jsonDecode(res.body);
      message = json['message'] ?? json['error'] ?? 'Error ${res.statusCode}';
    } catch (_) {
      message = res.body.isNotEmpty ? res.body : 'Error ${res.statusCode}';
    }
    switch (res.statusCode) {
      case 400:
        throw ApiException('Invalid data: $message', 400);
      case 401:
        throw ApiException('Unauthorized. Please log in again.', 401);
      case 403:
        throw ApiException('Access denied.', 403);
      case 404:
        throw ApiException('Resource not found.', 404);
      case 500:
        throw ApiException('Server error. Please try again.', 500);
      default:
        throw ApiException(message, res.statusCode);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  const ApiException(this.message, this.statusCode);
  @override
  String toString() => message;
}