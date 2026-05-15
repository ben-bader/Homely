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
  Future<Map<String, dynamic>> logout();
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
  Future<Map<String, dynamic>> logout() async {
    final response = await ApiClient.post(Endpoints.logout);
    return response;
  }

  @override
  Future<Map<String, dynamic>> refreshToken(String token) async {
    final response = await ApiClient.post(
      '/auth/refresh',
      body: {'token': token},
    );
    return response;
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
