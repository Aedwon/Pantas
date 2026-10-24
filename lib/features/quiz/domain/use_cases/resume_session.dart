import 'package:collection/collection.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:pantas/features/quiz/domain/models/review_batch_position.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';

class ResumeSession {
  const ResumeSession({
    required ContentRepository content,
    required QuizSessionRepository sessions,
  })  : _content = content,
        _sessions = sessions;

  final ContentRepository _content;
  final QuizSessionRepository _sessions;

  Future<QuizSession?> call({
    required String userId,
    required ExamId examId,
  }) async {
    final scope = _sessions.reviewBatches.capture(userId, examId);
    final row = await _sessions.activeFor(userId: userId, examId: examId);
    if (row == null) return null;
    final batch = await _sessions.reviewBatchFor(row, scope);
    final questions = await _hydrateQuestions(row.questionIds);
    if (questions.isEmpty ||
        !const ListEquality<String>()
            .equals(row.questionIds, [for (final q in questions) q.id]) ||
        row.currentIndex != row.outcomes.length ||
        row.outcomes.length > questions.length) {
      throw StateError('Saved quiz content is unavailable');
    }
    for (var i = 0; i < row.outcomes.length; i++) {
      if (row.outcomes[i].questionId != questions[i].id) {
        throw StateError('Saved quiz answer order changed');
      }
    }
    if (batch != null) {
      _sessions.reviewBatches
          .validateHydration(batch, batch.current, questions);
      if (scope == null ||
          !(_sessions.reviewBatches
                  .capture(row.userId, row.examId)
                  ?.matches(scope) ??
              false)) {
        throw StateError('Reviews account changed');
      }
      await _sessions.reviewBatchFor(row, scope);
    }
    return QuizSession(
      sessionId: row.id,
      examId: row.examId,
      questions: questions,
      currentIndex: row.currentIndex.clamp(0, questions.length - 1),
      outcomes: row.outcomes,
      startedAt: row.startedAt,
      origin: SessionOrigin.fromStorage(row.origin),
      topicId: row.topicId,
      subtopicId: row.subtopicId,
      lessonId: row.lessonId,
      reviewBatch: batch == null
          ? null
          : ReviewBatchPosition(
              batchId: batch.batchId,
              userId: batch.scope.userId,
              ordinal: batch.current + 1,
              total: batch.chunks.length,
            ),
    );
  }

  Future<List<Question>> _hydrateQuestions(List<QuestionId> ids) {
    return _content.hydrateSelectedQuestions(ids);
  }
}
