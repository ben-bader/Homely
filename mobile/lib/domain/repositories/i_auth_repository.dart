import '../entities/auth/auth_entity.dart';

abstract class IAuthRepository {
  Future<AuthEntity> login(
      {required String email, required String password});
  Future<AuthEntity> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
  });
  Future<void> logout();
  Future<void> requestPasswordReset(String email);
  Future<void> resetPassword({
    required String token,
    required String email,
    required String password,
    required String confirmPassword,
  });
  Future<void> verifyEmail(String token);
  Future<void> resendVerification(String email);
  Future<bool> isLoggedIn();
  Future<String> getUserRole();
  Future<String?> getCurrentUserId();
  Future<String?> getToken();
  Future<AuthEntity?> getCurrentSession();
}
