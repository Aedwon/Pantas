import 'package:cse_cet_reviewer/core/fsrs/fsrs_scheduler.dart';
import 'package:cse_cet_reviewer/core/storage/domain/attempt.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/sync/engine/pending_queue.dart';
import 'package:cse_cet_reviewer/features/quiz/data/repos/new_card_intro_repository.dart';
import 'package:cse_cet_reviewer/features/quiz/data/repos/quiz_preferences_repository.dart';
import 'package:cse_cet_reviewer/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/quiz_session.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/streak/streak_evaluator.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/complete_quiz.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/quit_session.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/restart_session.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/resume_session.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/start_drill.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/start_inline_lesson_quiz.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/start_quick_quiz.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/start_retake.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/start_today_session.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/submit_answer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

DateTime _nowUtc() => DateTime.now();

final nowProvider = Provider<DateTime Function()>((_) => _nowUtc);

final fsrsSchedulerProvider =
    Provider<FsrsScheduler>((_) => const FsrsScheduler());

final startQuickQuizProvider = Provider<StartQuickQuiz>(
  (ref) => StartQuickQuiz(ref.watch(contentRepositoryProvider)),
);

final startTodaySessionProvider = Provider<StartTodaySession>(
  (ref) => StartTodaySession(
    content: ref.watch(contentRepositoryProvider),
    sessions: ref.watch(quizSessionRepositoryProvider),
  ),
);

final startDrillProvider = Provider<StartDrill>(
  (ref) => StartDrill(
    content: ref.watch(contentRepositoryProvider),
    sessions: ref.watch(quizSessionRepositoryProvider),
  ),
);

final startRetakeProvider = Provider<StartRetake>(
  (ref) => StartRetake(
    content: ref.watch(contentRepositoryProvider),
    attempts: ref.watch(attemptsRepositoryProvider),
    sessions: ref.watch(quizSessionRepositoryProvider),
  ),
);

final startInlineLessonQuizProvider = Provider<StartInlineLessonQuiz>(
  (ref) => StartInlineLessonQuiz(
    content: ref.watch(contentRepositoryProvider),
    sessions: ref.watch(quizSessionRepositoryProvider),
  ),
);

final resumeSessionProvider = Provider<ResumeSession>(
  (ref) => ResumeSession(
    content: ref.watch(contentRepositoryProvider),
    sessions: ref.watch(quizSessionRepositoryProvider),
  ),
);

final quitSessionProvider = Provider<QuitSession>(
  (ref) => QuitSession(ref.watch(quizSessionRepositoryProvider)),
);

final restartSessionProvider = Provider<RestartSession>(
  (ref) => RestartSession(
    content: ref.watch(contentRepositoryProvider),
    sessions: ref.watch(quizSessionRepositoryProvider),
  ),
);

final submitAnswerProvider = Provider<SubmitAnswer>(
  (ref) => SubmitAnswer(
    reviewRepo: ref.watch(reviewStateRepositoryProvider),
    scheduler: ref.watch(fsrsSchedulerProvider),
    sessions: ref.watch(quizSessionRepositoryProvider),
    pendingQueue: ref.watch(pendingQueueProvider),
    newCards: ref.watch(newCardIntroRepositoryProvider),
  ),
);

final streakEvaluatorProvider = Provider<StreakEvaluator>(
  (ref) => StreakEvaluator(ref.watch(streakRepositoryProvider)),
);

final completeQuizProvider = Provider<CompleteQuiz>(
  (ref) => CompleteQuiz(
    ref.watch(attemptsRepositoryProvider),
    streakEvaluator: ref.watch(streakEvaluatorProvider),
    pendingQueue: ref.watch(pendingQueueProvider),
  ),
);

final pendingQueueProvider = Provider<PendingQueue>(
  (ref) => PendingQueue(ref.watch(appDatabaseProvider)),
);

final quizPreferencesRepositoryProvider = Provider<QuizPreferencesRepository>(
  (ref) => QuizPreferencesRepository(ref.watch(appDatabaseProvider)),
);

final quizSessionRepositoryProvider = Provider<QuizSessionRepository>(
  (ref) => QuizSessionRepository(ref.watch(appDatabaseProvider)),
);

final newCardIntroRepositoryProvider = Provider<NewCardIntroRepository>(
  (ref) => NewCardIntroRepository(ref.watch(appDatabaseProvider)),
);

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

    final updated = s.session.record(outcome);
    if (updated.isComplete) {
      final attempt =
          await _ref.read(completeQuizProvider)(session: updated, now: now);
      state = QuizComplete(attempt: attempt, session: updated);
    } else {
      state = QuizRunning(
        session: updated,
        questionShownAt: now,
        persisted: s.persisted,
      );
    }
  }

  void reset() => state = const QuizIdle();
}

const _localUserId = 'local';
