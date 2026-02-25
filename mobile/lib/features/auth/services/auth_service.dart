import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/core/storage/secure_storage.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String phone;
  final String role; // CLIENT | SELLER

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
    'phone': phone,
    'role': role,
  };
}

class AuthResponse {
  final String token;
  final String userId;
  final String name;
  final String email;
  final String role;

  AuthResponse({
    required this.token,
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
  });

  String get firstName => name.split(' ').first;

  String get lastName =>
      name.split(' ').length > 1 ? name.split(' ').sublist(1).join(' ') : '';

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? json['accessToken'] ?? '',
      userId: (json['id'] ?? json['userId'] ?? '').toString(),
      name:
          json['name'] ??
          '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim(),
      email: json['email'] ?? '',
      role: json['role'] ?? 'CLIENT',
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Service
// ─────────────────────────────────────────────────────────────

class AuthService {
  final SecureStorage _storage = SecureStorage();

  /// LOGIN
  Future<AuthResponse> login(LoginRequest request) async {
    final data = await ApiClient.post(
      '/api/auth/login', // ✅ Correct endpoint
      body: request.toJson(),
      auth: false,
    );

    final response = AuthResponse.fromJson(data);

    await _saveSession(response);

    return response;
  }

  /// REGISTER
  Future<AuthResponse> register(RegisterRequest request) async {
    final data = await ApiClient.post(
      '/api/auth/register', // ✅ Correct endpoint
      body: request.toJson(),
      auth: false,
    );

    final response = AuthResponse.fromJson(data);

    await _saveSession(response);

    return response;
  }

  /// LOGOUT
  Future<void> _logout(BuildContext context) async {
    try {
      await ApiClient.post('/api/auth/logout');

      // Remove stored token
      await _storage.deleteToken();

      if (!context.mounted) return;

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Logout failed")));
    }
  }

  /// CHECK IF USER IS LOGGED IN
  Future<bool> isLoggedIn() async {
    final userId = await getCurrentUserId();
    return userId != null;
  }

  /// GET USER ROLE
  Future<String?> getUserRole() async {
    return await _storage.getUserRole();
  }

  /// SAVE SESSION
  Future<void> _saveSession(AuthResponse r) async {
    await _storage.saveUserData(
      token: r.token,
      userId: r.userId,
      email: r.email,
      role: r.role,
      name: r.name,
    );
  }

  /// GET TOKEN
  Future<String?> getToken() async {
    return await _storage.getToken();
  }

 Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // whatever key you store JWT under
    if (token == null) return null;
    return _extractUserIdFromToken(token);
  }

  String? _extractUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Decode the payload (middle part)
      final payload = parts[1];
      // Fix base64 padding
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final map = jsonDecode(decoded) as Map<String, dynamic>;

      // JWT claim is usually 'sub' or 'userId' or 'id'
      return map['sub'] as String?   // try 'sub' first
          ?? map['userId'] as String?
          ?? map['id'] as String?;
    } catch (e) {
      return null;
    }
  }

  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }
}
