import 'api_client.dart';
import 'endpoints.dart';

/// 🔐 Authentication API Service
/// Handles all authentication-related API calls
class AuthApi {
  // ==================== LOGIN ====================

  /// Login user
  /// POST /api/auth/login
  Future<dynamic> login({
    required String email,
    required String password,
  }) async {
    return await ApiClient.post(
      Endpoints.login,
      body: {'email': email, 'password': password},
      auth: false,
    );
  }

  // ==================== REGISTER ====================

  /// Register new user
  /// POST /api/auth/register
  Future<dynamic> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role, // CLIENT or SELLER
  }) async {
    return await ApiClient.post(
      Endpoints.register,
      body: {
        'name':name,
        'email': email,
        'password': password,
        'phone': phone,
        'role': role,
      },
      auth: false,
    );
  }

  // ==================== LOGOUT ====================

  /// Logout user
  /// POST /api/auth/logout
  Future<dynamic> logout() async {
    return await ApiClient.post(Endpoints.logout, auth: true);
  }

  // ==================== REFRESH TOKEN ====================

  /// Refresh authentication token
  /// POST /api/auth/refresh
  Future<dynamic> refreshToken({
    required String refreshToken,
  }) async {
    return await ApiClient.post(
      Endpoints.refreshToken,
      body: {'refreshToken': refreshToken},
      auth: false,
    );
  }

  // ==================== REQUEST PASSWORD RESET ====================

  /// Request password reset
  /// POST /api/auth/request-password-reset
  Future<dynamic> requestPasswordReset({
    required String email,
  }) async {
    return await ApiClient.post(
      Endpoints.requestPasswordReset,
      body: {'email': email},
      auth: false,
    );
  }

  // ==================== RESET PASSWORD ====================

  /// Reset password with token
  /// POST /api/auth/reset-password
  Future<dynamic> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    return await ApiClient.post(
      '${Endpoints.resetPassword}?token=$token',
      body: {'newPassword': newPassword},
      auth: false,
    );
  }

  // ==================== VERIFY EMAIL ====================

  /// Verify email with token
  /// GET /api/auth/verify-email
  Future<dynamic> verifyEmail({
    required String token,
  }) async {
    return await ApiClient.get(
      Endpoints.verifyEmail,
      queryParams: {'token': token},
      auth: false,
    );
  }

  // ==================== RESEND VERIFICATION ====================

  /// Resend email verification
  /// POST /api/auth/resend-verification
  Future<dynamic> resendVerification({
    required String email,
  }) async {
    return await ApiClient.post(
      Endpoints.resendVerification,
      body: {'email': email},
      auth: false,
    );
  }
}
