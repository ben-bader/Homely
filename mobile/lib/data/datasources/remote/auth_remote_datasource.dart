import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:homely/core/network/api_client.dart';
import 'package:homely/core/network/endpoints.dart';

abstract class AuthRemoteDatasource {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  });
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
  });
  Future<Map<String, dynamic>> logout({String? refreshToken});
  Future<Map<String, dynamic>> refreshToken(String token);
  Future<Map<String, dynamic>> requestPasswordReset({required String email});
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String email,
    required String password,
    required String confirmPassword,
  });
  Future<Map<String, dynamic>> verifyEmail({required String token});
  Future<Map<String, dynamic>> resendVerification({required String email});
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post(
      Endpoints.login,
      body: {'email': email, 'password': password},
    );
    return response;
  }

  @override
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) async {
    final response = await ApiClient.post(
      Endpoints.register,
      body: {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'role': role,
      },
    );
    return response;
  }

  @override
  Future<Map<String, dynamic>> logout({String? refreshToken}) async {
    final response = await ApiClient.post(
      Endpoints.logout,
      body: refreshToken != null ? {'refreshToken': refreshToken} : null,
    );
    return response;
  }

  @override
  Future<Map<String, dynamic>> refreshToken(String token) async {
    // Use direct http call to avoid recursion into ApiClient auth flow
    final uri = Uri.parse(Endpoints.getFullUrl(Endpoints.refreshToken));
    final resp = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({'refreshToken': token}),
        )
        .timeout(const Duration(seconds: 30));
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      try {
        return jsonDecode(resp.body) as Map<String, dynamic>;
      } catch (_) {
        return <String, dynamic>{};
      }
    }
    throw Exception('Failed to refresh token: ${resp.statusCode}');
  }

  @override
  Future<Map<String, dynamic>> requestPasswordReset({
    required String email,
  }) async {
    final response = await ApiClient.post(
      Endpoints.requestPasswordReset,
      body: {'email': email},
    );
    return response;
  }

  @override
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await ApiClient.post(
      Endpoints.resetPassword,
      auth: false,
      body: {
        'email': email,
        'token': token,
        'newPassword': password,
        'confirmPassword': confirmPassword,
      },
    );
    return response;
  }

  @override
  Future<Map<String, dynamic>> verifyEmail({required String token}) async {
    final response = await ApiClient.get(
      Endpoints.verifyEmail,
      auth: false,
      queryParams: {'token': token},
    );
    return response;
  }

  @override
  Future<Map<String, dynamic>> resendVerification({
    required String email,
  }) async {
    final response = await ApiClient.post(
      Endpoints.resendVerification,
      body: {'email': email},
    );
    return response;
  }
}
