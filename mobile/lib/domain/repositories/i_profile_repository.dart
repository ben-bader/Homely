import '../entities/profile/profile_entity.dart';

abstract class IProfileRepository {
  Future<ProfileEntity> getMyProfile();
  Future<ProfileEntity> updateProfileFields(Map<String, dynamic> body);
  Future<void> updateUserFields(String userId, Map<String, dynamic> body);
  Future<String?> uploadAvatar(String filePath);
}
