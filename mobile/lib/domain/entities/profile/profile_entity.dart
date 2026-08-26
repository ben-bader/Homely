class ProfileEntity {
  final String userId;
  final String name;
  final String email;
  final String? phone;
  final String? bio;
  final String? address;
  final String? avatarUrl;
  final String? idDocumentUrl;
  final bool verified;
  final String? role;

  const ProfileEntity({
    required this.userId,
    required this.name,
    required this.email,
    this.phone,
    this.bio,
    this.address,
    this.avatarUrl,
    this.idDocumentUrl,
    this.verified = false,
    this.role,
  });

  String get firstName {
    final parts = name.trim().split(' ');
    return parts.first;
  }

  String get lastName {
    final parts = name.trim().split(' ');
    return parts.length > 1 ? parts.sublist(1).join(' ') : '';
  }

  ProfileEntity copyWith({
    String? name,
    String? email,
    String? phone,
    String? bio,
    String? address,
    String? avatarUrl,
    String? idDocumentUrl,
    bool? verified,
    String? role,
  }) => ProfileEntity(
    userId: userId,
    name: name ?? this.name,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    bio: bio ?? this.bio,
    address: address ?? this.address,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    idDocumentUrl: idDocumentUrl ?? this.idDocumentUrl,
    verified: verified ?? this.verified,
    role: role ?? this.role,
  );
}

class ProfileUpdateRequest {
  final String name;
  final String? phone;
  final String? bio;
  final String? address;
  // Fields the form does not edit — preserved from the current profile
  // so the backend does not null them out on a partial update.
  final String? avatarUrl;
  final String? email;
  final String? role;
  final bool? verified;

  const ProfileUpdateRequest({
    required this.name,
    this.phone,
    this.bio,
    this.address,
    this.avatarUrl,
    this.email,
    this.role,
    this.verified,
  });

  Map<String, dynamic> toProfileJson() => {
    if (bio != null) 'bio': bio,
    if (address != null) 'address': address,
    if (avatarUrl != null) 'avatarUrl': avatarUrl,
  };

  Map<String, dynamic> toUserJson() => {
    'name': name,
    if (phone != null) 'phone': phone,
  };
}
