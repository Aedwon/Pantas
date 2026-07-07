import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One month, matching the row's own copy: "28 you've got wrong in the last
/// month".
const mistakeWindow = Duration(days: 30);

/// How many distinct questions the student has got wrong in the last month.
///
/// This is the pool "Your mistakes" retakes, so the subtitle and the session
/// come from the same query.
final recentMistakeCountProvider =
    FutureProvider.family<int, ExamId>((ref, examId) async {
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
});

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
