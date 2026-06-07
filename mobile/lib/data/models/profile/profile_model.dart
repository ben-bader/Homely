import '../../../domain/entities/profile/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.userId,
    required super.name,
    required super.email,
    super.phone,
    super.bio,
    super.address,
    super.avatarUrl,
    super.idDocumentUrl,
    super.verified,
    super.role,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId:
          (json['userId'] ?? json['id'] ?? json['user']?['id'])?.toString() ??
              '',
      name: (json['name'] ?? json['user']?['name'])?.toString() ?? '',
      email: (json['email'] ?? json['user']?['email'])?.toString() ?? '',
      phone: (json['phone'] ?? json['user']?['phone'])?.toString(),
      bio: (json['bio'] ?? json['user']?['bio'])?.toString(),
      address: (json['address'] ?? json['user']?['address'])?.toString(),
      avatarUrl:
          (json['avatarUrl'] ??
                  json['avtarUrl'] ??
                  json['user']?['avatarUrl'] ??
                  json['user']?['avatar'])
              ?.toString(),
      idDocumentUrl:
          (json['idDocumentUrl'] ?? json['user']?['idDocumentUrl'])?.toString(),
      verified:
          (json['verified'] ?? json['user']?['verified']) as bool? ?? false,
      role: _extractRole(json),
    );
  }

  /// Extracts the role string from a profile JSON map.
  ///
  /// The backend may send the role in any of these shapes:
  ///   • plain string   – `"role": "ROLE_SELLER"`
  ///   • top-level list – `"roles": ["ROLE_SELLER"]`  (Spring Security)
  ///   • authority objs – `"authorities": [{"authority":"ROLE_SELLER"}]`
  ///   • nested in user – `"user": { "role": "SELLER" }`
  static String? _extractRole(Map<String, dynamic> j) {
    // 1. Plain string or list at top level under "role" / "userRole"
    for (final key in ['role', 'userRole']) {
      final v = j[key];
      if (v is String && v.isNotEmpty) return v;
      if (v is List && v.isNotEmpty) {
        final first = v.first?.toString() ?? '';
        if (first.isNotEmpty) return first;
      }
    }
    // 2. List under "roles" / "authorities"
    for (final key in ['roles', 'authorities']) {
      final list = j[key];
      if (list is List && list.isNotEmpty) {
        final first = list.first;
        // Spring Security wraps each entry as {"authority": "ROLE_SELLER"}
        if (first is Map) {
          final authority = (first['authority'] ?? first['role'])?.toString();
          if (authority != null && authority.isNotEmpty) return authority;
        }
        final str = first?.toString() ?? '';
        if (str.isNotEmpty) return str;
      }
    }
    // 3. Nested under "user"
    final user = j['user'];
    if (user is Map<String, dynamic>) return _extractRole(user);
    return null;
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'name': name,
    'email': email,
    if (phone != null) 'phone': phone,
    if (bio != null) 'bio': bio,
    if (address != null) 'address': address,
    if (avatarUrl != null) 'avatarUrl': avatarUrl,
    if (idDocumentUrl != null) 'idDocumentUrl': idDocumentUrl,
    if (role != null) 'role': role,
    'verified': verified,
  };
}
