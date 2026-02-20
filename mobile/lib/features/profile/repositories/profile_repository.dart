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
  /// GET /api/profile/me
  Future<Profile> getMyProfile() async {
    final data = await ApiClient.get('/api/profile/me');
    return Profile.fromJson(data as Map<String, dynamic>);
  }

  /// PUT /api/profile/me
  Future<Profile> updateMyProfile(ProfileUpdateRequest request) async {
    final data = await ApiClient.put('/api/profile/me', body: request.toJson());
    return Profile.fromJson(data as Map<String, dynamic>);
  }
}


class ProfileNotifier extends AsyncNotifier<Profile> {
  @override
  Future<Profile> build() => ref.read(profileRepositoryProvider).getMyProfile();

  Future<void> saveProfile(ProfileUpdateRequest request) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(profileRepositoryProvider).updateMyProfile(request),
    );
  }
}
