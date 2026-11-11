import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/storage/domain/ids.dart';
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
