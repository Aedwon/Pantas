import 'package:cse_cet_reviewer/core/storage/data/repos/attempts_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/session_origin.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/pick_context.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/question_picker.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/retake_picker.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/quiz_session.dart';
import 'package:uuid/uuid.dart';

sealed class StartRetakeResult {
  const StartRetakeResult();
}

class StartRetakeStarted extends StartRetakeResult {
  const StartRetakeStarted(this.session);

  final QuizSession session;
}

class StartRetakeNoQuestions extends StartRetakeResult {
  const StartRetakeNoQuestions(this.message);

  final String message;
}

class StartRetake {
  StartRetake({
    required ContentRepository content,
    required AttemptsRepository attempts,
    required QuizSessionRepository sessions,
    QuestionPicker? picker,
    Uuid? uuid,
  })  : _content = content,
        _attempts = attempts,
        _sessions = sessions,
        _picker = picker ?? RetakePicker(),
        _uuid = uuid ?? const Uuid();

  static const mistakeWindow = Duration(days: 30);
  static const maxQuestions = 50;

  final ContentRepository _content;
  final AttemptsRepository _attempts;
  final QuizSessionRepository _sessions;
  final QuestionPicker _picker;
  final Uuid _uuid;

  Future<StartRetakeResult> call({
    required String userId,
    required ExamId examId,
    required DateTime now,
  }) async {
    final missedIds = await _attempts.recentIncorrects(
      examId: examId,
      now: now,
      window: mistakeWindow,
      limit: maxQuestions,
    );
    if (missedIds.isEmpty) {
      return const StartRetakeNoQuestions('No recent mistakes to retake.');
    }

    final questions = <Question>[];
    for (final id in missedIds) {
      final question = await _content.questionById(id);
      if (question != null) questions.add(question);
    }
    final picked = _picker.pick(
      PickContext(
        allQuestions: questions,
        retakeQuestionIds: missedIds,
        requestedLength: maxQuestions,
      ),
    );
    if (picked.isEmpty) {
      return const StartRetakeNoQuestions('No recent mistakes to retake.');
    }

    final session = QuizSession.start(
      sessionId: _uuid.v4(),
      examId: examId,
      questions: picked,
      startedAt: now,
      origin: SessionOrigin.retake,
    );
    await _sessions.create(
      sessionId: session.sessionId,
      userId: userId,
      examId: examId,
      origin: SessionOrigin.retake,
      questionIds: picked.map((question) => question.id).toList(),
      startedAt: now,
    );
    return StartRetakeStarted(session);
  }
}
