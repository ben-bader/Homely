import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/remote/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/profile/profile_entity.dart';
import '../../domain/repositories/i_profile_repository.dart';

final profileRemoteDatasourceProvider = Provider<ProfileRemoteDatasource>(
  (ref) => ProfileRemoteDatasourceImpl(),
);

final localAvatarPathProvider =
    AsyncNotifierProvider.family<LocalAvatarPathNotifier, String?, String>(
      LocalAvatarPathNotifier.new,
    );

class LocalAvatarPathNotifier extends FamilyAsyncNotifier<String?, String> {
  static String _prefsKey(String userId) => 'local_profile_avatar_$userId';

  @override
  Future<String?> build(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefsKey(userId));
  }

  Future<void> setPath(String userId, String? localPath) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prefs = await SharedPreferences.getInstance();
      if (localPath == null || localPath.isEmpty) {
        await prefs.remove(_prefsKey(userId));
        return null;
      }

      // Save a temporary local preview while upload proceeds.
      await prefs.setString(_prefsKey(userId), localPath);

      try {
        final datasource = ref.read(profileRemoteDatasourceProvider);
        final response = await datasource.uploadAvatar(localPath);
        debugPrint('Avatar upload response: $response');
        final newAvatarUrl = response['avatarUrl'] as String?;

        if (newAvatarUrl != null && newAvatarUrl.isNotEmpty) {
          // Clear the local preview path after successful upload so the
          // app displays the backend-backed Cloudinary URL instead.
          await prefs.remove(_prefsKey(userId));
          ref.invalidate(profileNotifierProvider);
          return null;
        }
      } catch (e, stackTrace) {
        debugPrint('Avatar upload failed: $e\n$stackTrace');
        // Keep local preview if upload failed, but don't hide the error.
      }

      return localPath;
    });
  }

  Future<void> clearPath(String userId) async {
    await setPath(userId, null);
  }
}

final profileRepositoryProvider = Provider<IProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.read(profileRemoteDatasourceProvider));
});

final profileNotifierProvider =
    AsyncNotifierProvider<ProfileNotifier, ProfileEntity>(ProfileNotifier.new);

final currentProfileProvider = Provider<ProfileEntity?>((ref) {
  return ref.watch(profileNotifierProvider).valueOrNull;
});

class ProfileNotifier extends AsyncNotifier<ProfileEntity> {
  @override
  Future<ProfileEntity> build() =>
      ref.read(profileRepositoryProvider).getMyProfile();

  Future<void> saveProfile(ProfileUpdateRequest request) async {
    final previous = state;
    final current = state.valueOrNull;
    if (current == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(profileRepositoryProvider);
      final updatedProfile = await repo.updateProfileFields(
        request.toProfileJson(),
      );
      try {
        await repo.updateUserFields(current.userId, request.toUserJson());
      } catch (_) {}
      return updatedProfile.copyWith(name: request.name, phone: request.phone);
    });

    if (state.hasError) state = previous;
  }
}
