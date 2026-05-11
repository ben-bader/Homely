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
  }) =>
      ProfileEntity(
        userId: userId,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        bio: bio ?? this.bio,
        address: address ?? this.address,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        idDocumentUrl: idDocumentUrl ?? this.idDocumentUrl,
        verified: verified ?? this.verified,
      );
}

class ProfileUpdateRequest {
  final String name;
  final String? phone;
  final String? bio;
  final String? address;
  final String? avatarUrl;

  const ProfileUpdateRequest({
    required this.name,
    this.phone,
    this.bio,
    this.address,
    this.avatarUrl,
  });

  Map<String, dynamic> toProfileJson() => {
        if (bio != null) 'bio': bio,
        if (address != null) 'address': address,
        if (avatarUrl != null) 'avtarUrl': avatarUrl,
      };

  Map<String, dynamic> toUserJson() => {
        'name': name,
        if (phone != null) 'phone': phone,
      };
}
