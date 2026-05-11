import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/feedback_remote_datasource.dart';
import '../../data/repositories/feedback_repository_impl.dart';
import '../../domain/entities/feedback/feedback_entity.dart';
import '../../domain/repositories/i_feedback_repository.dart';

final feedbackRemoteDatasourceProvider = Provider<FeedbackRemoteDatasource>(
  (ref) => FeedbackRemoteDatasourceImpl(),
);

final feedbackRepositoryProvider = Provider<IFeedbackRepository>((ref) {
  return FeedbackRepositoryImpl(ref.read(feedbackRemoteDatasourceProvider));
});

final propertyFeedbackProvider =
    AsyncNotifierProviderFamily<
      PropertyFeedbackNotifier,
      List<FeedbackEntity>,
      String
    >(PropertyFeedbackNotifier.new);

class PropertyFeedbackNotifier
    extends FamilyAsyncNotifier<List<FeedbackEntity>, String> {
  @override
  Future<List<FeedbackEntity>> build(String propertyId) =>
      ref.read(feedbackRepositoryProvider).getByProperty(propertyId);

  Future<void> submit({required int rating, String? comment}) async {
    final previous = state;
    try {
      final created = await ref
          .read(feedbackRepositoryProvider)
          .create(propertyId: arg, rating: rating, comment: comment);
      state.whenData((list) => state = AsyncData([created, ...list]));
    } catch (e, st) {
      state = previous;
      Error.throwWithStackTrace(e, st);
    }
  }

  Future<void> delete(String feedbackId) async {
    final previous = state;
    state.whenData(
      (list) =>
          state = AsyncData(list.where((f) => f.id != feedbackId).toList()),
    );
    try {
      await ref.read(feedbackRepositoryProvider).delete(feedbackId);
    } catch (e, st) {
      state = previous;
      Error.throwWithStackTrace(e, st);
    }
  }
}

final propertyAverageRatingProvider = Provider.family<double, String>((
  ref,
  propertyId,
) {
  final feedbackAsync = ref.watch(propertyFeedbackProvider(propertyId));
  return feedbackAsync.maybeWhen(
    data: (list) {
      if (list.isEmpty) return 0.0;
      final total = list.fold<int>(0, (sum, f) => sum + f.rating);
      return total / list.length;
    },
    orElse: () => 0.0,
  );
});

final propertyReviewCountProvider = Provider.family<int, String>((
  ref,
  propertyId,
) {
  final feedbackAsync = ref.watch(propertyFeedbackProvider(propertyId));
  return feedbackAsync.maybeWhen(data: (list) => list.length, orElse: () => 0);
});
