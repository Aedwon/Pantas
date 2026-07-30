import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:uuid/uuid.dart';

class RestartSession {
  RestartSession({
    required ContentRepository content,
    required QuizSessionRepository sessions,
    String Function()? newSessionId,
  })  : _content = content,
        _sessions = sessions,
        _newSessionId = newSessionId ?? const Uuid().v4;

  final ContentRepository _content;
  final QuizSessionRepository _sessions;
  final String Function() _newSessionId;

  Future<QuizSession?> call({
    required String userId,
    required ExamId examId,
    required DateTime now,
  }) async {
    final row = await _sessions.activeFor(userId: userId, examId: examId);
    if (row == null) return null;
    final questions = await _hydrateQuestions(row.questionIds);
    if (questions.isEmpty) return null;

    await _sessions.quit(sessionId: row.id, quitAt: now);
    final sessionId = _newSessionId();
    final origin = SessionOrigin.fromStorage(row.origin);
    await _sessions.create(
      sessionId: sessionId,
      userId: userId,
      examId: examId,
      origin: origin,
      topicId: row.topicId,
      subtopicId: row.subtopicId,
      lessonId: row.lessonId,
      questionIds: questions.map((question) => question.id).toList(),
      startedAt: now,
    );
    return QuizSession.start(
      sessionId: sessionId,
      examId: examId,
      questions: questions,
      startedAt: now,
      origin: origin,
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
