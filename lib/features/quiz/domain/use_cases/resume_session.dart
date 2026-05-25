import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/session_origin.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/quiz_session.dart';

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
    final row = await _sessions.activeFor(userId: userId, examId: examId);
    if (row == null) return null;
    final questions = await _hydrateQuestions(row.questionIds);
    if (questions.isEmpty) return null;
    return QuizSession(
      sessionId: row.id,
      examId: row.examId,
      questions: questions,
      currentIndex: row.currentIndex.clamp(0, questions.length - 1),
      outcomes: const [],
      startedAt: row.startedAt,
      origin: SessionOrigin.fromStorage(row.origin),
      topicId: row.topicId,
      subtopicId: row.subtopicId,
      lessonId: row.lessonId,
    );
  }

  Future<List<Question>> _hydrateQuestions(List<QuestionId> ids) async {
    final questions = <Question>[];
    for (final id in ids) {
      final question = await _content.questionById(id);
      if (question != null) questions.add(question);
    }
    return questions;
  }
}
