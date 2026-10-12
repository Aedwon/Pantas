import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/storage/domain/ids.dart';

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
