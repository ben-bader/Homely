import 'api_client.dart';
import 'endpoints.dart';

/// 🔐 Authentication API Service
/// Handles all authentication-related API calls
class AuthApi {
  final ApiClient _apiClient;

  AuthApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // ==================== LOGIN ====================

  /// Login user
  /// POST /api/auth/login
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    return await _apiClient.post(
      Endpoints.login,
      body: {'email': email, 'password': password},
      includeAuth: false,
    );
  }

  // ==================== REGISTER ====================

  /// Register new user
  /// POST /api/auth/register
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required String role, // CLIENT or SELLER
  }) async {
    return await _apiClient.post(
      Endpoints.register,
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'phone': phone,
        'role': role,
      },
      includeAuth: false,
    );
  }

  // ==================== LOGOUT ====================

  /// Logout user
  /// POST /api/auth/logout
  Future<ApiResponse<void>> logout() async {
    return await _apiClient.post(Endpoints.logout, includeAuth: true);
  }

  // ==================== REFRESH TOKEN ====================

  /// Refresh authentication token
  /// POST /api/auth/refresh
  Future<ApiResponse<Map<String, dynamic>>> refreshToken({
    required String refreshToken,
  }) async {
    return await _apiClient.post(
      Endpoints.refreshToken,
      body: {'refreshToken': refreshToken},
      includeAuth: false,
    );
  }

  // ==================== FORGOT PASSWORD ====================

  /// Request password reset
  /// POST /api/auth/forgot-password
  Future<ApiResponse<Map<String, dynamic>>> forgotPassword({
    required String email,
  }) async {
    return await _apiClient.post(
      Endpoints.forgotPassword,
      body: {'email': email},
      includeAuth: false,
    );
  }

  // ==================== RESET PASSWORD ====================

  /// Reset password with token
  /// POST /api/auth/reset-password
  Future<ApiResponse<Map<String, dynamic>>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    return await _apiClient.post(
      Endpoints.resetPassword,
      body: {'token': token, 'newPassword': newPassword},
      includeAuth: false,
    );
  }

  // ==================== VERIFY EMAIL ====================

  /// Verify email with token
  /// GET /api/auth/verify-email
  Future<ApiResponse<Map<String, dynamic>>> verifyEmail({
    required String token,
  }) async {
    return await _apiClient.get(
      Endpoints.verifyEmail,
      queryParameters: {'token': token},
      includeAuth: false,
    );
  }

  // ==================== RESEND VERIFICATION ====================

  /// Resend email verification
  /// POST /api/auth/resend-verification
  Future<ApiResponse<Map<String, dynamic>>> resendVerification({
    required String email,
  }) async {
    return await _apiClient.post(
      Endpoints.resendVerification,
      body: {'email': email},
      includeAuth: false,
    );
  }
}
