import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/core/network/auth_api.dart';

import 'package:mobile/features/auth/models/auth_response.dart';
import 'package:mobile/features/auth/models/login_request.dart';
import 'package:mobile/features/auth/models/register_request.dart';
import 'package:mobile/core/storage/secure_storage.dart';

class AuthService {
  final AuthApi _api = AuthApi();
  final SecureStorage _storage = SecureStorage();

  // ─────────────────────────────────────────
  // LOGIN
  // ─────────────────────────────────────────

  Future<AuthResponse> login(LoginRequest request) async {
    final data = await _api.login(
      email: request.email,
      password: request.password,
    );

    final auth = AuthResponse.fromJson(data);
    await _saveSession(auth);

    return auth;
  }

  // ─────────────────────────────────────────
  // REGISTER
  // ─────────────────────────────────────────

  Future<AuthResponse> register(RegisterRequest request) async {
    final data = await _api.register(
      name: request.name,
      email: request.email,
      password: request.password,
      phone: request.phone,
      role: request.role,
    );

    final auth = AuthResponse.fromJson(data);
    await _saveSession(auth);

    return auth;
  }

  // ─────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────

  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (_) {}

    await _storage.deleteToken();
    await _storage.clearAll();
  }

  // ─────────────────────────────────────────
  // PASSWORD + AUTH HELPERS
  // ─────────────────────────────────────────

  Future forgotPassword(String email) async {
    return await _api.forgotPassword(email: email);
  }

  Future resetPassword(String token, String newPassword) async {
    return await _api.resetPassword(token: token, newPassword: newPassword);
  }

  Future verifyEmail(String token) async {
    return await _api.verifyEmail(token: token);
  }

  Future resendVerification(String email) async {
    return await _api.resendVerification(email: email);
  }

  Future refreshToken(String refreshToken) async {
    return await _api.refreshToken(refreshToken: refreshToken);
  }

  // ─────────────────────────────────────────
  // SESSION STORAGE
  // ─────────────────────────────────────────

  Future<void> _saveSession(AuthResponse r) async {
    await _storage.saveUserData(
      token: r.token,
      userId: r.userId,
      email: r.email,
      role: r.role,
      name: r.name,
    );

    await _storage.saveUserRole(r.role);

    debugPrint("Session saved → ${r.role}");
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.getToken();
    return token != null;
  }

  Future<String> getUserRole() async {
    final role = await _storage.getUserRole();
    return role ?? "CLIENT";
  }

  Future<AuthResponse?> getCurrentSession() async {
    final token = await _storage.getToken();
    if (token == null) return null;

    final email = await _storage.getUserEmail();
    final name = await _storage.getUserName();
    final role = await _storage.getUserRole();
    final userId = await _storage.getUserId();

    return AuthResponse(
      token: token,
      userId: userId ?? "",
      email: email ?? "",
      role: role ?? "CLIENT",
      name: name ?? "",
    );
  }

  Future<String?> getToken() async {
    return await _storage.getToken();
  }

  Future<String?> getCurrentUserId() async {
    final userId = await _storage.getUserId();
    if (userId != null) return userId;

    final token = await _storage.getToken();
    if (token == null) return null;

    return _extractUserIdFromToken(token);
  }

  String? _extractUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);

      final decoded = utf8.decode(base64Url.decode(normalized));
      final map = jsonDecode(decoded);

      return map['sub'] ?? map['userId'] ?? map['id'];
    } catch (_) {
      return null;
    }
  }

  Future<String> getUserRoleFromStorage() async {
    final role = await _storage.getUserRole();

    if (role != null && role.isNotEmpty) return role;

    final token = await _storage.getToken();
    if (token != null) {
      final decodedRole = _extractRoleFromToken(token);

      if (decodedRole != null) {
        await _storage.saveUserRole(decodedRole);
        return decodedRole;
      }
    }

    return "CLIENT";
  }

  String? _extractRoleFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);

      final decoded = utf8.decode(base64Url.decode(normalized));
      final map = jsonDecode(decoded);

      String? role = map['role']?.toString();

      if (role == null) return null;

      role = role.toUpperCase();

      if (role.startsWith("ROLE_")) {
        role = role.substring(5);
      }

      if (role.contains("SELLER")) return "SELLER";
      if (role.contains("ADMIN")) return "ADMIN";
      if (role.contains("CLIENT") || role.contains("USER")) {
        return "CLIENT";
      }

      return role;
    } catch (_) {
      return null;
    }
  }
}
