import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart' as auth_providers;

/// Simple ownership helper used across the app.
class ProfileOwnershipHelper {
  static bool isOwnProfile(String? authenticatedUserId, String? viewedUserId) {
    if (authenticatedUserId == null || viewedUserId == null) return false;
    return authenticatedUserId == viewedUserId;
  }
}

/// Riverpod provider (family) that resolves whether the current authenticated
/// user owns the given `viewedUserId` profile.
final isOwnProfileProvider = FutureProvider.family<bool, String?>((ref, viewedUserId) async {
  final authId = await ref.watch(auth_providers.currentUserIdProvider.future);
  return ProfileOwnershipHelper.isOwnProfile(authId, viewedUserId);
});
