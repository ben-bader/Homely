import 'dart:convert';

class AuthResponse {
  final String token;
  final String userId;
  final String email;
  final String name;
  final String role;

  AuthResponse({
    required this.token,
    required this.userId,
    required this.email,
    required this.name,
    required this.role,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final token = json['token'] ?? '';

    final payload = _decodeJwt(token);

    final role = _normalizeRole(payload['role']?.toString());

    final name = payload['name']?.toString() ?? '';

    return AuthResponse(
      token: token,
      userId: payload['userId']?.toString() ??
          payload['sub']?.toString() ??
          '',
      email: payload['email']?.toString() ?? '',
      name: name,
      role: role,
    );
  }

  // ─────────────────────────────

  static Map<String, dynamic> _decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return {};

      final normalized = base64Url.normalize(parts[1]);

      final decoded = utf8.decode(base64Url.decode(normalized));

      return jsonDecode(decoded);
    } catch (_) {
      return {};
    }
  }

  static String _normalizeRole(String? role) {
    if (role == null) return "CLIENT";

    String r = role.toUpperCase();

    if (r.startsWith("ROLE_")) {
      r = r.substring(5);
    }

    if (r.contains("SELLER")) return "SELLER";
    if (r.contains("ADMIN")) return "ADMIN";

    return "CLIENT";
  }
}