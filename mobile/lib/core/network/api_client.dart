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
  static const _timeout = Duration(seconds: 15);
  static const _maxRetries = 2;
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
            final newToken = newData['token'] as String?;
            if (newToken != null && newToken.isNotEmpty) {
              await _storage.setToken(newToken);
              // retry original request once
              final res = await get(path, queryParams: queryParams, auth: auth);
              return ApiSuccess<T?>(res as T?);
            }
          } catch (_) {}
        }
      }
      if (e is Exception) return ApiFailure<T?>(e, statusCode: e is ApiException ? e.statusCode : null, message: e.toString());
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
            final newToken = newData['token'] as String?;
            if (newToken != null && newToken.isNotEmpty) {
              await _storage.setToken(newToken);
              final res = await post(path, body: body, auth: auth);
              return ApiSuccess<T?>(res as T?);
            }
          } catch (_) {}
        }
      }
      if (e is Exception) return ApiFailure<T?>(e, statusCode: e is ApiException ? e.statusCode : null, message: e.toString());
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
      final res = await put(path, queryParams: queryParams, body: body, auth: auth);
      return ApiSuccess<T?>(res as T?);
    } catch (e) {
      if (e is ApiException && e.statusCode == 401 && auth) {
        final refresh = await _storage.getRefreshToken();
        if (refresh != null && refresh.isNotEmpty) {
          try {
            final authRemote = AuthRemoteDatasourceImpl();
            final newData = await authRemote.refreshToken(refresh);
            final newToken = newData['token'] as String?;
            if (newToken != null && newToken.isNotEmpty) {
              await _storage.setToken(newToken);
              final res = await put(path, queryParams: queryParams, body: body, auth: auth);
              return ApiSuccess<T?>(res as T?);
            }
          } catch (_) {}
        }
      }
      if (e is Exception) return ApiFailure<T?>(e, statusCode: e is ApiException ? e.statusCode : null, message: e.toString());
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
    final cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$cleanBase$cleanPath').replace(queryParameters: queryParams);
  }

  static void _logResponse(String method, Uri uri, int statusCode) {
    debugPrint('[ApiClient] $method ${uri.toString()} => $statusCode');
  }

  static Future<T> _withRetry<T>(Future<T> Function() action, {bool retry = false}) async {
    var attempt = 0;
    while (true) {
      try {
        return await action();
      } on TimeoutException {
        attempt++;
        if (attempt > _maxRetries) {
          throw NetworkException('Request timed out after $_timeout.');
        }
        await Future.delayed(_backoffDelay(attempt));
      } on SocketException {
        attempt++;
        if (attempt > _maxRetries) {
          throw NetworkException('Network unavailable. Please check your connection.');
        }
        await Future.delayed(_backoffDelay(attempt));
      } on http.ClientException {
        attempt++;
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
    final capped = Duration(milliseconds: delay.clamp(_baseDelay.inMilliseconds, 6000));
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
