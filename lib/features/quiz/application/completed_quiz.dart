import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';

/// Reopening never shortens a completed paper around unavailable content.
Future<QuizSession> hydrateCompletedQuiz(
  Attempt attempt,
  ContentRepository content, {
  QuizSession? original,
}) async {
  final lookup = original == null
      ? await content.questionsByIds(attempt.items.map((i) => i.questionId))
      : null;
  final questions = original?.questions ??
      <Question?>[for (final item in attempt.items) lookup![item.questionId]];
  if (original != null &&
      (original.sessionId != attempt.id || original.examId != attempt.examId)) {
    throw StateError('Completed quiz identity changed');
  }
  if (questions.length != attempt.items.length) {
    throw StateError('Completed quiz membership changed');
  }
  final exact = <Question>[];
  for (var i = 0; i < questions.length; i++) {
    final question = questions[i];
    final item = attempt.items[i];
    if (question == null ||
        question.id != item.questionId ||
        question.version != item.questionVersion ||
        !question.choices.any((c) => c.id == item.chosenChoiceId) ||
        !question.choices.any((c) => c.id == item.correctChoiceId)) {
      throw StateError('Original quiz content is unavailable');
    }
    exact.add(question);
  }
  return QuizSession(
    sessionId: attempt.id,
    examId: attempt.examId,
    questions: exact,
    currentIndex: exact.length,
    startedAt: attempt.startedAt,
    origin: SessionOrigin.fromStorage(attempt.origin),
    lessonId: original?.lessonId,
    topicId: original?.topicId,
    subtopicId: original?.subtopicId,
    reviewBatch: original?.reviewBatch,
    outcomes: [
      for (final item in attempt.items)
        AnswerOutcome(
          questionId: item.questionId,
          questionVersion: item.questionVersion,
          chosenChoiceId: item.chosenChoiceId,
          correctChoiceId: item.correctChoiceId,
          responseMs: item.responseMs,
        ),
    ],
  );
}
