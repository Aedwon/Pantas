import 'package:cse_cet_reviewer/core/fsrs/fsrs_scheduler.dart';
import 'package:cse_cet_reviewer/core/storage/domain/attempt.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:cse_cet_reviewer/features/quiz/data/repos/quiz_preferences_repository.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/quiz_session.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/use_cases/complete_quiz.dart';
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
  const QuizRunning({required this.session, required this.questionShownAt});
  final QuizSession session;
  final DateTime questionShownAt;
}

class QuizComplete extends QuizControllerState {
  const QuizComplete(this.attempt);
  final Attempt attempt;
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

final submitAnswerProvider = Provider<SubmitAnswer>(
  (ref) => SubmitAnswer(
    reviewRepo: ref.watch(reviewStateRepositoryProvider),
    scheduler: ref.watch(fsrsSchedulerProvider),
  ),
);

final completeQuizProvider = Provider<CompleteQuiz>(
  (ref) => CompleteQuiz(ref.watch(attemptsRepositoryProvider)),
);

final quizPreferencesRepositoryProvider = Provider<QuizPreferencesRepository>(
  (ref) => QuizPreferencesRepository(ref.watch(appDatabaseProvider)),
);

final quizSessionRepositoryProvider = Provider<QuizSessionRepository>(
  (ref) => QuizSessionRepository(ref.watch(appDatabaseProvider)),
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
    );

    final updated = s.session.record(outcome);
    if (updated.isComplete) {
      final attempt =
          await _ref.read(completeQuizProvider)(session: updated, now: now);
      state = QuizComplete(attempt);
    } else {
      state = QuizRunning(session: updated, questionShownAt: now);
    }
  }

  void reset() => state = const QuizIdle();
}
