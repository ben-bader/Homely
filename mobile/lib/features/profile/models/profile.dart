class Profile {
  final String userId;
  final String name;
  final String email;
  final String? phone;
  final String? bio;
  final String? address;
  final String? avatarUrl;
  final String? idDocumentUrl;
  final bool verified;

  const Profile({
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

  /// Derived getters – split name on first space
  String get firstName {
    final parts = name.trim().split(' ');
    return parts.first;
  }

  String get lastName {
    final parts = name.trim().split(' ');
    return parts.length > 1 ? parts.sublist(1).join(' ') : '';
  }

  /// NOTE: Backend ProfileDto currently only returns:
  ///   userId, bio, address, verified, avtarUrl, idDocumentUrl
  ///
  /// name / email / phone come from UserDto (separate entity).
  /// You MUST extend your backend ProfileDto to include these fields,
  /// OR merge both DTOs in ProfileController.getMyProfile().
  ///
  /// Until then, name and email will fall back to empty strings and
  /// phone will be null – no crash, but data will be missing.
  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    userId: json['userId']?.toString() ?? '',
    name: json['name']?.toString() ?? '', // requires backend fix
    email: json['email']?.toString() ?? '', // requires backend fix
    phone: json['phone']?.toString(), // requires backend fix
    bio: json['bio']?.toString(),
    address: json['address']?.toString(),
    avatarUrl: json['avtarUrl']?.toString(), // backend typo: "avtarUrl"
    idDocumentUrl: json['idDocumentUrl']?.toString(),
    verified: json['verified'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'name': name,
    'email': email,
    if (phone != null) 'phone': phone,
    if (bio != null) 'bio': bio,
    if (address != null) 'address': address,
    if (avatarUrl != null) 'avtarUrl': avatarUrl,
    if (idDocumentUrl != null) 'idDocumentUrl': idDocumentUrl,
    'verified': verified,
  };

  Profile copyWith({
    String? name,
    String? email,
    String? phone,
    String? bio,
    String? address,
    String? avatarUrl,
    String? idDocumentUrl,
    bool? verified,
  }) => Profile(
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

/// Sent to two backend endpoints on save:
///   PUT /api/profile/me  → toProfileJson()  (bio, address, avtarUrl)
///   PUT /api/users/{id}  → toUserJson()     (name, phone)
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
