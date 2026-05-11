import 'package:homely/core/network/api_client.dart';

abstract class ProfileRemoteDatasource {
  Future<Map<String, dynamic>> getProfile();
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data);
  Future<Map<String, dynamic>> uploadAvatar(String filePath);
  Future<Map<String, dynamic>> getMyProfile();
  Future<Map<String, dynamic>> updateProfileFields(Map<String, dynamic> body);
  Future<void> updateUserFields(String userId, Map<String, dynamic> body);
}

class ProfileRemoteDatasourceImpl implements ProfileRemoteDatasource {
  @override
  Future<Map<String, dynamic>> getProfile() async {
    final response = await ApiClient.get('/profile');
    return response;
  }

  @override
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await ApiClient.put('/profile', body: data);
    return response;
  }

  @override
  Future<Map<String, dynamic>> uploadAvatar(String filePath) async {
    final response = await ApiClient.post('/profile/avatar', body: {});
    return response;
  }

  @override
  Future<Map<String, dynamic>> getMyProfile() async {
    return await getProfile();
  }

  @override
  Future<Map<String, dynamic>> updateProfileFields(
    Map<String, dynamic> body,
  ) async {
    return await updateProfile(body);
  }

  @override
  Future<void> updateUserFields(
    String userId,
    Map<String, dynamic> body,
  ) async {
    await ApiClient.put('/user/$userId', body: body);
  }
}
