import '../../domain/entities/profile/profile_entity.dart';
import '../../domain/repositories/i_profile_repository.dart';
import '../datasources/remote/profile_remote_datasource.dart';
import '../models/profile/profile_model.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  final ProfileRemoteDatasource _remote;

  ProfileRepositoryImpl(this._remote);

  @override
  Future<ProfileEntity> getMyProfile() async {
    final data = await _remote.getMyProfile();
    return ProfileModel.fromJson(data);
  }

  @override
  Future<ProfileEntity> getProfileById(String userId) async {
    final data = await _remote.getProfileById(userId);
    return ProfileModel.fromJson(data);
  }

  @override
  Future<ProfileEntity> updateProfileFields(Map<String, dynamic> body) async {
    final data = await _remote.updateProfileFields(body);
    return ProfileModel.fromJson(data);
  }

  @override
  Future<void> updateUserFields(String userId, Map<String, dynamic> body) =>
      _remote.updateUserFields(userId, body);

  @override
  Future<String?> uploadAvatar(String filePath) async {
    final response = await _remote.uploadAvatar(filePath);
    return response['avatarUrl'] as String?;
  }
}
