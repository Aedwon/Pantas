import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/review_list.dart';
import 'package:pantas/features/metrics/signals/mock_payload_reader.dart';
import 'package:pantas/features/mock_exam/application/mock_availability_provider.dart';
import 'package:pantas/features/mock_exam/application/server_mock_providers.dart';
import 'package:pantas/features/mock_exam/application/server_mock_results_providers.dart';
import 'package:pantas/features/mock_exam/data/server_mock_api.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';
import 'package:pantas/features/mock_exam/domain/mock_session_snapshot.dart';

/// Every question in one finished mock attempt, in paper order.
///
/// [ReviewEntry.subjectName] carries the paper-part name here. Mock review is
/// grouped by the paper the student actually sat, not by content taxonomy.
final mockReviewProvider =
    FutureProvider.family<List<ReviewEntry>, String>((ref, attemptId) async {
  if (ref.watch(mockUsesServerProvider)) {
    return _serverReviewEntries(ref, attemptId);
  }
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
  if (ref.watch(mockUsesServerProvider)) {
    final result = await ref.watch(serverMockResultProvider(attemptId).future);
    if (!result.canReview) return const {};
    final uid = ref.watch(serverMockIdentityProvider);
    if (uid == null) throw const ServerMockException(code: 'unauthenticated');
    final view = await ref
        .watch(serverMockViewCacheProvider)
        .read(uid: uid, mockId: attemptId);
    if (ref.read(serverMockActorProvider)() != uid) {
      throw const ServerMockException(code: 'cancelled');
    }
    return view?.flags.intersection(result.paper!.questionIds.toSet()) ??
        const {};
  }
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

/// Saved notes use the same decoder as the submitted snapshot.
final mockReviewAnswersProvider =
    FutureProvider.family<Map<String, MockAnswer>, String>(
        (ref, attemptId) async {
  if (ref.watch(mockUsesServerProvider)) {
    final result = await ref.watch(serverMockResultProvider(attemptId).future);
    if (!result.proCovered) return const {};
    final paper = result.paper!;
    final questions = await ref
        .watch(contentRepositoryProvider)
        .questionsByIds(paper.questionIds);
    return {
      for (final id in paper.questionIds)
        id: MockAnswer(
          selectedIndex: questions[id]
                  ?.choices
                  .indexWhere((c) => c.id == paper.answers[id]?.chosen) ??
              -1,
          atSec: 0,
          missReason: result.notes[id]?.missReason,
          blankReason: result.notes[id]?.blankReason,
          reasonNote: result.notes[id]?.reasonNote,
        ),
    };
  }
  final attempt = await ref.watch(mockAttemptRepoProvider).findById(attemptId);
  if (attempt == null) return const {};
  return const MockSessionSnapshotCodec()
      .decode(
        sampledQuestionsJson: attempt.sampledQuestionsJson,
        answersJson: attempt.answersJson,
        flagsJson: attempt.flagsJson,
      )
      .answers;
});

/// Saved study flags are separate from immutable marks made under the clock.
final mockSavedFlagIdsProvider = FutureProvider<Set<String>>(
  (ref) => ref.watch(questionFlagsRepositoryProvider).flaggedIds(),
);

Future<List<ReviewEntry>> _serverReviewEntries(Ref ref, String id) async {
  final result = await ref.watch(serverMockResultProvider(id).future);
  if (!result.canReview) return const [];
  final paper = result.paper!;
  final content = ref.watch(contentRepositoryProvider);
  final questions = await content.questionsByIds(paper.questionIds);
  if (paper.questionIds.any((id) => !questions.containsKey(id))) {
    throw const FormatException('Original mock questions are unavailable');
  }
  final lookup = _ContentLookup(content);
  final marked = await ref.watch(mockMarkedQuestionIdsProvider(id).future);
  final entries = <ReviewEntry>[];
  for (final section in paper.sections) {
    for (final pinned in section.questions) {
      final question = questions[pinned.id]!;
      final passage = await lookup.passage(question.passageId);
      if (question.passageId != null && passage == null) {
        throw const FormatException('Original mock passage is unavailable');
      }
      entries.add(
        ReviewEntry(
          number: entries.length + 1,
          question: question,
          chosenChoiceId: paper.answers[pinned.id]?.chosen,
          isFlagged: marked.contains(pinned.id),
          subjectName: section.name,
          label: question.shortLabel ?? question.stem,
          labelIsStem: question.shortLabel == null,
          passage: passage,
        ),
      );
    }
  }
  return List.unmodifiable(entries);
}
