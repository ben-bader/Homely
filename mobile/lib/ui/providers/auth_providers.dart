import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/secure_storage.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth/auth_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';

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
