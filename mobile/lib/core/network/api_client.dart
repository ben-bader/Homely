import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:homely/core/errors/exceptions.dart';
import 'package:homely/core/network/endpoints.dart';
import 'package:homely/data/datasources/local/secure_storage.dart';
import 'package:homely/core/network/api_result.dart';
import 'package:homely/data/datasources/remote/auth_remote_datasource.dart';

class ApiClient {
  static final _storage = SecureStorage();
  // Increased timeout and retries to be more resilient on slow dev machines/networks
  static const _timeout = Duration(seconds: 30);
  static const _maxRetries = 3;
  static const _baseDelay = Duration(seconds: 1);

  static String get baseUrl => Endpoints.baseUrl;

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
    final uri = _buildUri(path, queryParams);
    return _withRetry(() async {
      final response = await http
          .get(uri, headers: await _headers(auth: auth))
          .timeout(_timeout);
      _logResponse('GET', uri, response.statusCode);
      return _handle(response);
    }, retry: true);
  }

  static Future<dynamic> postMultipart(
    String path, {
    required String filePath,
    required String fieldName,
    bool auth = true,
  }) async {
    final uri = _buildUri(path);
    final headers = await _headers(auth: auth);

    // Multipart n'accepte pas Content-Type JSON — on le retire
    headers.remove('Content-Type');

    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(headers);

    request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));

    final streamedResponse = await request.send().timeout(_timeout);
    final response = await http.Response.fromStream(streamedResponse);

    _logResponse('POST MULTIPART', uri, response.statusCode);
    return _handle(response);
  }

  // Safe variants that return ApiResult instead of throwing
  static Future<ApiResult<T?>> safeGet<T>(
    String path, {
    Map<String, String>? queryParams,
    bool auth = true,
  }) async {
    try {
      final res = await get(path, queryParams: queryParams, auth: auth);
      return ApiSuccess<T?>(res as T?);
    } catch (e) {
      if (e is ApiException && e.statusCode == 401 && auth) {
        // Try refresh once
        final refresh = await _storage.getRefreshToken();
        if (refresh != null && refresh.isNotEmpty) {
          try {
            final authRemote = AuthRemoteDatasourceImpl();
            final newData = await authRemote.refreshToken(refresh);
            final newToken = newData['accessToken'] as String?;
            final newRefreshToken = newData['refreshToken'] as String?;
            if (newToken != null && newToken.isNotEmpty) {
              await _storage.setToken(newToken);
              if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
                await _storage.setRefreshToken(newRefreshToken);
              }
              // retry original request once
              final res = await get(path, queryParams: queryParams, auth: auth);
              return ApiSuccess<T?>(res as T?);
            }
          } catch (_) {}
        }
      }
      if (e is Exception)
        return ApiFailure<T?>(
          e,
          statusCode: e is ApiException ? e.statusCode : null,
          message: e.toString(),
        );
      return ApiFailure<T?>(Exception('Unknown error'));
    }
  }

  static Future<ApiResult<T?>> safePost<T>(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    try {
      final res = await post(path, body: body, auth: auth);
      return ApiSuccess<T?>(res as T?);
    } catch (e) {
      if (e is ApiException && e.statusCode == 401 && auth) {
        final refresh = await _storage.getRefreshToken();
        if (refresh != null && refresh.isNotEmpty) {
          try {
            final authRemote = AuthRemoteDatasourceImpl();
            final newData = await authRemote.refreshToken(refresh);
            final newToken = newData['accessToken'] as String?;
            final newRefreshToken = newData['refreshToken'] as String?;
            if (newToken != null && newToken.isNotEmpty) {
              await _storage.setToken(newToken);
              if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
                await _storage.setRefreshToken(newRefreshToken);
              }
              final res = await post(path, body: body, auth: auth);
              return ApiSuccess<T?>(res as T?);
            }
          } catch (_) {}
        }
      }
      if (e is Exception)
        return ApiFailure<T?>(
          e,
          statusCode: e is ApiException ? e.statusCode : null,
          message: e.toString(),
        );
      return ApiFailure<T?>(Exception('Unknown error'));
    }
  }

  static Future<ApiResult<T?>> safePut<T>(
    String path, {
    Map<String, String>? queryParams,
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    try {
      final res = await put(
        path,
        queryParams: queryParams,
        body: body,
        auth: auth,
      );
      return ApiSuccess<T?>(res as T?);
    } catch (e) {
      if (e is ApiException && e.statusCode == 401 && auth) {
        final refresh = await _storage.getRefreshToken();
        if (refresh != null && refresh.isNotEmpty) {
          try {
            final authRemote = AuthRemoteDatasourceImpl();
            final newData = await authRemote.refreshToken(refresh);
            final newToken = newData['accessToken'] as String?;
            final newRefreshToken = newData['refreshToken'] as String?;
            if (newToken != null && newToken.isNotEmpty) {
              await _storage.setToken(newToken);
              if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
                await _storage.setRefreshToken(newRefreshToken);
              }
              final res = await put(
                path,
                queryParams: queryParams,
                body: body,
                auth: auth,
              );
              return ApiSuccess<T?>(res as T?);
            }
          } catch (_) {}
        }
      }
      if (e is Exception)
        return ApiFailure<T?>(
          e,
          statusCode: e is ApiException ? e.statusCode : null,
          message: e.toString(),
        );
      return ApiFailure<T?>(Exception('Unknown error'));
    }
  }

  static Future<ApiResult<T?>> safeDelete<T>(
    String path, {
    Map<String, String>? queryParams,
    bool auth = true,
  }) async {
    try {
      final res = await delete(path, queryParams: queryParams, auth: auth);
      return ApiSuccess<T?>(res as T?);
    } catch (e) {
      if (e is Exception) return ApiFailure<T?>(e);
      return ApiFailure<T?>(Exception('Unknown error'));
    }
  }

  static Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final uri = _buildUri(path);
    return _withRetry(() async {
      final response = await http
          .post(
            uri,
            headers: await _headers(auth: auth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);
      _logResponse('POST', uri, response.statusCode);
      return _handle(response);
    });
  }

  static Future<dynamic> put(
    String path, {
    Map<String, String>? queryParams,
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final uri = _buildUri(path, queryParams);
    return _withRetry(() async {
      final response = await http
          .put(
            uri,
            headers: await _headers(auth: auth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);
      _logResponse('PUT', uri, response.statusCode);
      return _handle(response);
    });
  }

  static Future<dynamic> delete(
    String path, {
    Map<String, String>? queryParams,
    bool auth = true,
  }) async {
    final uri = _buildUri(path, queryParams);
    return _withRetry(() async {
      final response = await http
          .delete(uri, headers: await _headers(auth: auth))
          .timeout(_timeout);
      _logResponse('DELETE', uri, response.statusCode);
      return _handle(response);
    });
  }

  static Future<dynamic> patch(
    String path, {
    Map<String, String>? queryParams,
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final uri = _buildUri(path, queryParams);
    return _withRetry(() async {
      final response = await http
          .patch(
            uri,
            headers: await _headers(auth: auth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);
      _logResponse('PATCH', uri, response.statusCode);
      return _handle(response);
    });
  }

  static Future<Map<String, dynamic>> fetchUserById(String userId) async {
    final data = await get(Endpoints.userById(userId));
    return data as Map<String, dynamic>;
  }

  // ── Pagination helper ─────────────────────────────────────
  /// Default page size (30 items per page)
  static const int defaultPageSize = 30;

  /// Validate and sanitize page number
  static int validatePageNumber(int? pageNumber) {
    if (pageNumber == null || pageNumber < 0) return 0;
    return pageNumber;
  }

  /// Validate and sanitize page size
  static int validatePageSize(int? pageSize) {
    if (pageSize == null || pageSize <= 0) return defaultPageSize;
    return pageSize > 100 ? 100 : pageSize; // Max 100 items per page
  }

  static Uri _buildUri(String path, [Map<String, String>? queryParams]) {
    var cleanBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final cleanPath = path.startsWith('/') ? path : '/$path';

    // If developer used localhost in baseUrl and the app is running on an Android emulator,
    // map localhost to the emulator's host loopback address so requests reach the host machine.
    try {
      if (!kIsWeb && Platform.isAndroid) {
        if (cleanBase.contains('localhost')) {
          cleanBase = cleanBase.replaceAll('localhost', '10.0.2.2');
        } else if (cleanBase.contains('127.0.0.1')) {
          cleanBase = cleanBase.replaceAll('127.0.0.1', '10.0.2.2');
        }
      }
    } catch (_) {}

    final uri = Uri.parse(
      '$cleanBase$cleanPath',
    ).replace(queryParameters: queryParams);
    debugPrint('[ApiClient] Built URI: ${uri.toString()}');
    return uri;
  }

  static void _logResponse(String method, Uri uri, int statusCode) {
    debugPrint('[ApiClient] $method ${uri.toString()} => $statusCode');
  }

  static Future<T> _withRetry<T>(
    Future<T> Function() action, {
    bool retry = false,
  }) async {
    var attempt = 0;
    while (true) {
      try {
        return await action();
      } on TimeoutException {
        attempt++;
        debugPrint('[ApiClient] Timeout on attempt $attempt/$_maxRetries');
        if (attempt > _maxRetries) {
          throw NetworkException('Request timed out after $_timeout.');
        }
        await Future.delayed(_backoffDelay(attempt));
      } on SocketException {
        attempt++;
        debugPrint(
          '[ApiClient] SocketException on attempt $attempt/$_maxRetries',
        );
        if (attempt > _maxRetries) {
          throw NetworkException(
            'Network unavailable. Please check your connection.',
          );
        }
        await Future.delayed(_backoffDelay(attempt));
      } on http.ClientException {
        attempt++;
        debugPrint(
          '[ApiClient] Http client exception on attempt $attempt/$_maxRetries',
        );
        if (attempt > _maxRetries) {
          throw NetworkException('Network error. Please try again.');
        }
        await Future.delayed(_backoffDelay(attempt));
      } on ApiException catch (e) {
        // Only retry server (5xx) errors when retry is explicitly enabled (GET requests)
        if (!retry || attempt >= _maxRetries || e.statusCode < 500) {
          rethrow;
        }
        attempt++;
        await Future.delayed(_backoffDelay(attempt));
      }
    }
  }

  static Duration _backoffDelay(int attempt) {
    final delay = _baseDelay.inMilliseconds * (1 << (attempt - 1));
    final capped = Duration(
      milliseconds: delay.clamp(_baseDelay.inMilliseconds, 6000),
    );
    return capped;
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
    // Log server errors for diagnostics
    if (res.statusCode >= 500) {
      try {
        debugPrint('[ApiClient] Server error ${res.statusCode}: ${res.body}');
      } catch (_) {}
    }
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
