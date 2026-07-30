import 'package:pantas/core/storage/data/repos/attempts_repository.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/domain/picker/drill_picker.dart';
import 'package:pantas/features/quiz/domain/picker/pick_context.dart';
import 'package:pantas/features/quiz/domain/picker/practice_selection.dart';
import 'package:pantas/features/quiz/domain/picker/question_picker.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:uuid/uuid.dart';

/// Anything answered inside this window goes to the back of the pool.
const practiceRecencyWindow = Duration(days: 7);

sealed class StartPracticeResult {
  const StartPracticeResult();
}

class StartPracticeStarted extends StartPracticeResult {
  const StartPracticeStarted(this.session);

  final QuizSession session;
}

class StartPracticeNoQuestions extends StartPracticeResult {
  const StartPracticeNoQuestions(this.message);

  final String message;
}

/// One session from many selections, each drawing `perUnit` from its own
/// pool.
///
/// Per selection rather than a total because a total cannot be split at all
/// when five is asked across six topics, and when it can be split something
/// has to decide the shares.
class StartPractice {
  StartPractice({
    required ContentRepository content,
    required QuizSessionRepository sessions,
    required AttemptsRepository attempts,
    QuestionPicker? picker,
    Uuid? uuid,
  })  : _content = content,
        _sessions = sessions,
        _attempts = attempts,
        _picker = picker ?? DrillPicker(),
        _uuid = uuid ?? const Uuid();

  final ContentRepository _content;
  final QuizSessionRepository _sessions;
  final AttemptsRepository _attempts;
  final QuestionPicker _picker;
  final Uuid _uuid;

  Future<StartPracticeResult> call({
    required String userId,
    required ExamId examId,
    required List<PracticeUnit> units,
    required int perUnit,
    required DateTime now,
  }) async {
    if (units.isEmpty || perUnit <= 0) {
      return const StartPracticeNoQuestions(
        'Pick a topic or a lesson first.',
      );
    }

    final excluded = await _attempts.questionIdsAnsweredSince(
      examId: examId,
      since: now.subtract(practiceRecencyWindow),
    );

    final picked = <Question>[];
    final used = <QuestionId>{};
    for (final unit in units) {
      final pool = await _poolFor(unit);
      final drawn = _picker.pick(
        PickContext(
          allQuestions: pool,
          requestedLength: perUnit,
          excludedQuestionIds: excluded,
        ),
      );
      for (final question in drawn) {
        // A question tagged to a lesson also sits in that lesson's topic, so
        // selecting both would ask it twice.
        if (used.add(question.id)) picked.add(question);
      }
    }

    if (picked.isEmpty) {
      return const StartPracticeNoQuestions(
        'There are no questions in what you picked.',
      );
    }

    final session = QuizSession.start(
      sessionId: _uuid.v4(),
      examId: examId,
      questions: picked,
      startedAt: now,
      origin: SessionOrigin.drill,
      // A session spanning several topics is named after none of them.
      topicId: units.length == 1 ? units.single.topicId : null,
    );
    await _sessions.create(
      sessionId: session.sessionId,
      userId: userId,
      examId: examId,
      origin: SessionOrigin.drill,
      topicId: session.topicId,
      questionIds: picked.map((question) => question.id).toList(),
      startedAt: now,
    );
    return StartPracticeStarted(session);
  }

  Future<StartPracticeResult> fromQuestionIds({
    required String userId,
    required ExamId examId,
    required List<QuestionId> questionIds,
    required DateTime now,
  }) async {
    if (questionIds.isEmpty) {
      return const StartPracticeNoQuestions(
        'Flag anything you want to come back to',
      );
    }

    final picked = <Question>[];
    for (final id in questionIds) {
      final q = await _content.questionById(id);
      if (q != null) picked.add(q);
    }

    if (picked.isEmpty) {
      return const StartPracticeNoQuestions(
        'There are no questions in what you picked.',
      );
    }

    final session = QuizSession.start(
      sessionId: _uuid.v4(),
      examId: examId,
      questions: picked,
      startedAt: now,
      origin: SessionOrigin.drill,
    );

    await _sessions.create(
      sessionId: session.sessionId,
      userId: userId,
      examId: examId,
      origin: SessionOrigin.drill,
      topicId: session.topicId,
      questionIds: picked.map((question) => question.id).toList(),
      startedAt: now,
    );

    return StartPracticeStarted(session);
  }

  Future<List<Question>> _poolFor(PracticeUnit unit) async {
    final questions = await _content.questionsByTopic(unit.topicId);
    final lessonId = unit.lessonId;
    if (lessonId == null) return questions;
    return questions
        .where((question) => question.lessonId == lessonId)
        .toList();
  }
}
