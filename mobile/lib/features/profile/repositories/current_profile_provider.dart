import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/profile/models/profile.dart';
import '../repositories/profile_repository.dart';

final currentProfileProvider = Provider<Profile?>((ref) {
  return ref.watch(profileNotifierProvider).valueOrNull;
});