import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/quiz_preferences.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/models/session_origin.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/drill_picker.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/pick_context.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/question_picker.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/quiz_session.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/selectors/subtopic_filter.dart';
import 'package:uuid/uuid.dart';

sealed class StartDrillResult {
  const StartDrillResult();
}

class StartDrillStarted extends StartDrillResult {
  const StartDrillStarted(this.session);

  final QuizSession session;
}

class StartDrillNoQuestions extends StartDrillResult {
  const StartDrillNoQuestions(this.message);

  final String message;
}

class StartDrill {
  StartDrill({
    required ContentRepository content,
    required QuizSessionRepository sessions,
    QuestionPicker? picker,
    Uuid? uuid,
  })  : _content = content,
        _sessions = sessions,
        _picker = picker ?? DrillPicker(),
        _uuid = uuid ?? const Uuid();

  final ContentRepository _content;
  final QuizSessionRepository _sessions;
  final QuestionPicker _picker;
  final Uuid _uuid;

  Future<StartDrillResult> call({
    required String userId,
    required ExamId examId,
    required TopicId topicId,
    required int requestedLength,
    required DateTime now,
    SubtopicId? subtopicId,
  }) async {
    final allQuestions = await _content.questionsByTopic(topicId);
    final length = requestedLength == QuizPreferences.allDueSessionLength
        ? allQuestions.length
        : requestedLength;
    final context = PickContext(
      allQuestions: allQuestions,
      subtopicCandidates: [
        for (final question in allQuestions)
          SubtopicQuestion(question: question, subtopicId: null),
      ],
      requestedLength: length,
      topicId: topicId,
      subtopicId: subtopicId,
    );
    final picked = _picker.pick(context);
    if (picked.isEmpty) {
      return const StartDrillNoQuestions(
        'No questions are available for this drill.',
      );
    }

    final session = QuizSession.start(
      sessionId: _uuid.v4(),
      examId: examId,
      questions: picked,
      startedAt: now,
      origin: SessionOrigin.drill,
      topicId: topicId,
      subtopicId: subtopicId,
    );
    await _sessions.create(
      sessionId: session.sessionId,
      userId: userId,
      examId: examId,
      origin: SessionOrigin.drill,
      topicId: topicId,
      subtopicId: subtopicId,
      questionIds: picked.map((question) => question.id).toList(),
      startedAt: now,
    );
    return StartDrillStarted(session);
  }
}
