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
import '../providers/auth_providers.dart' as auth_prov;

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
  Future<ProfileEntity> build() async {
    ProfileEntity profile =
        await ref.read(profileRepositoryProvider).getMyProfile();

    // ── Role fallback ────────────────────────────────────────────────────────
    // If /profile/me did not include a role field (null or empty), fall back
    // to the role that was stored in secure storage during login.
    // This covers backends that return role only in the auth response, not in
    // the profile endpoint.
    if (profile.role == null || profile.role!.trim().isEmpty) {
      try {
        final storedRole =
            await ref.read(auth_prov.authRepositoryProvider).getUserRole();
        debugPrint(
          '>>> ProfileNotifier: profile.role was null/empty, '
          'falling back to stored role="$storedRole"',
        );
        if (storedRole.isNotEmpty) {
          profile = profile.copyWith(role: storedRole);
        }
      } catch (e) {
        debugPrint('>>> ProfileNotifier: role fallback failed: $e');
      }
    } else {
      debugPrint('>>> ProfileNotifier: raw profile.role="${profile.role}"');
    }

    return profile;
  }

  Future<void> saveProfile(ProfileUpdateRequest request) async {
    final previous = state;
    final current = state.valueOrNull;
    if (current == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(profileRepositoryProvider);
      final updated = await repo.updateProfileFields(
        request.toProfileJson(),
      );
      try {
        await repo.updateUserFields(current.userId, request.toUserJson());
      } catch (_) {}

      // Merge: the backend PUT response may omit fields the server did not
      // touch. Fall back to the pre-save value for every field that comes
      // back null or empty, so nothing is accidentally cleared.
      final merged = current.copyWith(
        // Editable fields — use form values, which are always intentional
        name: request.name.isNotEmpty ? request.name : null,
        phone: request.phone ?? updated.phone,
        bio: request.bio ?? updated.bio,
        address: request.address ?? updated.address,
        // Non-editable fields — keep whatever the update response returned,
        // falling back to what we had before if the response omitted them.
        avatarUrl: updated.avatarUrl ?? current.avatarUrl,
        role: updated.role ?? current.role,
        // email and verified are read-only — never overwrite from the form.
        // (copyWith with no email/verified param keeps existing values.)
      );
      return merged;
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
  if (role == null || role.trim().isEmpty) return UserRole.client;
  // Strip optional "ROLE_" prefix and normalise case
  final s = role.trim().toUpperCase().replaceAll('ROLE_', '');
  // Match every seller-equivalent value the backend might send
  const sellerValues = {'SELLER', 'VENDOR', 'AGENT', 'OWNER', 'HOST'};
  return sellerValues.contains(s) ? UserRole.seller : UserRole.client;
}

// ─────────────────────────────────────────────────────────────────────────────
// sellerListingsByUserIdProvider
// Fetches listings for any seller by their userId.
// Used only by UserProfileScreen — never call sellerListingsProvider here.
// autoDispose keeps memory clean once the screen is popped.
// ─────────────────────────────────────────────────────────────────────────────

final sellerListingsByUserIdProvider =
    FutureProvider.autoDispose.family<List<PropertyEntity>, String>((
  ref,
  userId,
) async {
  try {
    debugPrint('>>> sellerListingsByUserId: fetching for userId=$userId');
    final repo = ref.read(propertyRepositoryProvider);
    final result = await repo.getByUserId(userId);
    debugPrint(
        '>>> sellerListingsByUserId: result count=${result.length}');
    return result;
  } catch (e, st) {
    debugPrint('>>> sellerListingsByUserId ERROR: $e\n$st');
    rethrow;
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// profileStatsByUserIdProvider
// Fetches stats for any userId. Used only by UserProfileScreen header.
// Accepts a plain String userId — the same param the call site already passes.
//
// Role-detection strategy (in order of reliability):
//   1. Use the role field from /users/{userId} if present.
//   2. If absent (public endpoint omits role), fetch listings:
//      – listings.length > 0  → treat as seller
//      – listings.length == 0 → cannot determine (show empty stats)
// autoDispose — same reason as above.
// ─────────────────────────────────────────────────────────────────────────────

final profileStatsByUserIdProvider =
    FutureProvider.autoDispose.family<ProfileStats, String>((
  ref,
  userId,
) async {
  debugPrint('>>> profileStatsByUserId: userId=$userId');

  // ── Step 1: fetch the profile to get the role ──────────────────────────────
  ProfileEntity? profile;
  try {
    profile = await ref.read(profileRepositoryProvider).getProfileById(userId);
    debugPrint(
        '>>> profileStatsByUserId: raw role="${profile.role}"');
  } catch (e) {
    debugPrint('>>> profileStatsByUserId: profile fetch failed: $e');
  }

  UserRole role = normalizeRole(profile?.role);
  debugPrint('>>> profileStatsByUserId: normalized role=$role');

  // ── Step 2: always fetch listings (needed for stats + role fallback) ───────
  List<PropertyEntity> listings = [];
  try {
    listings = await ref.read(sellerListingsByUserIdProvider(userId).future);
  } catch (e) {
    debugPrint('>>> profileStatsByUserId: listings fetch failed: $e');
  }

  // ── Step 3: if the profile endpoint omitted role, infer from listings ──────
  // /users/{userId} is a public endpoint that may not include role.
  // If we got listings back, the user is definitely a seller.
  if (role == UserRole.client && listings.isNotEmpty) {
    debugPrint(
        '>>> profileStatsByUserId: role was client but listings=${listings.length}, inferring seller');
    role = UserRole.seller;
  }

  if (role == UserRole.seller) {
    final visitRepo = ref.read(visitRequestRepositoryProvider);
    int totalRequests = 0;
    final uniqueUsers = <String>{};
    for (final p in listings) {
      try {
        final requests = await visitRepo.getRequestsForProperty(p.id);
        totalRequests += requests.length;
        for (final r in requests) {
          if (r.userId != null && r.userId!.isNotEmpty) {
            uniqueUsers.add(r.userId!);
          }
        }
      } catch (_) {}
    }
    return ProfileStats(
      listingCount: listings.length,
      totalVisitRequests: totalRequests,
      uniqueVisitRequesters: uniqueUsers.length,
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
