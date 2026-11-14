import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';

/// The reader supplies its active exam. Pushing preserves the reader and its
/// position so Done returns to the same lesson.
Future<void> startLessonQuiz(
  BuildContext context,
  LessonId lessonId, {
  required ExamId examId,
}) =>
    context.push<void>(
      '/quiz/inline/${Uri.encodeComponent(examId)}/'
      '${Uri.encodeComponent(lessonId)}',
    );

/// Only Study offers this entry. The route uses the existing ten-question
/// quick selector and returns to Study when the session ends.
Future<void> startQuickQuiz(
  BuildContext context, {
  required ExamId examId,
}) =>
    context.push<void>('/quiz/quick/${Uri.encodeComponent(examId)}');

final lessonQuizAvailableProvider = FutureProvider.autoDispose
    .family<bool, ({ExamId examId, LessonId lessonId})>((ref, key) async {
  final content = ref.watch(contentRepositoryProvider);
  final lesson = await content.lessonById(key.lessonId);
  if (lesson == null) return false;
  final rows = await content.selectionRowsByTopic(
    lesson.topicId,
    examId: key.examId,
  );
  return rows.any((row) => row.lessonId == key.lessonId);
});

/// How many questions the lesson's quiz will show for the active exam:
/// the lesson's quiz size, capped by the questions available. Zero when there
/// is no active exam, no lesson or no questions.
final lessonQuizCountProvider =
    FutureProvider.autoDispose.family<int, LessonId>((ref, lessonId) async {
  final focus = await ref.watch(activeExamFocusProvider.future);
  final examId = focus.exam?.id;
  if (examId == null) return 0;
  final content = ref.watch(contentRepositoryProvider);
  final lesson = await content.lessonById(lessonId);
  if (lesson == null) return 0;
  final rows = await content.selectionRowsByTopic(
    lesson.topicId,
    examId: examId,
  );
  final available = rows.where((row) => row.lessonId == lessonId).length;
  return available < lesson.quizSize ? available : lesson.quizSize;
});
