import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';

/// One month, matching the row's own copy: "28 you've got wrong in the last
/// month".
const mistakeWindow = Duration(days: 30);

/// How many distinct questions the student has got wrong in the last month.
///
/// This is the pool "Your mistakes" retakes, so the subtitle and the session
/// come from the same query.
///
/// A function, not a cached provider: the Quiz tab's counts are recomputed
/// after every session, and a cached count would keep the last session's
/// answer until the page was reloaded.
Future<int> recentMistakeCount(Ref ref, ExamId examId) async {
  final ids = await ref.watch(attemptsRepositoryProvider).recentIncorrects(
        examId: examId,
        now: ref.watch(nowProvider)(),
        window: mistakeWindow,
        // The default cap is 50. A student with 80 mistakes would be shown 50,
        // which is not a rounded figure, it is a wrong one. Raised past any
        // plausible month so the pool binds before the cap does.
        limit: 100000,
      );
  return ids.length;
}

final flagCountProvider = FutureProvider<int>(
  (ref) => ref.watch(questionFlagsRepositoryProvider).flagCount(),
);

/// What the flagged row says: how many are kept and how many topics they
/// span.
class FlagSummary {
  const FlagSummary({required this.count, required this.topicCount});

  static const empty = FlagSummary(count: 0, topicCount: 0);

  final int count;
  final int topicCount;
}

final flagSummaryProvider = FutureProvider<FlagSummary>((ref) async {
  final ids = await ref.watch(questionFlagsRepositoryProvider).flaggedIds();
  if (ids.isEmpty) return FlagSummary.empty;

  final content = ref.watch(contentRepositoryProvider);
  final topicIds = <TopicId>{};
  for (final id in ids) {
    final question = await content.questionById(id);
    if (question != null) topicIds.add(question.topicId);
  }
  return FlagSummary(count: ids.length, topicCount: topicIds.length);
});

/// The Quiz tab's two practice rows: how many mistakes and how many flagged
/// questions the student has, in this exam.
final quizPracticeCountsProvider = FutureProvider.autoDispose
    .family<({int mistakes, int flags}), ExamId>((ref, examId) async {
  final mistakes = await recentMistakeCount(ref, examId);
  final flags = await ref.watch(questionFlagsRepositoryProvider).flaggedIds();
  final topicIds = (await ref.watch(scopedTopicsProvider(examId).future))
      .map((topic) => topic.id)
      .toSet();
  final questions =
      await ref.watch(contentRepositoryProvider).questionsByIds(flags);
  return (
    mistakes: mistakes,
    flags: questions.values.where((q) => topicIds.contains(q.topicId)).length
  );
});

/// What every flagged count on screen is built from changed. The Quiz tab keeps
/// its counts while a practice run is on top of it and the run can be left
/// without coming back through the tab, so a flag written there must reach it
/// from here.
void refreshFlagCounts(Ref ref) => ref
  ..invalidate(flagSummaryProvider)
  ..invalidate(flagCountProvider)
  ..invalidate(quizPracticeCountsProvider);
