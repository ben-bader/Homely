class Profile {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? bio;
  final String? avatarUrl;
  final String? city;
  final String? country;

  const Profile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.bio,
    this.avatarUrl,
    this.city,
    this.country,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json['id']?.toString() ?? '',
        firstName: json['firstName'] ?? '',
        lastName: json['lastName'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'],
        bio: json['bio'],
        avatarUrl: json['avatarUrl'],
        city: json['city'],
        country: json['country'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        if (phone != null) 'phone': phone,
        if (bio != null) 'bio': bio,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (city != null) 'city': city,
        if (country != null) 'country': country,
      };

  Profile copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? bio,
    String? avatarUrl,
    String? city,
    String? country,
  }) =>
      Profile(
        id: id,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        bio: bio ?? this.bio,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        city: city ?? this.city,
        country: country ?? this.country,
      );
}

class ProfileUpdateRequest {
  final String firstName;
  final String lastName;
  final String? phone;
  final String? bio;
  final String? city;
  final String? country;

  const ProfileUpdateRequest({
    required this.firstName,
    required this.lastName,
    this.phone,
    this.bio,
    this.city,
    this.country,
  });

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        if (phone != null) 'phone': phone,
        if (bio != null) 'bio': bio,
        if (city != null) 'city': city,
        if (country != null) 'country': country,
      };
}