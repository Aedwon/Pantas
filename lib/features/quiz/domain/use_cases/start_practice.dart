import 'dart:async';

import 'package:pantas/core/storage/data/repos/attempts_repository.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/data/repos/review_state_repository.dart';
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
    required ReviewStateRepository reviews,
    QuestionPicker? picker,
    Uuid? uuid,
  })  : _content = content,
        _sessions = sessions,
        _attempts = attempts,
        _reviews = reviews,
        _picker = picker ?? DrillPicker(),
        _uuid = uuid ?? const Uuid();

  final ContentRepository _content;
  final QuizSessionRepository _sessions;
  final AttemptsRepository _attempts;
  final ReviewStateRepository _reviews;
  final QuestionPicker _picker;
  final Uuid _uuid;

  Future<StartPracticeResult> call({
    required String userId,
    required ExamId examId,
    required List<PracticeUnit> units,
    required int perUnit,
    required DateTime now,
    Map<String, int> countsByUnit = const {},
    FutureOr<bool> Function()? canPersist,
  }) async {
    if (units.isEmpty || perUnit <= 0) {
      return const StartPracticeNoQuestions(
        'Pick a topic or a lesson first.',
      );
    }

    final topics = <TopicId, List<Question>>{};
    final pools = <List<Question>>[];
    for (final unit in units) {
      final questions =
          topics[unit.topicId] ?? await _content.questionsByTopic(unit.topicId);
      topics[unit.topicId] = questions;
      pools.add(
        unit.lessonId == null
            ? questions
            : questions.where((q) => q.lessonId == unit.lessonId).toList(),
      );
    }
    final cutoff = now.subtract(practiceRecencyWindow);
    final outcomes = await _attempts.questionOutcomes(
      examId: examId,
      now: now,
      window: practiceRecencyWindow,
    );
    final states = await _reviews.byQuestionIds(
      pools.expand((pool) => pool).map((question) => question.id),
    );
    final excluded = outcomes.keys.toSet();
    for (final state in states.values) {
      if (state.reps > 0 && !state.lastReview.isBefore(cutoff)) {
        excluded.add(state.questionId);
      }
    }
    final drawn = <List<Question>>[];
    for (final (i, unit) in units.indexed) {
      drawn.add(
        _picker.pick(
          PickContext(
            allQuestions: pools[i],
            requestedLength: countsByUnit[unit.key] ?? perUnit,
            excludedQuestionIds: excluded,
          ),
        ),
      );
    }
    final picked = <Question>[];
    final used = <QuestionId>{};
    final longest = drawn.fold<int>(
      0,
      (length, pool) => pool.length > length ? pool.length : length,
    );
    for (var i = 0; i < longest; i++) {
      for (final pool in drawn) {
        if (i < pool.length && used.add(pool[i].id)) picked.add(pool[i]);
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
    final created = await _sessions.createGuarded(
      sessionId: session.sessionId,
      userId: userId,
      examId: examId,
      origin: SessionOrigin.drill,
      topicId: session.topicId,
      questionIds: session.questions.map((question) => question.id).toList(),
      startedAt: now,
      canPersist: canPersist ?? () => true,
    );
    if (!created) throw StateError('Custom quiz launch changed');
    return StartPracticeStarted(session);
  }

  Future<StartPracticeResult> fromQuestionIds({
    required String userId,
    required ExamId examId,
    required List<QuestionId> questionIds,
    required DateTime now,
    SessionOrigin origin = SessionOrigin.drill,
    FutureOr<bool> Function()? canPersist,
  }) async {
    if (questionIds.isEmpty) {
      return const StartPracticeNoQuestions(
        'Flag anything you want to come back to',
      );
    }

    final flaggedQuestions = origin == SessionOrigin.flagged
        ? await _content.questionsByIds(questionIds)
        : null;
    final picked = <Question>[];
    for (final id in questionIds) {
      final q = flaggedQuestions == null
          ? await _content.questionById(id)
          : flaggedQuestions[id];
      if (q == null && origin == SessionOrigin.flagged) {
        throw StateError('Flagged content is unavailable');
      }
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
      origin: origin,
    );

    final created = await _sessions.createGuarded(
      sessionId: session.sessionId,
      userId: userId,
      examId: examId,
      origin: origin,
      topicId: session.topicId,
      questionIds: session.questions.map((question) => question.id).toList(),
      startedAt: now,
      canPersist: canPersist ?? () => true,
    );
    if (!created) throw StateError('Flagged quiz launch changed');

    return StartPracticeStarted(session);
  }
}
