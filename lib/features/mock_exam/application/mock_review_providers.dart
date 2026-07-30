import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/subject.dart';
import 'package:pantas/core/storage/domain/topic.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/review_list.dart';
import 'package:pantas/features/metrics/signals/mock_payload_reader.dart';
import 'package:pantas/features/mock_exam/application/mock_availability_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Every question in one finished mock attempt, in paper order.
final mockReviewProvider =
    FutureProvider.family<List<ReviewEntry>, String>((ref, attemptId) async {
  final attempt = await ref.watch(mockAttemptRepoProvider).findById(attemptId);
  if (attempt == null) return const [];

  final content = ref.watch(contentRepositoryProvider);
  final flagged = await ref.watch(questionFlagsRepositoryProvider).flaggedIds();

  final payload = const MockPayloadReader().read(
    sampledQuestionsJson: attempt.sampledQuestionsJson,
    answersJson: attempt.answersJson,
    flagsJson: attempt.flagsJson,
  );

  final allQuestionIds = <String>[];
  for (final section in payload.sections) {
    allQuestionIds.addAll(section.questionIds);
  }

  final questions = await content.questionsByIds(allQuestionIds);
  final lookup = _ContentLookup(content);

  final entries = <ReviewEntry>[];
  for (var i = 0; i < allQuestionIds.length; i++) {
    final qId = allQuestionIds[i];
    final question = questions[qId];
    if (question == null) continue;

    final topic = await lookup.topic(question.topicId);
    final subject =
        topic == null ? null : await lookup.subject(topic.subjectId);
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

  final _topics = <TopicId, Topic?>{};
  final _subjects = <SubjectId, Subject?>{};
  final _passages = <PassageId, Passage?>{};

  Future<Topic?> topic(TopicId id) async {
    if (_topics.containsKey(id)) return _topics[id];
    return _topics[id] = await _content.topicById(id);
  }

  Future<Subject?> subject(SubjectId id) async {
    if (_subjects.containsKey(id)) return _subjects[id];
    return _subjects[id] = await _content.subjectById(id);
  }

  Future<Passage?> passage(PassageId? id) async {
    if (id == null) return null;
    if (_passages.containsKey(id)) return _passages[id];
    return _passages[id] = await _content.passageById(id);
  }
}
