import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart'
    show appDatabaseProvider, contentRepositoryProvider;
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/features/quiz/application/quiz_launch_coordinator.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/quiz/application/today_quiz_preparer.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/domain/picker/practice_selection.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/domain/use_cases/build_today_plan.dart';
import 'package:pantas/features/quiz/domain/use_cases/start_drill.dart';
import 'package:pantas/features/quiz/domain/use_cases/start_inline_lesson_quiz.dart';
import 'package:pantas/features/quiz/domain/use_cases/start_practice.dart';
import 'package:pantas/features/quiz/domain/use_cases/start_retake.dart';

// Re-exported so the thirteen files that reach for the quiz's wiring through
// the controller keep working; the wiring itself now lives in application/.
export 'package:pantas/features/quiz/application/quiz_providers.dart';

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
    this.questionShownAt,
    this.persisted = false,
    this.selectedChoiceId,
    this.checking = false,
  });
  final QuizSession session;
  final DateTime? questionShownAt;
  final bool persisted;
  final ChoiceId? selectedChoiceId;
  final bool checking;
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

  String? _preparedSessionId;
  int? _preparedQuestionIndex;

  Future<void> start({
    required ExamId examId,
    TopicId? topicId,
    int count = 10,
    int? randomSeed,
  }) async {
    if (!mounted) return;
    state = const QuizLoading();
    try {
      final guard = await captureLaunchGuard(examId: examId);
      final startedAt = _ref.read(nowProvider)();
      final session = await _ref.read(startQuickQuizProvider)(
        examId: examId,
        topicId: topicId,
        count: count,
        now: startedAt,
        randomSeed: randomSeed,
      );
      final sessions = _ref.read(quizSessionRepositoryProvider);
      final created = await sessions.createGuarded(
        sessionId: session.sessionId,
        userId: quizLocalUserId,
        examId: examId,
        origin: session.origin,
        questionIds: session.questions.map((q) => q.id).toList(),
        startedAt: session.startedAt,
        topicId: topicId,
        canPersist: () async {
          if (!await guard()) return false;
          final active = await sessions.activeFor(
            userId: quizLocalUserId,
            examId: examId,
          );
          // Quick launch must never silently discard a different paused quiz.
          return (active == null || active.id == session.sessionId) &&
              await guard();
        },
      );
      if (!created || !await guard()) {
        throw StateError('Quick quiz launch is no longer available');
      }
      state = QuizRunning(session: session, persisted: true);
    } catch (e) {
      if (mounted) state = QuizFailure(e.toString());
    }
  }

  Future<void> startToday({
    required ExamId examId,
    TopicId? topicId,
    TodaySessionPlan? plan,
    PreparedTodaySession? prepared,
  }) async {
    state = const QuizLoading();
    try {
      final request = QuizPreparationRequest(
        userId: quizLocalUserId,
        examId: examId,
        topicId: topicId,
      );
      final result = await _ref.read(quizLaunchCoordinatorProvider).launchToday(
            request,
            prepared: prepared,
          );
      switch (result) {
        case QuizLaunchStarted(:final session):
          state = QuizRunning(
            session: session,
            persisted: true,
          );
        case QuizLaunchNoQuestions(:final message):
          state = QuizFailure(message);
        case QuizLaunchCancelled(:final persistedSession):
          if (persistedSession == null) {
            state = const QuizIdle();
          } else {
            state = QuizRunning(
              session: persistedSession,
              persisted: true,
            );
          }
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
      final session =
          await _ref.read(quizLaunchCoordinatorProvider).resumeToday(
                QuizPreparationRequest(
                  userId: quizLocalUserId,
                  examId: examId,
                ),
              );
      if (session == null) {
        state = const QuizFailure('There is no session to pick up.');
        return;
      }
      state = QuizRunning(
        session: session,
        persisted: true,
      );
    } catch (e) {
      state = QuizFailure(e.toString());
    }
  }

  /// Captures the original launch owner before UI/content waits. Callers pass
  /// the returned predicate unchanged; old requests cannot rebind it.
  Future<Future<bool> Function()> captureLaunchGuard({
    required ExamId examId,
  }) async {
    if (!mounted) {
      throw StateError('Quiz controller is unavailable');
    }
    final db = _ref.read(appDatabaseProvider);
    final preparer = _ref.read(todayQuizPreparerProvider);
    final lifetime = preparer.accountLifetimeToken;
    final auth = _ref.read(authStateProvider).unwrapPrevious().asData?.value;
    final uid = switch (auth) {
      AnonymousAuthState(:final uid) => uid,
      SignedInAuthState(:final user) => user.uid,
      _ => null,
    };
    bool current() =>
        mounted &&
        lifetime != null &&
        uid != null &&
        identical(_ref.read(appDatabaseProvider), db) &&
        identical(_ref.read(todayQuizPreparerProvider), preparer) &&
        preparer.accountLifetimeToken == lifetime &&
        _ref.read(authStateProvider).unwrapPrevious().asData?.value == auth &&
        _ref
                .read(activeExamFocusProvider)
                .unwrapPrevious()
                .asData
                ?.value
                .exam
                ?.id ==
            examId;
    if (!current()) throw StateError('Quiz account is unavailable');
    final contexts = SyncActiveContextStore(db);
    final original = await contexts.readSnapshot();
    if (!current() ||
        (original?.context != null && original!.context!.uid != uid)) {
      throw StateError('Quiz account changed');
    }
    return () async {
      if (!current()) return false;
      final snapshot = await contexts.readSnapshot();
      return current() && snapshot?.token == original?.token;
    };
  }

  /// One session built from many picked units, each drawing [perUnit] from
  /// its own pool. Distinct from [startDrill], which draws one topic.
  Future<void> startPractice({
    required ExamId examId,
    required List<PracticeUnit> units,
    required int perUnit,
    Map<String, int> countsByUnit = const {},
    Future<bool> Function()? canPersist,
  }) async {
    if (!mounted) return;
    state = const QuizLoading();
    try {
      final guard = canPersist ?? await captureLaunchGuard(examId: examId);
      if (!await guard()) throw StateError('Quiz account changed');
      final now = _ref.read(nowProvider)();
      final result = await _ref.read(startPracticeProvider)(
        userId: quizLocalUserId,
        examId: examId,
        units: units,
        perUnit: perUnit,
        countsByUnit: countsByUnit,
        now: now,
        canPersist: guard,
      );
      if (!await guard()) throw StateError('Quiz account changed');
      switch (result) {
        case StartPracticeStarted(:final session):
          state = QuizRunning(
            session: session,
            persisted: true,
          );
        case StartPracticeNoQuestions(:final message):
          state = QuizFailure(message);
      }
    } catch (e) {
      if (mounted) state = QuizFailure(e.toString());
    }
  }

  Future<void> startPracticeFromQuestionIds({
    required ExamId examId,
    required List<QuestionId> questionIds,
    SessionOrigin origin = SessionOrigin.drill,
    Future<bool> Function()? canPersist,
  }) async {
    if (!mounted) return;
    state = const QuizLoading();
    try {
      final guard = canPersist ??
          (origin == SessionOrigin.flagged
              ? await captureLaunchGuard(examId: examId)
              : null);
      if (guard != null && !await guard()) {
        throw StateError('Flagged quiz account changed');
      }
      final now = _ref.read(nowProvider)();
      final result = await _ref.read(startPracticeProvider).fromQuestionIds(
            userId: quizLocalUserId,
            examId: examId,
            questionIds: questionIds,
            origin: origin,
            now: now,
            canPersist: guard,
          );
      if (guard != null && !await guard()) {
        throw StateError('Flagged quiz account changed');
      }
      switch (result) {
        case StartPracticeStarted(:final session):
          state = QuizRunning(
            session: session,
            persisted: true,
          );
        case StartPracticeNoQuestions(:final message):
          state = QuizFailure(message);
      }
    } catch (e) {
      if (mounted) state = QuizFailure(e.toString());
    }
  }

  /// Explicit continuation retains the completed screen until a real next row
  /// commits. A repeated call preserves any pick already made on that row.
  Future<void> continueReviews(QuizSession completed) async {
    if (!mounted || completed.reviewBatch == null || !completed.isComplete) {
      throw StateError('Completed Reviews session is unavailable');
    }
    final originalState = state;
    final position = completed.reviewBatch!;
    final db = _ref.read(appDatabaseProvider);
    final preparer = _ref.read(todayQuizPreparerProvider);
    final lifetime = preparer.accountLifetimeToken;
    final auth = _ref.read(authStateProvider).unwrapPrevious().asData?.value;
    final uid = switch (auth) {
      AnonymousAuthState(:final uid) => uid,
      SignedInAuthState(:final user) => user.uid,
      _ => null,
    };
    bool current() {
      if (!mounted) return false;
      final visible = state;
      final sameNext = visible is QuizRunning &&
          visible.session.reviewBatch?.batchId == position.batchId &&
          visible.session.reviewBatch?.ordinal == position.ordinal + 1;
      return (identical(visible, originalState) || sameNext) &&
          uid != null &&
          lifetime != null &&
          identical(_ref.read(appDatabaseProvider), db) &&
          identical(_ref.read(todayQuizPreparerProvider), preparer) &&
          preparer.accountLifetimeToken == lifetime &&
          _ref.read(authStateProvider).unwrapPrevious().asData?.value == auth &&
          _ref
                  .read(activeExamFocusProvider)
                  .unwrapPrevious()
                  .asData
                  ?.value
                  .exam
                  ?.id ==
              completed.examId;
    }

    if (!current()) throw StateError('Reviews account is unavailable');
    final contexts = SyncActiveContextStore(db);
    final original = await contexts.readSnapshot();
    if (!current() ||
        (original?.context != null && original!.context!.uid != uid)) {
      throw StateError('Reviews account changed');
    }
    Future<bool> valid() async {
      if (!current()) return false;
      final snapshot = await contexts.readSnapshot();
      return current() && snapshot?.token == original?.token;
    }

    final batches = _ref.read(quizReviewBatchRepositoryProvider);
    final scope = batches.capture(quizLocalUserId, completed.examId);
    if (scope == null) throw StateError('Reviews account changed');
    final content = _ref.read(contentRepositoryProvider);
    final now = _ref.read(nowProvider)();
    final claimed = await batches.continueBatch(
      scope: scope,
      content: content,
      now: now,
      canPersist: valid,
      after: completed,
    );
    if (claimed == null || !await valid()) {
      throw StateError('Reviews account changed');
    }
    final visible = state;
    if (visible is QuizRunning &&
        visible.session.sessionId == claimed.session.sessionId) {
      return;
    }
    clearQuestionPreparation();
    state = QuizRunning(session: claimed.session, persisted: true);
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
        userId: quizLocalUserId,
        examId: examId,
        topicId: topicId,
        requestedLength: requestedLength,
        now: now,
      );
      switch (result) {
        case StartDrillStarted(:final session):
          state = QuizRunning(
            session: session,
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
        userId: quizLocalUserId,
        examId: examId,
        now: now,
      );
      switch (result) {
        case StartRetakeStarted(:final session):
          state = QuizRunning(
            session: session,
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
        userId: quizLocalUserId,
        examId: examId,
        lessonId: lessonId,
        now: now,
      );
      switch (result) {
        case StartInlineLessonQuizStarted(:final session):
          state = QuizRunning(
            session: session,
            persisted: true,
          );
        case StartInlineLessonQuizNoQuestions(:final message):
          state = QuizFailure(message);
      }
    } catch (e) {
      state = QuizFailure(e.toString());
    }
  }

  void markQuestionReady({
    required String sessionId,
    required int questionIndex,
  }) {
    final s = state;
    if (s is! QuizRunning ||
        s.session.sessionId != sessionId ||
        s.session.currentIndex != questionIndex ||
        s.session.currentOutcome != null ||
        s.questionShownAt != null) {
      return;
    }

    state = QuizRunning(
      session: s.session,
      questionShownAt: _ref.read(nowProvider)(),
      persisted: s.persisted,
    );
  }

  void markQuestionPrepared({
    required String sessionId,
    required int questionIndex,
  }) {
    final s = state;
    if (s is! QuizRunning ||
        s.session.sessionId != sessionId ||
        questionIndex != s.session.currentIndex + 1 ||
        questionIndex >= s.session.questions.length) {
      return;
    }

    _preparedSessionId = sessionId;
    _preparedQuestionIndex = questionIndex;
  }

  void clearQuestionPreparation() {
    _preparedSessionId = null;
    _preparedQuestionIndex = null;
  }

  void pick({required ChoiceId chosenChoiceId}) {
    final s = state;
    if (s is! QuizRunning ||
        s.questionShownAt == null ||
        s.checking ||
        s.session.currentOutcome != null ||
        !s.session.currentQuestion.choices.any((c) => c.id == chosenChoiceId)) {
      return;
    }
    state = QuizRunning(
      session: s.session,
      questionShownAt: s.questionShownAt,
      persisted: s.persisted,
      selectedChoiceId: chosenChoiceId,
    );
  }

  // Retained for the old renderer until its Task 9 removal.
  Future<void> answer({required ChoiceId chosenChoiceId}) async {
    final s = state;
    if (s is! QuizRunning) {
      throw StateError('answer() called when controller is not running');
    }
    final questionShownAt = s.questionShownAt;
    if (questionShownAt == null) {
      throw StateError('answer() called before the question is ready');
    }
    pick(chosenChoiceId: chosenChoiceId);
    await check();
  }

  Future<void> check() async {
    final s = state;
    if (s is! QuizRunning ||
        s.checking ||
        s.session.currentOutcome != null ||
        s.selectedChoiceId == null ||
        s.questionShownAt == null) {
      return;
    }
    state = QuizRunning(
      session: s.session,
      questionShownAt: s.questionShownAt,
      persisted: s.persisted,
      selectedChoiceId: s.selectedChoiceId,
      checking: true,
    );
    final now = _ref.read(nowProvider)();
    final responseMs = now.difference(s.questionShownAt!).inMilliseconds;

    try {
      final outcome = await _ref.read(submitAnswerProvider)(
        question: s.session.currentQuestion,
        chosenChoiceId: s.selectedChoiceId!,
        responseMs: responseMs,
        now: now,
        sessionId: s.persisted ? s.session.sessionId : null,
        userId: s.persisted ? quizLocalUserId : null,
        examId: s.persisted ? s.session.examId : null,
        origin: s.session.origin.storageValue,
      );

      if (!mounted) return;
      final current = state;
      if (current is! QuizRunning || !identical(current.session, s.session)) {
        return;
      }
      state = QuizRunning(
        session: s.session.record(outcome),
        questionShownAt: s.questionShownAt,
        persisted: s.persisted,
      );
    } catch (_) {
      if (mounted) {
        final current = state;
        if (current is QuizRunning && identical(current.session, s.session)) {
          state = QuizRunning(
            session: s.session,
            questionShownAt: s.questionShownAt,
            persisted: s.persisted,
            selectedChoiceId: s.selectedChoiceId,
          );
        }
      }
      rethrow;
    }
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
      clearQuestionPreparation();
      final attempt =
          await _ref.read(quizCompletionCoordinatorProvider).complete(
                session: s.session,
                now: _ref.read(nowProvider)(),
                persisted: s.persisted,
              );
      state = QuizComplete(attempt: attempt, session: s.session);
      return;
    }

    final nextIndex = s.session.currentIndex + 1;
    final prepared = _preparedSessionId == s.session.sessionId &&
        _preparedQuestionIndex == nextIndex;
    clearQuestionPreparation();

    state = QuizRunning(
      session: s.session.advance(),
      questionShownAt: prepared ? _ref.read(nowProvider)() : null,
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
    clearQuestionPreparation();
    if (s is! QuizRunning || s.checking) return;
    if (index < 0 || index > s.session.outcomes.length) return;
    if (index >= s.session.questions.length) return;

    state = QuizRunning(
      session: s.session.copyWith(currentIndex: index),
      persisted: s.persisted,
    );
  }

  void reset() {
    clearQuestionPreparation();
    state = const QuizIdle();
  }
}
