import '../../../domain/entities/auth/auth_entity.dart';

class AuthResponseModel extends AuthEntity {
  const AuthResponseModel({
    required super.token,
    required super.refreshToken,
    required super.userId,
    required super.email,
    required super.name,
    required super.role,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final token = json['accessToken']?.toString() ?? '';
    final refreshToken = json['refreshToken']?.toString() ?? '';
    final username = json['username']?.toString() ?? '';
    final rolesRaw = json['roles'] as List<dynamic>? ?? [];
    final roles = rolesRaw.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
    final role = roles.isNotEmpty ? _normalizeRole(roles.first) : 'CLIENT';

    // We intentionally do NOT populate email/userId/name from auth response.
    return AuthResponseModel(
      token: token,
      refreshToken: refreshToken,
      userId: '',
      email: '',
      name: username,
      role: role,
    );
  }

  static String _normalizeRole(String? role) {
    if (role == null) return 'CLIENT';
    String r = role.toUpperCase();
    if (r.startsWith('ROLE_')) r = r.substring(5);
    if (r.contains('SELLER')) return 'SELLER';
    if (r.contains('ADMIN')) return 'ADMIN';
    return 'CLIENT';
  }
}
