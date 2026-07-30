import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/fsrs/fsrs_scheduler.dart';
import 'package:pantas/core/notifications/notification_service.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/engine/pending_queue.dart';
import 'package:pantas/features/quiz/data/repos/new_card_intro_repository.dart';
import 'package:pantas/features/quiz/data/repos/quiz_preferences_repository.dart';
import 'package:pantas/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:pantas/features/quiz/domain/streak/streak_evaluator.dart';
import 'package:pantas/features/quiz/domain/use_cases/complete_quiz.dart';
import 'package:pantas/features/quiz/domain/use_cases/quit_session.dart';
import 'package:pantas/features/quiz/domain/use_cases/restart_session.dart';
import 'package:pantas/features/quiz/domain/use_cases/resume_session.dart';
import 'package:pantas/features/quiz/domain/use_cases/start_drill.dart';
import 'package:pantas/features/quiz/domain/use_cases/start_inline_lesson_quiz.dart';
import 'package:pantas/features/quiz/domain/use_cases/start_practice.dart';
import 'package:pantas/features/quiz/domain/use_cases/start_quick_quiz.dart';
import 'package:pantas/features/quiz/domain/use_cases/start_retake.dart';
import 'package:pantas/features/quiz/domain/use_cases/start_today_session.dart';
import 'package:pantas/features/quiz/domain/use_cases/submit_answer.dart';

/// The quiz feature's wiring: every use case and repository the quiz builds
/// on, and the clock they read.
///
/// It lives beside the feature rather than inside its screens because Home
/// starts a session too, and a screen may not reach into another feature's
/// presentation.

final startPracticeProvider = Provider<StartPractice>(
  (ref) => StartPractice(
    content: ref.watch(contentRepositoryProvider),
    sessions: ref.watch(quizSessionRepositoryProvider),
    attempts: ref.watch(attemptsRepositoryProvider),
  ),
);

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
    telemetry: ref.watch(telemetryProvider),
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
    notifications: ref.watch(notificationServiceProvider),
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
