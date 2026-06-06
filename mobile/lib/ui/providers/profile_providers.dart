import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/remote/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/profile/profile_entity.dart';
import '../../domain/repositories/i_profile_repository.dart';
import '../../domain/entities/property/property_entity.dart';
import '../providers/property_providers.dart';
import '../providers/visit_request_providers.dart';

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

final profileByIdProvider = FutureProvider.family<ProfileEntity, String>(
  (ref, userId) async {
    return ref.read(profileRepositoryProvider).getProfileById(userId);
  },
);

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

// ─────────────────────────────────────────────────────────────────────────────
// PROFILE STATS — shared entity (used by both screens)
// ─────────────────────────────────────────────────────────────────────────────

class ProfileStats {
  // Seller stats
  final int? listingCount;
  final int? toursCount;
  final int? followersCount;
  final double? rating;

  // Client stats
  final int? favoritesCount;
  final int? propertyVisitsCount;
  final int? scheduledToursCount;
  final int? reviewsCount;
  final int? savedSearchesCount;

  // Visit metrics (seller)
  final int? totalVisitRequests;
  final int? uniqueVisitRequesters;

  const ProfileStats({
    this.listingCount,
    this.toursCount,
    this.followersCount,
    this.rating,
    this.favoritesCount,
    this.propertyVisitsCount,
    this.scheduledToursCount,
    this.reviewsCount,
    this.savedSearchesCount,
    this.totalVisitRequests,
    this.uniqueVisitRequesters,
  });

  factory ProfileStats.empty() => const ProfileStats(
        listingCount: 0,
        toursCount: 0,
        followersCount: 0,
        rating: 0,
        favoritesCount: 0,
        propertyVisitsCount: 0,
        scheduledToursCount: 0,
        reviewsCount: 0,
        savedSearchesCount: 0,
        totalVisitRequests: 0,
        uniqueVisitRequesters: 0,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// USER ROLE ENUM
// ─────────────────────────────────────────────────────────────────────────────

enum UserRole { seller, client }

UserRole normalizeRole(String? role) {
  if (role == null) return UserRole.client;
  final normalized = role.toUpperCase().replaceAll('ROLE_', '');
  return normalized == 'SELLER' ? UserRole.seller : UserRole.client;
}

// ─────────────────────────────────────────────────────────────────────────────
// sellerListingsByUserIdProvider
// Fetches listings for any seller by their userId.
// Used only by UserProfileScreen — never call sellerListingsProvider here.
// Not autoDispose so the data persists while the profile screen is in the stack.
// ─────────────────────────────────────────────────────────────────────────────

final sellerListingsByUserIdProvider =
    FutureProvider.family<List<PropertyEntity>, String>((ref, userId) async {
  return ref.read(propertyRepositoryProvider).getByUserId(userId);
});

// ─────────────────────────────────────────────────────────────────────────────
// profileStatsByUserIdProvider
// Fetches stats for any userId. Used only by UserProfileScreen header.
// Role is derived from the fetched profile entity, NOT from auth state.
// Not autoDispose — same reason as above.
// ─────────────────────────────────────────────────────────────────────────────

final profileStatsByUserIdProvider =
    FutureProvider.family<ProfileStats, String>((ref, userId) async {
  final profile =
      await ref.read(profileRepositoryProvider).getProfileById(userId);
  final role = normalizeRole(profile.role);

  if (role == UserRole.seller) {
    final listings =
        await ref.watch(sellerListingsByUserIdProvider(userId).future);
    final visitRepo = ref.read(visitRequestRepositoryProvider);
    int totalRequests = 0;
    for (final p in listings) {
      try {
        final requests = await visitRepo.getRequestsForProperty(p.id);
        totalRequests += requests.length;
      } catch (_) {}
    }
    return ProfileStats(
      listingCount: listings.length,
      // Visits column reads totalVisitRequests; Tours defaults to 0 until wired.
      totalVisitRequests: totalRequests,
      toursCount: 0,
      followersCount: 0,
      rating: 0,
    );
  }

  // Client — no public stats API yet.
  return ProfileStats(
    favoritesCount: 0,
    propertyVisitsCount: 0,
    scheduledToursCount: 0,
  );
});
