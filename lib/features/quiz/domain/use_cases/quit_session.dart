import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/features/quiz/data/repos/quiz_session_repository.dart';

class QuitSession {
  const QuitSession(this._sessions);

  final QuizSessionRepository _sessions;

  Future<void> call({
    required String userId,
    required ExamId examId,
    required DateTime now,
  }) async {
    final row = await _sessions.activeFor(userId: userId, examId: examId);
    if (row == null) return;
    await _sessions.quit(sessionId: row.id, quitAt: now);
  }
}
