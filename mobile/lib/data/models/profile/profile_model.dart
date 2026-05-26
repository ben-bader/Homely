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
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    userId:
        (json['userId'] ?? json['id'] ?? json['user']?['id'])?.toString() ?? '',
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
    idDocumentUrl: (json['idDocumentUrl'] ?? json['user']?['idDocumentUrl'])
        ?.toString(),
    verified: (json['verified'] ?? json['user']?['verified']) as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'name': name,
    'email': email,
    if (phone != null) 'phone': phone,
    if (bio != null) 'bio': bio,
    if (address != null) 'address': address,
    if (avatarUrl != null) 'avatarUrl': avatarUrl,
    if (idDocumentUrl != null) 'idDocumentUrl': idDocumentUrl,
    'verified': verified,
  };
}
