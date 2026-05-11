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
        userId: json['userId']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        phone: json['phone']?.toString(),
        bio: json['bio']?.toString(),
        address: json['address']?.toString(),
        avatarUrl: json['avtarUrl']?.toString(),
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
}
