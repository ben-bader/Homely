import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/media/models/property_media.dart';
import 'package:mobile/features/media/repositories/media_repository.dart';

final propertyMediaProvider =
    AsyncNotifierProviderFamily<
      PropertyMediaNotifier,
      List<PropertyMedia>,
      String
    >(PropertyMediaNotifier.new);

class PropertyMediaNotifier
    extends FamilyAsyncNotifier<List<PropertyMedia>, String> {
  @override
  Future<List<PropertyMedia>> build(String arg) =>
      ref.read(mediaRepositoryProvider).getByPropertyId(arg);
  Future<void> addMedia(PropertyMediaCreateRequest request) async {
    final previous = state;
    state = await AsyncValue.guard(() async {
      await ref.read(mediaRepositoryProvider).create(request);
      return ref.read(mediaRepositoryProvider).getByPropertyId(arg);
    });
    if (state.hasError) state = previous;
  }
  Future<void> removeMedia(String mediaId) async {
    final previous = state;
    state = AsyncData(
      state.valueOrNull?.where((m) => m.id != mediaId).toList() ?? [],
    );
    try {
      await ref.read(mediaRepositoryProvider).delete(mediaId);
    } catch (_) {
      state = previous; 
      rethrow;
    }
  }
  Future<String> uploadVideo({
    required File file,
    required int displayOrder,
  }) async {
    ref.read(videoUploadLoadingProvider.notifier).state = true;
    ref.read(videoUploadErrorProvider.notifier).state = null;

    try {
      final repo = ref.read(mediaRepositoryProvider);
      final url = await repo.uploadVideo(
        VideoUploadRequest(
          propertyId: arg,
          file: file,
          displayOrder: displayOrder,
        ),
      );
      state = await AsyncValue.guard(() => repo.getByPropertyId(arg));
      return url;
    } catch (e) {
      ref.read(videoUploadErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      ref.read(videoUploadLoadingProvider.notifier).state = false;
    }
  }
}
final videoUploadLoadingProvider = StateProvider<bool>((ref) => false);
final videoUploadErrorProvider = StateProvider<String?>((ref) => null);
final propertyImagesProvider = Provider.family<List<PropertyMedia>, String>((
  ref,
  propertyId,
) {
  return ref
          .watch(propertyMediaProvider(propertyId))
          .valueOrNull
          ?.where((m) => m.isImage)
          .toList() ??
      [];
});
final propertyVideosProvider = Provider.family<List<PropertyMedia>, String>((
  ref,
  propertyId,
) {
  return ref
          .watch(propertyMediaProvider(propertyId))
          .valueOrNull
          ?.where((m) => m.isVideo)
          .toList() ??
      [];
});
final propertyMediaCountProvider = Provider.family<int, String>((
  ref,
  propertyId,
) {
  return ref.watch(propertyMediaProvider(propertyId)).valueOrNull?.length ?? 0;
});
