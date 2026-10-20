import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/review_list.dart';
import 'package:pantas/features/metrics/signals/mock_payload_reader.dart';
import 'package:pantas/features/mock_exam/application/mock_availability_provider.dart';

/// Every question in one finished mock attempt, in paper order.
///
/// [ReviewEntry.subjectName] carries the paper-part name here. Mock review is
/// grouped by the paper the student actually sat, not by content taxonomy.
final mockReviewProvider =
    FutureProvider.family<List<ReviewEntry>, String>((ref, attemptId) async {
  final attempt = await ref.watch(mockAttemptRepoProvider).findById(attemptId);
  if (attempt == null) return const [];

  final content = ref.watch(contentRepositoryProvider);
  final payload = const MockPayloadReader().read(
    sampledQuestionsJson: attempt.sampledQuestionsJson,
    answersJson: attempt.answersJson,
    flagsJson: attempt.flagsJson,
  );

  final allQuestionIds = <String>[
    for (final section in payload.sections) ...section.questionIds,
  ];
  final questions = await content.questionsByIds(allQuestionIds);
  final lookup = _ContentLookup(content);
  final entries = <ReviewEntry>[];

  for (final section in payload.sections) {
    for (final qId in section.questionIds) {
      final question = questions[qId];
      if (question == null) continue;

      final passage = await lookup.passage(question.passageId);
      final mockAnswer = payload.answers[qId];
      ChoiceId? chosenChoiceId;
      if (mockAnswer != null &&
          mockAnswer.selectedIndex >= 0 &&
          mockAnswer.selectedIndex < question.choices.length) {
        chosenChoiceId = question.choices[mockAnswer.selectedIndex].id;
      }

      entries.add(
        ReviewEntry(
          number: entries.length + 1,
          question: question,
          chosenChoiceId: chosenChoiceId,
          isFlagged: payload.flaggedQuestionIds.contains(question.id),
          subjectName: section.name,
          label: question.shortLabel ?? question.stem,
          labelIsStem: question.shortLabel == null,
          passage: passage,
        ),
      );
    }
  }

  return entries;
});

/// The question IDs marked under the clock for a given attempt.
final mockMarkedQuestionIdsProvider =
    FutureProvider.family<Set<String>, String>((ref, attemptId) async {
  final attempt = await ref.watch(mockAttemptRepoProvider).findById(attemptId);
  if (attempt == null) return const {};

  final payload = const MockPayloadReader().read(
    sampledQuestionsJson: attempt.sampledQuestionsJson,
    answersJson: attempt.answersJson,
    flagsJson: attempt.flagsJson,
  );
  return payload.flaggedQuestionIds;
});

/// Whether the one-time flag offer has already been handled for an attempt.
final mockOfferHandledProvider =
    FutureProvider.family<bool, String>((ref, attemptId) async {
  final prefs = ref.watch(appPreferencesRepositoryProvider);
  final value = await prefs.deviceValue('mock_flag_offer_handled_$attemptId');
  return value == 'true';
});

class _ContentLookup {
  _ContentLookup(this._content);

  final ContentRepository _content;
  final _passages = <PassageId, Passage?>{};

  Future<Passage?> passage(PassageId? id) async {
    if (id == null) return null;
    if (_passages.containsKey(id)) return _passages[id];
    return _passages[id] = await _content.passageById(id);
  }
}
