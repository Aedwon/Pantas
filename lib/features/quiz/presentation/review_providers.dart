import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/subject.dart';
import 'package:pantas/core/storage/domain/topic.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/core/ui/components/review_list.dart';
import 'package:pantas/features/quiz/presentation/question_flag_providers.dart';

/// Every question in one finished practice attempt, in the order it was
/// asked.
final practiceReviewProvider =
    FutureProvider.family<List<ReviewEntry>, AttemptId>((ref, attemptId) async {
  final attempt = await ref.watch(attemptsRepositoryProvider).byId(attemptId);
  if (attempt == null) return const [];

  final content = ref.watch(contentRepositoryProvider);
  final flagged = await ref.watch(flaggedIdsProvider.future);

  // One query for every question, then one per distinct topic, subject and
  // passage. It used to be four per question in series, which is what made
  // the result look like it was loading.
  final questions =
      await content.questionsByIds(attempt.items.map((i) => i.questionId));
  final lookup = _ContentLookup(content);

  final entries = <ReviewEntry>[];
  for (var i = 0; i < attempt.items.length; i++) {
    final item = attempt.items[i];
    final question = questions[item.questionId];
    if (question == null) continue;
    final topic = await lookup.topic(question.topicId);
    final subject =
        topic == null ? null : await lookup.subject(topic.subjectId);
    // Reading comprehension questions are unanswerable without their passage,
    // so the review carries it through and the list prints it once above the
    // run that shares it.
    final passage = await lookup.passage(question.passageId);
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

  final questions =
      await content.questionsByIds(flagRows.map((r) => r.questionId));
  final lookup = _ContentLookup(content);

  final entries = <ReviewEntry>[];
  for (final flagRow in flagRows) {
    final question = questions[flagRow.questionId];
    if (question == null) continue;
    final topic = await lookup.topic(question.topicId);
    final subject =
        topic == null ? null : await lookup.subject(topic.subjectId);
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

/// Remembers what it has already read.
///
/// A session of 120 questions spans a handful of topics and fewer subjects,
/// so asking the database for each one per question was the same answer
/// fetched over and over.
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

/// Current flags in this exam/track. Storage keeps flags for every exam.
final flaggedExamReviewProvider = FutureProvider.autoDispose
    .family<List<ReviewEntry>, ExamId>((ref, examId) async {
  // The flag controller invalidates this existing signal after every write.
  await ref.watch(flaggedIdsProvider.future);
  final rows =
      await ref.watch(questionFlagsRepositoryProvider).flagsNewestFirst();
  if (rows.isEmpty) return const [];
  final topics = await ref.watch(scopedTopicsProvider(examId).future);
  final scope = {for (final topic in topics) topic.id: topic};
  final content = ref.watch(contentRepositoryProvider);
  final questions =
      await content.questionsByIds(rows.map((row) => row.questionId));
  final lookup = _ContentLookup(content);
  final entries = <ReviewEntry>[];
  for (final row in rows) {
    final question = questions[row.questionId];
    if (question == null) throw StateError('Flagged content is unavailable');
    final topic = scope[question.topicId];
    if (topic == null) continue;
    final subject = await lookup.subject(topic.subjectId);
    if (subject == null) throw StateError('Flagged subject is unavailable');
    final passageId = question.passageId;
    final passage = passageId == null || passageId.isEmpty
        ? null
        : await lookup.passage(passageId);
    if (passageId != null && passageId.isNotEmpty && passage == null) {
      throw StateError('Flagged passage is unavailable');
    }
    entries.add(
      ReviewEntry(
        number: entries.length + 1,
        question: question,
        isFlagged: true,
        subjectName: subject.name,
        label: question.shortLabel ?? question.stem,
        labelIsStem: question.shortLabel == null,
        passage: passage,
      ),
    );
  }
  return entries;
});
