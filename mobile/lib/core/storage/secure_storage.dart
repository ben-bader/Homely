import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 🔒 Secure Storage Service
/// Handles secure storage of sensitive data like JWT tokens
class SecureStorage {
  final FlutterSecureStorage _storage;

  // Storage keys
  static const String _keyToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserRole = 'user_role';
  static const String _keyUserName = 'user_name';

  SecureStorage({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  // ==================== TOKEN MANAGEMENT ====================

  /// Save authentication token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  /// Get authentication token
  Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  /// Delete authentication token
  Future<void> deleteToken() async {
    await _storage.delete(key: _keyToken);
  }

  /// Check if token exists
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ==================== REFRESH TOKEN MANAGEMENT ====================

  /// Save refresh token
  Future<void> saveRefreshToken(String refreshToken) async {
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  /// Delete refresh token
  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _keyRefreshToken);
  }

  // ==================== USER DATA MANAGEMENT ====================

  /// Save user ID
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _keyUserId, value: userId);
  }

  /// Get user ID
  Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  /// Save user email
  Future<void> saveUserEmail(String email) async {
    await _storage.write(key: _keyUserEmail, value: email);
  }

  /// Get user email
  Future<String?> getUserEmail() async {
    return await _storage.read(key: _keyUserEmail);
  }

  /// Save user role
  Future<void> saveUserRole(String role) async {
    await _storage.write(key: _keyUserRole, value: role);
  }

  /// Get user role
  Future<String?> getUserRole() async {
    return await _storage.read(key: _keyUserRole);
  }

  /// Save user name
  Future<void> saveUserName(String name) async {
    await _storage.write(key: _keyUserName, value: name);
  }

  /// Get user name
  Future<String?> getUserName() async {
    return await _storage.read(key: _keyUserName);
  }

  // ==================== SAVE ALL USER DATA ====================

  /// Save all user data at once
  Future<void> saveUserData({
    required String token,
    String? refreshToken,
    required String userId,
    required String email,
    required String role,
    required String name,
  }) async {
    await Future.wait([
      saveToken(token),
      if (refreshToken != null) saveRefreshToken(refreshToken),
      saveUserId(userId),
      saveUserEmail(email),
      saveUserRole(role),
      saveUserName(name),
    ]);
  }

  // ==================== CLEAR ALL DATA ====================

  /// Clear all stored data (logout)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // ==================== CUSTOM KEY-VALUE STORAGE ====================

  /// Write custom value
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Read custom value
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  /// Delete custom value
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  /// Check if key exists
  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }
}
