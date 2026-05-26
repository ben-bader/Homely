import 'package:homely/core/network/api_client.dart';
import 'package:homely/core/network/endpoints.dart';
import 'package:flutter/foundation.dart';

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
    // Backend exposes only /profile/me for current user profile.
    final res = await ApiClient.get(Endpoints.getProfileMe);
    if (res is Map<String, dynamic> && res.isNotEmpty) {
      return res;
    }
    throw Exception('Profile not found');
  }

  @override
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await ApiClient.put(
        Endpoints.updateProfileMe,
        body: data,
      );
      return response as Map<String, dynamic>? ?? <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  @override
  Future<Map<String, dynamic>> uploadAvatar(String filePath) async {
    try {
      final response = await ApiClient.postMultipart(
        Endpoints.uploadProfilePicture,
        filePath: filePath,
        fieldName: 'file',
      );
      return response as Map<String, dynamic>? ?? <String, dynamic>{};
    } catch (e) {
      debugPrint('Upload avatar error: $e');
      return <String, dynamic>{};
    }
  }

  @override
  Future<Map<String, dynamic>> getMyProfile() async {
    return await getProfile();
  }

  @override
  Future<Map<String, dynamic>> updateProfileFields(
    Map<String, dynamic> body,
  ) async {
    try {
      return await updateProfile(body);
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  @override
  Future<void> updateUserFields(
    String userId,
    Map<String, dynamic> body,
  ) async {
    try {
      await ApiClient.put(Endpoints.userById(userId), body: body);
    } catch (_) {
      // ignore
    }
  }
}
