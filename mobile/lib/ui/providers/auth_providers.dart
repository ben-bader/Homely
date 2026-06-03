import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homely/ui/providers/media_providers.dart';
import 'package:homely/ui/providers/report_providers.dart';
import 'package:homely/ui/providers/seller_analytics_providers.dart';
import '../../data/datasources/local/secure_storage.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth/auth_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../providers/chat_providers.dart';
import '../providers/property_providers.dart';
import '../providers/favorite_providers.dart';
import '../providers/boost_providers.dart';
import '../providers/profile_providers.dart';
import '../providers/visit_request_providers.dart';
import '../providers/notification_providers.dart';
import '../../infrastructure/services/app_initializer.dart';
import '../../infrastructure/services/realtime_service.dart';
import '../../infrastructure/services/notification_service.dart';
import '../../infrastructure/services/chat_service.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>(
  (ref) => AuthRemoteDatasourceImpl(),
);

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.read(authRemoteDatasourceProvider),
    ref.read(secureStorageProvider),
  );
});

final authServiceProvider = Provider<IAuthRepository>((ref) {
  return ref.read(authRepositoryProvider);
});

/// Provider to manage logout and clear all user-specific state
/// Call ref.read(logoutNotifierProvider.notifier).logout() to properly logout
final logoutNotifierProvider = 
    StateNotifierProvider<LogoutNotifier, bool>((ref) {
  return LogoutNotifier(ref);
});

class LogoutNotifier extends StateNotifier<bool> {
  final Ref ref;
  LogoutNotifier(this.ref) : super(false);

  /// Performs complete logout with full state cleanup
  Future<void> logout() async {
    try {
      // 1. Disconnect real-time services
      RealtimeService().disconnect();
      NotificationService().disconnect();
      ChatService().disconnect();

      // 2. Clear AppInitializer state
      AppInitializer().reset();

      // 3. Invalidate all user-specific providers to clear caches
      _invalidateAllProviders();

      // 4. Perform auth logout (clears tokens)
      await ref.read(authRepositoryProvider).logout();

      state = true;
    } catch (e) {
      print('[LogoutNotifier] Logout error: $e');
      rethrow;
    }
  }

  /// Invalidates all user-specific providers to force fresh data on next login
  void _invalidateAllProviders() {
    // Auth providers
    ref.invalidate(userRoleProvider);
    ref.invalidate(isLoggedInProvider);
    ref.invalidate(currentUserIdProvider);
    ref.invalidate(currentSessionProvider);

    // Chat/Messaging providers
    ref.invalidate(conversationsProvider);
    ref.invalidate(chatEventStreamProvider);
    ref.invalidate(notificationStreamProvider);

    // Property providers
    ref.invalidate(propertiesProvider);
    ref.invalidate(propertyDetailProvider);
    ref.invalidate(sellerListingsProvider);
    ref.invalidate(featuredCountProvider);

    // User data providers
    ref.invalidate(favoritesProvider);
    ref.invalidate(myBoostsProvider);
    ref.invalidate(myVisitRequestsProvider);
    ref.invalidate(notificationsProvider);
    ref.invalidate(profileNotifierProvider);

    // Media providers
    ref.invalidate(propertyMediaProvider);
    ref.invalidate(propertyImagesProvider);
    ref.invalidate(propertyVideosProvider);

    // Analytics providers
    ref.invalidate(sellerAnalyticsProvider);
    ref.invalidate(sellerAnalyticsViewsOverTimeProvider);
    ref.invalidate(sellerAnalyticsMessagesOverTimeProvider);
    ref.invalidate(sellerAnalyticsVisitsOverTimeProvider);

    // Other providers
    ref.invalidate(boostPackagesProvider);
    ref.invalidate(reportReasonsProvider);
    ref.invalidate(reportNotifierProvider);
  }
}

// Auth providers with proper caching behavior
final userRoleProvider = FutureProvider<String>((ref) async {
  return ref.read(authRepositoryProvider).getUserRole();
});

final isLoggedInProvider = FutureProvider<bool>((ref) async {
  return ref.read(authRepositoryProvider).isLoggedIn();
});

final currentUserIdProvider = FutureProvider<String?>((ref) async {
  return ref.read(authRepositoryProvider).getCurrentUserId();
});

final currentSessionProvider = FutureProvider<AuthEntity?>((ref) async {
  return ref.read(authRepositoryProvider).getCurrentSession();
});
