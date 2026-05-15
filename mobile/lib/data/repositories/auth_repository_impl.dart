import '../../domain/entities/auth/auth_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/local/secure_storage.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../models/auth/auth_response_model.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDatasource _remote;
  final SecureStorage _storage;

  AuthRepositoryImpl(this._remote, this._storage);

  @override
  Future<AuthEntity> login({
    required String email,
    required String password,
  }) async {
    final data = await _remote.login(email: email, password: password);
    final auth = AuthResponseModel.fromJson(data);
    await _saveSession(auth);
    return auth;
  }

  @override
  Future<AuthEntity> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) async {
    final data = await _remote.register(
      name: name,
      email: email,
      password: password,
      phone: phone,
      role: role,
    );
    final auth = AuthResponseModel.fromJson(data);
    await _saveSession(auth);
    return auth;
  }

  @override
  Future<void> logout() async {
    try {
      await _remote.logout();
    } catch (_) {}
    await _storage.clearAll();
  }

  @override
  Future<void> requestPasswordReset(String email) =>
      _remote.requestPasswordReset(email: email);

  @override
  Future<void> resetPassword({
    required String token,
    required String email,
    required String password,
    required String confirmPassword,
  }) =>
      _remote.resetPassword(
        token: token,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

  @override
  Future<void> verifyEmail(String token) => _remote.verifyEmail(token: token);

  @override
  Future<void> resendVerification(String email) =>
      _remote.resendVerification(email: email);

  @override
  Future<bool> isLoggedIn() async {
    final token = await _storage.getToken();
    return token != null;
  }

  @override
  Future<String> getUserRole() async {
    final role = await _storage.getUserRole();
    return role ?? 'CLIENT';
  }

  @override
  Future<String?> getCurrentUserId() async => _storage.getUserId();

  @override
  Future<String?> getToken() => _storage.getToken();

  @override
  Future<AuthEntity?> getCurrentSession() async {
    final token = await _storage.getToken();
    if (token == null) return null;
    final email = await _storage.getUserEmail();
    final name = await _storage.getUserName();
    final role = await _storage.getUserRole();
    final userId = await _storage.getUserId();
    return AuthResponseModel(
      token: token,
      userId: userId ?? '',
      email: email ?? '',
      name: name ?? '',
      role: role ?? 'CLIENT',
    );
  }

  Future<void> _saveSession(AuthEntity auth) async {
    await _storage.saveUserSession(
      token: auth.token,
      userId: auth.userId,
      email: auth.email,
      role: auth.role,
      name: auth.name,
    );
    await _storage.saveUserRole(auth.role);
  }
}
