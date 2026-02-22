import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/features/profile/models/profile.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

final profileNotifierProvider = AsyncNotifierProvider<ProfileNotifier, Profile>(
  ProfileNotifier.new,
);

class ProfileRepository {
  Future<Profile> getMyProfile() async {
    final data = await ApiClient.get('/api/profile/me');
    return Profile.fromJson(data as Map<String, dynamic>);
  }

  Future<Profile> updateProfileFields(ProfileUpdateRequest request) async {
    final data = await ApiClient.put(
      '/api/profile/me',
      body: request.toProfileJson(),
    );
    return Profile.fromJson(data as Map<String, dynamic>);
  }

  Future<void> updateUserFields(
    String userId,
    ProfileUpdateRequest request,
  ) async {
    await ApiClient.put('/api/users/$userId', body: request.toUserJson());
  }
}

class ProfileNotifier extends AsyncNotifier<Profile> {
  @override
  Future<Profile> build() => ref.read(profileRepositoryProvider).getMyProfile();

  Future<void> saveProfile(ProfileUpdateRequest request) async {
    final previous = state;
    final current = state.valueOrNull;

    if (current == null) return;

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repo = ref.read(profileRepositoryProvider);

      final updatedProfile = await repo.updateProfileFields(request);

      try {
        await repo.updateUserFields(current.userId, request);
      } catch (_) {
      }
      return updatedProfile.copyWith(name: request.name, phone: request.phone);
    });
    
       if (state.hasError) {
      state = previous;
    }
  }
}
