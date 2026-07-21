import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/features/quiz/data/repos/quiz_session_repository.dart';

class QuitSession {
  const QuitSession(this._sessions);

  final QuizSessionRepository _sessions;

  /// Discards everything still open for this exam.
  ///
  /// One at a time was the old behaviour, and with sessions accumulating it
  /// meant a student had to press Discard once per abandoned session with no
  /// sign that anything was happening.
  Future<void> call({
    required String userId,
    required ExamId examId,
    required DateTime now,
  }) async {
    await _sessions.quitAllOpen(userId: userId, examId: examId, quitAt: now);
  }
}
