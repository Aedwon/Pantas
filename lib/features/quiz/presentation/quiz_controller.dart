import 'package:cse_cet_reviewer/core/storage/domain/attempt.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/features/quiz/application/quiz_providers.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/practice_selection.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/quiz_session.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/build_today_plan.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/start_drill.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/start_inline_lesson_quiz.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/start_practice.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/start_retake.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/start_today_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Re-exported so the thirteen files that reach for the quiz's wiring through
// the controller keep working; the wiring itself now lives in application/.
export 'package:cse_cet_reviewer/features/quiz/application/quiz_providers.dart';

sealed class QuizControllerState {
  const QuizControllerState();
}

class QuizIdle extends QuizControllerState {
  const QuizIdle();
}

class QuizLoading extends QuizControllerState {
  const QuizLoading();
}

class QuizRunning extends QuizControllerState {
  const QuizRunning({
    required this.session,
    required this.questionShownAt,
    this.persisted = false,
  });
  final QuizSession session;
  final DateTime questionShownAt;
  final bool persisted;
}

class QuizComplete extends QuizControllerState {
  const QuizComplete({
    required this.attempt,
    required this.session,
  });
  final Attempt attempt;
  final QuizSession session;
}

class QuizFailure extends QuizControllerState {
  const QuizFailure(this.message);
  final String message;
}

final quizControllerProvider =
    StateNotifierProvider<QuizController, QuizControllerState>(
  QuizController.new,
);

class QuizController extends StateNotifier<QuizControllerState> {
  QuizController(this._ref) : super(const QuizIdle());

  final Ref _ref;

  Future<void> start({
    required ExamId examId,
    TopicId? topicId,
    int count = 10,
    int? randomSeed,
  }) async {
    state = const QuizLoading();
    try {
      final now = _ref.read(nowProvider)();
      final session = await _ref.read(startQuickQuizProvider)(
        examId: examId,
        topicId: topicId,
        count: count,
        now: now,
        randomSeed: randomSeed,
      );
      state = QuizRunning(session: session, questionShownAt: now);
    } catch (e) {
      state = QuizFailure(e.toString());
    }
  }

  Future<void> startToday({
    required ExamId examId,
    TopicId? topicId,
    TodaySessionPlan? plan,
  }) async {
    state = const QuizLoading();
    try {
      final now = _ref.read(nowProvider)();
      final preferences =
          await _ref.read(quizPreferencesRepositoryProvider).read();
      final result = await _ref.read(startTodaySessionProvider)(
        userId: _localUserId,
        examId: examId,
        topicId: topicId,
        preferences: preferences,
        now: now,
        plan: plan,
      );
      switch (result) {
        case StartTodaySessionStarted(:final session):
          state = QuizRunning(
            session: session,
            questionShownAt: now,
            persisted: true,
          );
        case StartTodaySessionNoQuestions(:final message):
          state = QuizFailure(message);
      }
    } catch (e) {
      state = QuizFailure(e.toString());
    }
  }

  /// Picks up the session already open for this exam. Never creates one: if
  /// there is nothing to resume the panel should not have offered the button.
  Future<void> resumeToday({required ExamId examId}) async {
    state = const QuizLoading();
    try {
      final now = _ref.read(nowProvider)();
      final session = await _ref.read(resumeSessionProvider)(
        userId: _localUserId,
        examId: examId,
      );
      if (session == null) {
        state = const QuizFailure('There is no session to pick up.');
        return;
      }
      state = QuizRunning(
        session: session,
        questionShownAt: now,
        persisted: true,
      );
    } catch (e) {
      state = QuizFailure(e.toString());
    }
  }

  /// One session built from many picked units, each drawing [perUnit] from
  /// its own pool. Distinct from [startDrill], which draws one topic.
  Future<void> startPractice({
    required ExamId examId,
    required List<PracticeUnit> units,
    required int perUnit,
  }) async {
    state = const QuizLoading();
    try {
      final now = _ref.read(nowProvider)();
      final result = await _ref.read(startPracticeProvider)(
        userId: _localUserId,
        examId: examId,
        units: units,
        perUnit: perUnit,
        now: now,
      );
      switch (result) {
        case StartPracticeStarted(:final session):
          state = QuizRunning(
            session: session,
            questionShownAt: now,
            persisted: true,
          );
        case StartPracticeNoQuestions(:final message):
          state = QuizFailure(message);
      }
    } catch (e) {
      state = QuizFailure(e.toString());
    }
  }

  Future<void> startPracticeFromQuestionIds({
    required ExamId examId,
    required List<QuestionId> questionIds,
  }) async {
    state = const QuizLoading();
    try {
      final now = _ref.read(nowProvider)();
      final result = await _ref.read(startPracticeProvider).fromQuestionIds(
            userId: _localUserId,
            examId: examId,
            questionIds: questionIds,
            now: now,
          );
      switch (result) {
        case StartPracticeStarted(:final session):
          state = QuizRunning(
            session: session,
            questionShownAt: now,
            persisted: true,
          );
        case StartPracticeNoQuestions(:final message):
          state = QuizFailure(message);
      }
    } catch (e) {
      state = QuizFailure(e.toString());
    }
  }

  Future<void> startDrill({
    required ExamId examId,
    required TopicId topicId,
    int requestedLength = 10,
  }) async {
    state = const QuizLoading();
    try {
      final now = _ref.read(nowProvider)();
      final result = await _ref.read(startDrillProvider)(
        userId: _localUserId,
        examId: examId,
        topicId: topicId,
        requestedLength: requestedLength,
        now: now,
      );
      switch (result) {
        case StartDrillStarted(:final session):
          state = QuizRunning(
            session: session,
            questionShownAt: now,
            persisted: true,
          );
        case StartDrillNoQuestions(:final message):
          state = QuizFailure(message);
      }
    } catch (e) {
      state = QuizFailure(e.toString());
    }
  }

  Future<void> startRetake({required ExamId examId}) async {
    state = const QuizLoading();
    try {
      final now = _ref.read(nowProvider)();
      final result = await _ref.read(startRetakeProvider)(
        userId: _localUserId,
        examId: examId,
        now: now,
      );
      switch (result) {
        case StartRetakeStarted(:final session):
          state = QuizRunning(
            session: session,
            questionShownAt: now,
            persisted: true,
          );
        case StartRetakeNoQuestions(:final message):
          state = QuizFailure(message);
      }
    } catch (e) {
      state = QuizFailure(e.toString());
    }
  }

  Future<void> startInline({
    required ExamId examId,
    required LessonId lessonId,
  }) async {
    state = const QuizLoading();
    try {
      final now = _ref.read(nowProvider)();
      final result = await _ref.read(startInlineLessonQuizProvider)(
        userId: _localUserId,
        examId: examId,
        lessonId: lessonId,
        now: now,
      );
      switch (result) {
        case StartInlineLessonQuizStarted(:final session):
          state = QuizRunning(
            session: session,
            questionShownAt: now,
            persisted: true,
          );
        case StartInlineLessonQuizNoQuestions(:final message):
          state = QuizFailure(message);
      }
    } catch (e) {
      state = QuizFailure(e.toString());
    }
  }

  Future<void> answer({required ChoiceId chosenChoiceId}) async {
    final s = state;
    if (s is! QuizRunning) {
      throw StateError('answer() called when controller is not running');
    }
    final now = _ref.read(nowProvider)();
    final responseMs = now.difference(s.questionShownAt).inMilliseconds;

    final outcome = await _ref.read(submitAnswerProvider)(
      question: s.session.currentQuestion,
      chosenChoiceId: chosenChoiceId,
      responseMs: responseMs,
      now: now,
      sessionId: s.persisted ? s.session.sessionId : null,
      userId: s.persisted ? _localUserId : null,
      examId: s.persisted ? s.session.examId : null,
    );

    // The answer is written now, and the session stays where it is so the
    // reveal can be read. Nothing about the attempt or the scheduler waits
    // for the student to move on.
    state = QuizRunning(
      session: s.session.record(outcome),
      questionShownAt: s.questionShownAt,
      persisted: s.persisted,
    );
  }

  /// Leaves the reveal for the next question, or ends the session when the
  /// last one has been answered.
  Future<void> next() async {
    final s = state;
    if (s is! QuizRunning) {
      throw StateError('next() called when controller is not running');
    }
    if (s.session.currentOutcome == null) return;

    if (s.session.isComplete) {
      final now = _ref.read(nowProvider)();
      final attempt = await _ref.read(completeQuizProvider)(
        session: s.session,
        now: now,
      );
      state = QuizComplete(attempt: attempt, session: s.session);
      return;
    }

    state = QuizRunning(
      session: s.session.advance(),
      questionShownAt: _ref.read(nowProvider)(),
      persisted: s.persisted,
    );
  }

  /// Moves to a question the student has already reached.
  ///
  /// Read only, and it needs no storage: the session already holds every
  /// answer in order. Anything past the answered run is refused, because
  /// jumping ahead would skip questions the scheduler has not been told
  /// about.
  Future<void> goTo(int index) async {
    final s = state;
    if (s is! QuizRunning) return;
    if (index < 0 || index > s.session.outcomes.length) return;
    if (index >= s.session.questions.length) return;

    state = QuizRunning(
      session: s.session.copyWith(currentIndex: index),
      questionShownAt: _ref.read(nowProvider)(),
      persisted: s.persisted,
    );
  }

  void reset() => state = const QuizIdle();
}

const _localUserId = 'local';
