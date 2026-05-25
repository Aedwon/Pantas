import 'package:cse_cet_reviewer/core/storage/data/repos/attempts_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/attempt.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/quiz_session.dart';

class CompleteQuiz {
  CompleteQuiz(this._attempts);

  final AttemptsRepository _attempts;

  Future<Attempt> call({
    required QuizSession session,
    required DateTime now,
  }) async {
    if (!session.isComplete) {
      throw StateError('Cannot complete a quiz with unanswered questions');
    }
    final attempt = Attempt(
      id: session.sessionId,
      examId: session.examId,
      origin: session.origin.storageValue,
      startedAt: session.startedAt,
      completedAt: now,
      items: session.outcomes
          .map(
            (o) => AttemptItem(
              questionId: o.questionId,
              questionVersion: o.questionVersion,
              chosenChoiceId: o.chosenChoiceId,
              correctChoiceId: o.correctChoiceId,
              responseMs: o.responseMs,
            ),
          )
          .toList(),
    );
    await _attempts.save(attempt);
    return attempt;
  }
}
