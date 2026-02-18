import 'package:mobile/core/storage/secure_storage.dart';
import 'package:mobile/core/network/api_client.dart';


// ─────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
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
      name: json['name'] ??
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
  Future<void> logout() async {
    await _storage.clearAll();
  }

  /// CHECK IF USER IS LOGGED IN
  Future<bool> isLoggedIn() async {
    return await _storage.hasToken();
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
}
