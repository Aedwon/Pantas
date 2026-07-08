import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/review_list.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/question_flag_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Every question in one finished practice attempt, in the order it was
/// asked.
final practiceReviewProvider =
    FutureProvider.family<List<ReviewEntry>, AttemptId>((ref, attemptId) async {
  final attempt = await ref.watch(attemptsRepositoryProvider).byId(attemptId);
  if (attempt == null) return const [];

  final content = ref.watch(contentRepositoryProvider);
  final flagged = await ref.watch(flaggedIdsProvider.future);

  final entries = <ReviewEntry>[];
  for (var i = 0; i < attempt.items.length; i++) {
    final item = attempt.items[i];
    final question = await content.questionById(item.questionId);
    if (question == null) continue;
    final topic = await content.topicById(question.topicId);
    final subject =
        topic == null ? null : await content.subjectById(topic.subjectId);
    // Reading comprehension questions are unanswerable without their passage,
    // so the review carries it through and the list prints it once above the
    // run that shares it.
    final passageId = question.passageId;
    final passage =
        passageId == null ? null : await content.passageById(passageId);
    entries.add(
      ReviewEntry(
        number: i + 1,
        question: question,
        chosenChoiceId: item.chosenChoiceId,
        isFlagged: flagged.contains(question.id),
        subjectName: subject?.name ?? topic?.name ?? '',
        label: question.shortLabel ?? question.stem,
        labelIsStem: question.shortLabel == null,
        passage: passage,
      ),
    );
  }
  return entries;
});

/// Every flagged question across subjects, grouped by subject on the page.
final flaggedReviewProvider = FutureProvider<List<ReviewEntry>>((ref) async {
  final flagRows =
      await ref.watch(questionFlagsRepositoryProvider).flagsNewestFirst();
  final content = ref.watch(contentRepositoryProvider);

  final entries = <ReviewEntry>[];
  for (final flagRow in flagRows) {
    final question = await content.questionById(flagRow.questionId);
    if (question == null) continue;
    final topic = await content.topicById(question.topicId);
    final subject =
        topic == null ? null : await content.subjectById(topic.subjectId);
    entries.add(
      ReviewEntry(
        number: entries.length + 1,
        question: question,
        isFlagged: true,
        subjectName: subject?.name ?? topic?.name ?? '',
        label: question.shortLabel ?? question.stem,
        labelIsStem: question.shortLabel == null,
      ),
    );
  }
  return entries;
});
