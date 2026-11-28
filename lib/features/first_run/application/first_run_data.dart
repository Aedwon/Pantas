import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/domain/choice_order.dart';
import 'package:pantas/core/storage/domain/lesson.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/first_run/domain/first_run_content.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';

/// What the run shows: the lesson, the three questions with their choices in
/// the order the app always uses for each question, and the names for the
/// eyebrow.
class FirstRunData {
  const FirstRunData({
    required this.lesson,
    required this.questions,
    required this.subjectName,
    required this.topicName,
  });

  final Lesson lesson;
  final List<Question> questions;
  final String subjectName;
  final String topicName;

  /// "Mathematics · Arithmetic": the topic name up to its first "&".
  ///
  /// Frames W03, W04 and W02 draw "MATHEMATICS · ARITHMETIC" for the topic
  /// "Arithmetic & Number Sense". The cut at "&" is exact for this one fixed
  /// lesson only; a topic with another shape would need its own wording.
  String get eyebrow => '$subjectName: ${topicName.split(' & ').first}';
}

/// How long the lesson stays open before it can count as read. Only tests
/// shorten it.
final firstRunReadDwellProvider = Provider<Duration>((ref) => readDwellFloor);

/// The run's content for an exam id. Throws when the exam has no fixed lesson
/// or any piece is missing, so the page shows its error state.
final firstRunDataProvider =
    FutureProvider.family<FirstRunData, String>((ref, examId) async {
  final content = firstRunContentFor(examId);
  if (content == null) throw StateError('No fixed lesson for $examId');
  final repo = ref.watch(contentRepositoryProvider);
  final lesson = await ref.watch(lessonByIdProvider(content.lessonId).future);
  if (lesson == null) throw StateError('Fixed lesson is missing');
  final byId = await repo.questionsByIds(content.questionIds);
  final questions = [
    for (final id in content.questionIds)
      if (byId[id] case final q?)
        q.copyWith(choices: orderChoicesFor(q.id, q.choices))
      else
        throw StateError('Fixed question $id is missing'),
  ];
  final topic = await repo.topicById(lesson.topicId);
  final subject =
      topic == null ? null : await repo.subjectById(topic.subjectId);
  return FirstRunData(
    lesson: lesson,
    questions: questions,
    subjectName: subject?.name ?? '',
    topicName: topic?.name ?? '',
  );
});
