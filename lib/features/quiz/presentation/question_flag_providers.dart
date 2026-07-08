import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/review_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What just happened, so the caller knows which toast to raise.
enum FlagToggle { firstFlagged, flagged, unflagged }

final flaggedIdsProvider = FutureProvider<Set<QuestionId>>(
  (ref) => ref.watch(questionFlagsRepositoryProvider).flaggedIds(),
);

final questionFlagControllerProvider =
    NotifierProvider<QuestionFlagController, void>(QuestionFlagController.new);

class QuestionFlagController extends Notifier<void> {
  @override
  void build() {}

  /// Never submits and never advances. It writes one row and nothing else,
  /// which is the reason the control is in the bar rather than on a choice.
  Future<FlagToggle> toggle(QuestionId questionId) async {
    final repo = ref.read(questionFlagsRepositoryProvider);
    final prefs = ref.read(appPreferencesRepositoryProvider);
    final wasFlagged = await repo.isFlagged(questionId);

    if (wasFlagged) {
      await repo.unflag(questionId);
      ref
        ..invalidate(flaggedIdsProvider)
        ..invalidate(flaggedReviewProvider);
      return FlagToggle.unflagged;
    }

    await repo.flag(questionId);
    ref
      ..invalidate(flaggedIdsProvider)
      ..invalidate(flaggedReviewProvider);

    final announced = await prefs.hasAnnouncedFirstFlag();
    if (announced) return FlagToggle.flagged;
    await prefs.setAnnouncedFirstFlag();
    return FlagToggle.firstFlagged;
  }
}
