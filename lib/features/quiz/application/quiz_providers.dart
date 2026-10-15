import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content_seed_version.dart';
import 'package:pantas/core/fsrs/fsrs_scheduler.dart';
import 'package:pantas/core/notifications/notification_service.dart';
import 'package:pantas/core/storage/data/repos/review_log_repository.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/domain/question_selection_row.dart';
import 'package:pantas/core/storage/domain/topic.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/features/quiz/application/quiz_completion_coordinator.dart';
import 'package:pantas/features/quiz/application/quiz_launch_coordinator.dart';
import 'package:pantas/features/quiz/application/quiz_performance_probe.dart';
import 'package:pantas/features/quiz/application/quiz_preparation_stamp.dart';
import 'package:pantas/features/quiz/application/today_quiz_preparer.dart';
import 'package:pantas/features/quiz/data/repos/new_card_intro_repository.dart';
import 'package:pantas/features/quiz/data/repos/quiz_preferences_repository.dart';
import 'package:pantas/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:pantas/features/quiz/data/repos/review_batch_repository.dart';
import 'package:pantas/features/quiz/domain/models/quiz_ordering.dart';
import 'package:pantas/features/quiz/domain/models/quiz_preferences.dart';
import 'package:pantas/features/quiz/domain/models/review_batch.dart';
import 'package:pantas/features/quiz/domain/models/topic_queue_row.dart';
import 'package:pantas/features/quiz/domain/streak/streak_evaluator.dart';
import 'package:pantas/features/quiz/domain/use_cases/build_today_plan.dart';
import 'package:pantas/features/quiz/domain/use_cases/build_today_queue.dart';
import 'package:pantas/features/quiz/domain/use_cases/count_today_backlog.dart';
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
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';
import 'package:pantas/features/roadmap/domain/day_snapshot.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';
import 'package:pantas/features/roadmap/domain/roadmap_inputs.dart';
import 'package:pantas/features/roadmap/domain/sitting_planner.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:pantas/features/settings/domain/session_ordering.dart';

/// The local durable quiz identity. All local Today launch owners use this
/// value so Home, the Quiz tab, and the controller cannot split one user into
/// parallel session namespaces.
const quizLocalUserId = 'local';

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
    reviews: ref.watch(reviewStateRepositoryProvider),
  ),
);

DateTime _nowUtc() => DateTime.now();

final nowProvider = Provider<DateTime Function()>((_) => _nowUtc);

final quizPerformanceProbeProvider = Provider<QuizPerformanceProbe>(
  (_) => const QuizPerformanceProbe.disabled(),
);

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
    newCards: ref.watch(newCardIntroRepositoryProvider),
    reviewLog: ReviewLogRepository(ref.watch(appDatabaseProvider)),
    telemetry: ref.watch(telemetryProvider),
  ),
);

final streakEvaluatorProvider = Provider<StreakEvaluator>(
  (ref) => StreakEvaluator(
    ref.watch(streakRepositoryProvider),
    studyDaysReader: () async =>
        (await ref.read(userSettingsProvider.future)).studyDays,
  ),
);

final quizPreferencesRepositoryProvider = Provider<QuizPreferencesRepository>(
  (ref) => QuizPreferencesRepository(ref.watch(appDatabaseProvider)),
);

final quizSessionRepositoryProvider = Provider<QuizSessionRepository>(
  (ref) => QuizSessionRepository(
    ref.watch(appDatabaseProvider),
    reviewBatches: ref.watch(quizReviewBatchRepositoryProvider),
  ),
);

final quizReviewBatchRepositoryProvider = Provider<ReviewBatchRepository>(
  (ref) => ReviewBatchRepository(
    ref.watch(appDatabaseProvider),
    currentScope: (userId, examId) {
      if (userId != quizLocalUserId) return null;
      final auth = ref.read(authStateProvider).valueOrNull;
      final token = ref.read(todayQuizPreparerProvider).accountLifetimeToken;
      if (auth == null ||
          token == null ||
          auth is UnknownAuthState ||
          auth is SignedOutAuthState) {
        return null;
      }
      final selectedExam = ref.read(activeExamFocusProvider).valueOrNull?.exam;
      if (selectedExam != null && selectedExam.id != examId) return null;
      return ReviewBatchScope(
        userId: userId,
        examId: examId,
        principal: _authToken(auth),
        accountLifetimeToken: token,
      );
    },
  ),
);

final newCardIntroRepositoryProvider = Provider<NewCardIntroRepository>(
  (ref) => NewCardIntroRepository(ref.watch(appDatabaseProvider)),
);

final todayQuizPreparerProvider = Provider<TodayQuizPreparer>((ref) {
  var accountLifetimeGeneration = 0;
  late final TodayQuizPreparer preparer;
  preparer = TodayQuizPreparer(
    readStamp: (request) => _readPreparationStamp(
      ref,
      request,
      accountLifetimeGeneration: accountLifetimeGeneration,
    ),
    buildPlan: (request) => _buildTodayPlan(ref, request),
    now: ref.watch(nowProvider),
    readAccountLifetimeToken: () {
      final auth = ref.read(authStateProvider).valueOrNull;
      return auth == null
          ? null
          : '${_authToken(auth)}:$accountLifetimeGeneration';
    },
  );

  ref.listen(authStateProvider, (previous, next) {
    if (previous == null || previous == next) return;
    accountLifetimeGeneration += 1;
    preparer.invalidateAll();
  });
  return preparer;
});

final quizLaunchCoordinatorProvider = Provider<QuizLaunchCoordinator>((ref) {
  return QuizLaunchCoordinator(
    preparer: ref.watch(todayQuizPreparerProvider),
    readActive: (request) => ref.read(resumeSessionProvider)(
      userId: request.userId,
      examId: request.examId,
    ),
    persist: ({
      required request,
      required prepared,
      required canPersist,
    }) async {
      if (!canPersist()) return null;
      final stamp = prepared.stamp;
      final preferences = QuizPreferences(
        sessionLength: stamp.sessionLength,
        ordering: _quizOrdering(stamp.ordering),
      );
      if (!canPersist()) return null;
      return ref.read(quizPerformanceProbeProvider).measureAsync(
            QuizPerformancePhase.sessionPersistence,
            () => ref.read(startTodaySessionProvider).callGuarded(
                  userId: request.userId,
                  examId: request.examId,
                  topicId: request.topicId,
                  preferences: preferences,
                  now: ref.read(nowProvider)(),
                  plan: prepared.plan,
                  canPersist: canPersist,
                ),
          );
    },
  );
});

final quizSessionPanelRevisionProvider =
    NotifierProvider<QuizSessionPanelRevision, int>(
  QuizSessionPanelRevision.new,
);

class QuizSessionPanelRevision extends Notifier<int> {
  @override
  int build() => 0;

  void publishCompletion() => state += 1;
}

final quizCompletionCoordinatorProvider = Provider<QuizCompletionCoordinator>(
  (ref) => QuizCompletionCoordinator(
    attempts: ref.watch(attemptsRepositoryProvider),
    sessions: ref.watch(quizSessionRepositoryProvider),
    streakEvaluator: ref.watch(streakEvaluatorProvider),
    notifications: ref.watch(notificationServiceProvider),
    onCommitted: () {
      ref.read(todayQuizPreparerProvider).invalidateAll();
      ref.read(quizLaunchCoordinatorProvider).clearAllCommitted();
      ref.read(quizSessionPanelRevisionProvider.notifier).publishCompletion();
    },
  ),
);

Future<TodaySessionPlan> _buildTodayPlan(
  Ref ref,
  QuizPreparationRequest request,
) async {
  final content = ref.read(contentRepositoryProvider);
  final now = ref.read(nowProvider)();
  final probe = ref.read(quizPerformanceProbeProvider);
  final scope = await probe.measureAsync(
    QuizPerformancePhase.scopeResolution,
    () => _readScope(ref, request.examId),
  );
  final topics = scope.topics;
  if (topics.isEmpty) return TodaySessionPlan.empty;

  if (request.topicId == null) {
    final today =
        await ref.read(roadmapControllerProvider).today(request.examId);
    if (today.state == RoadmapState.needsAssessment ||
        today.state == RoadmapState.noContent ||
        today.remaining.questionCount == 0) {
      return TodaySessionPlan.empty;
    }
    final topicIds = [for (final topic in topics) topic.id];
    final metadata = await probe.measureAsync(
      QuizPerformancePhase.metadataRead,
      () async => (
        questions: await content.selectionRowsByTopics(topicIds),
        lessons: await content.lessonMetaByTopics(topicIds),
      ),
    );
    final db = ref.read(appDatabaseProvider);
    final history = await probe.measureAsync(
      QuizPerformancePhase.historyRead,
      () async => (
        preferences: await ref.read(quizPreferencesRepositoryProvider).read(),
        lessons: await db.select(db.lessonProgressLocal).get(),
      ),
    );
    final ids = probe.measureSync(
      QuizPerformancePhase.selection,
      () => SittingPlanner.next(
        remaining: today.remaining,
        knownLessonIds: {
          for (final lessons in metadata.lessons.values)
            for (final lesson in lessons) lesson.id,
        },
        readLessonIds: {for (final lesson in history.lessons) lesson.lessonId},
        questionsById: {
          for (final rows in metadata.questions.values)
            for (final row in rows)
              row.id: RoadmapQuestion(
                id: row.id,
                topicId: row.topicId,
                lessonId: row.lessonId,
                passageId: row.passageId,
              ),
        },
        sessionLength: history.preferences.sessionLength,
        ordering: history.preferences.ordering,
        vocabularyTopicId: 'topic_upcat_vocabulary',
        rankedTopics: today.snapshot.topicOrder,
      ),
    );
    if (ids.isEmpty) return TodaySessionPlan.empty;
    final questions = await probe.measureAsync(
      QuizPerformancePhase.hydration,
      () => content.hydrateSelectedQuestions(ids),
    );
    if (questions.isEmpty) return TodaySessionPlan.empty;
    final dueIds = today.remaining.reviewQuestionIds.toSet();
    final newIds = today.remaining.newQuestionIds.toSet();
    final topicId = questions.first.topicId;
    return TodaySessionPlan(
      questions: questions,
      dueCount: questions.where((q) => dueIds.contains(q.id)).length,
      freshCount: questions.where((q) => newIds.contains(q.id)).length,
      weaknessCount: 0,
      topicId: topicId,
      topicName: topics.firstWhere((topic) => topic.id == topicId).name,
    );
  }

  final questionsByTopic = await probe.measureAsync(
    QuizPerformancePhase.metadataRead,
    () async {
      final rows = await content.selectionRowsByTopics(
        [for (final topic in topics) topic.id],
      );
      return <TopicId, List<Question>>{
        for (final entry in rows.entries)
          entry.key: [
            for (final row in entry.value)
              _selectionQuestion(row, request.examId),
          ],
      };
    },
  );
  final questionsById = <QuestionId, Question>{
    for (final questions in questionsByTopic.values)
      for (final question in questions) question.id: question,
  };

  final historyInputs = await probe.measureAsync(
    QuizPerformancePhase.historyRead,
    () async {
      final states = await ref.read(reviewStateRepositoryProvider).allStates();
      final outcomes =
          await ref.read(attemptsRepositoryProvider).questionOutcomes(
                examId: request.examId,
                now: now,
              );
      final preferences =
          await ref.read(quizPreferencesRepositoryProvider).read();
      return (
        states: states,
        outcomes: outcomes,
        preferences: preferences,
      );
    },
  );
  final states = historyInputs.states;
  final outcomes = historyInputs.outcomes;
  final preferences = historyInputs.preferences;
  final seenIds = {for (final state in states) state.questionId};
  final backlogByTopic = <TopicId, TopicBacklog>{};
  for (final topic in topics) {
    final backlog = CountTodayBacklog.forTopic(
      topicId: topic.id,
      questions: questionsByTopic[topic.id] ?? const [],
      states: states,
      questionsById: questionsById,
      outcomes: outcomes,
      capRemaining:
          preferences.sessionLength == QuizPreferences.allDueSessionLength
              ? (questionsByTopic[topic.id] ?? const [])
                  .where(
                    (question) => !seenIds.contains(question.id),
                  )
                  .length
              : preferences.sessionLength,
      now: now,
    );
    backlogByTopic[topic.id] = backlog;
  }

  final queue = BuildTodayQueue.call(
    topics: [
      for (final topic in topics)
        TopicQueueInput(topicId: topic.id, topicName: topic.name),
    ],
    dueCounts: {
      for (final entry in backlogByTopic.entries)
        entry.key: entry.value.due.length,
    },
    weaknessCounts: {
      for (final entry in backlogByTopic.entries)
        entry.key: entry.value.weakness.length,
    },
    newCounts: {
      for (final entry in backlogByTopic.entries)
        entry.key: entry.value.fresh.length,
    },
  );
  if (queue.isEmpty) return TodaySessionPlan.empty;

  TopicQueueRow? named;
  if (request.topicId == null) {
    named = queue.first;
  } else {
    for (final row in queue) {
      if (row.topicId == request.topicId) {
        named = row;
        break;
      }
    }
  }
  if (named == null || named.totalCount == 0) return TodaySessionPlan.empty;
  final selectedTopic = named;

  final poolBacklogs = backlogByTopic.values;
  final due = <Question>[];
  final weakness = <Question>[];
  final fresh = <Question>[];
  for (final backlog in poolBacklogs) {
    due.addAll(backlog.due);
    weakness.addAll(backlog.weakness);
    fresh.addAll(backlog.fresh);
  }
  final selectionPlan = probe.measureSync(
    QuizPerformancePhase.selection,
    () => BuildTodayPlan.call(
      due: due,
      weakness: weakness,
      fresh: fresh,
      allQuestions: [
        for (final questions in questionsByTopic.values) ...questions,
      ],
      preferences: preferences,
      topicId: selectedTopic.topicId,
      topicName: selectedTopic.topicName,
    ),
  );
  if (selectionPlan.isEmpty) return selectionPlan;

  final hydrated = await probe.measureAsync(
    QuizPerformancePhase.hydration,
    () => content.hydrateSelectedQuestions(
      [for (final question in selectionPlan.questions) question.id],
    ),
  );
  final hydratedIds = {for (final question in hydrated) question.id};
  final dueIds = {for (final question in due) question.id};
  final weaknessIds = {for (final question in weakness) question.id};
  final freshIds = {for (final question in fresh) question.id};
  return TodaySessionPlan(
    questions: hydrated,
    dueCount: hydratedIds.where(dueIds.contains).length,
    weaknessCount: hydratedIds.where(weaknessIds.contains).length,
    freshCount: hydratedIds.where(freshIds.contains).length,
    topicId: selectionPlan.topicId,
    topicName: selectionPlan.topicName,
  );
}

Future<QuizPreparationStamp> _readPreparationStamp(
  Ref ref,
  QuizPreparationRequest request, {
  required int accountLifetimeGeneration,
}) async {
  final now = ref.read(nowProvider)();
  final probe = ref.read(quizPerformanceProbeProvider);
  final scope = await probe.measureAsync(
    QuizPerformancePhase.scopeResolution,
    () => _readScope(ref, request.examId),
  );
  final content = ref.read(contentRepositoryProvider);
  final questionIds = await probe.measureAsync(
    QuizPerformancePhase.metadataRead,
    () async {
      final rows = await content.selectionRowsByTopics(
        [for (final topic in scope.topics) topic.id],
      );
      return {
        for (final topicRows in rows.values)
          for (final row in topicRows) row.id,
      };
    },
  );

  final historyInputs = await probe.measureAsync(
    QuizPerformancePhase.historyRead,
    () async {
      final preferences =
          await ref.read(quizPreferencesRepositoryProvider).read();
      final states = await ref.read(reviewStateRepositoryProvider).allStates();
      final outcomes =
          await ref.read(attemptsRepositoryProvider).questionOutcomes(
                examId: request.examId,
                now: now,
              );
      final db = ref.read(appDatabaseProvider);
      final readLessonIds = (request.topicId == null
          ? [
              for (final row in await db.select(db.lessonProgressLocal).get())
                row.lessonId,
            ]
          : <LessonId>[])
        ..sort();
      return (
        preferences: preferences,
        states: states,
        outcomes: outcomes,
        readLessonIds: readLessonIds,
      );
    },
  );
  final preferences = historyInputs.preferences;
  final states = historyInputs.states;
  final relevantStates = [
    for (final state in states)
      if (questionIds.contains(state.questionId)) state,
  ]..sort((a, b) => a.questionId.compareTo(b.questionId));
  final outcomes = historyInputs.outcomes;
  final outcomeIds = outcomes.keys.where(questionIds.contains).toList()..sort();

  final history = StringBuffer();
  for (final state in relevantStates) {
    history
      ..write(state.questionId)
      ..write(':')
      ..write(state.questionVersion)
      ..write(':')
      ..write(state.stage.name)
      ..write(':')
      ..write(state.stability)
      ..write(':')
      ..write(state.difficulty)
      ..write(':')
      ..write(state.due.microsecondsSinceEpoch)
      ..write(':')
      ..write(state.lastReview.microsecondsSinceEpoch)
      ..write(':')
      ..write(state.reps)
      ..write(':')
      ..write(state.lapses)
      ..write(';');
  }
  for (final id in outcomeIds) {
    final outcome = outcomes[id]!;
    history
      ..write(id)
      ..write('=')
      ..write(outcome.attempts)
      ..write('/')
      ..write(outcome.correct)
      ..write(';');
  }

  // Reading a planned lesson can change which new questions enter the sitting.
  // Keep cached preparation fresh even when the day's snapshot stays fixed.
  for (final id in historyInputs.readLessonIds) {
    history
      ..write('read-lesson=')
      ..write(id)
      ..write(';');
  }

  DateTime? nextDueExpiry;
  for (final state in relevantStates) {
    if (!state.due.isAfter(now)) continue;
    if (nextDueExpiry == null || state.due.isBefore(nextDueExpiry)) {
      nextDueExpiry = state.due;
    }
  }

  final active = await ref.read(quizSessionRepositoryProvider).activeFor(
        userId: request.userId,
        examId: request.examId,
      );
  final sessionRevision = active == null
      ? 'none'
      : '${active.id}|${active.currentIndex}|${active.questionIdsJson}|'
          '${active.topicId ?? ''}';

  final authState = await ref.read(authStateProvider.future);
  final installedContentRevision = await ref
      .read(appPreferencesRepositoryProvider)
      .installedContentSeedVersion();
  final day = DateTime(now.year, now.month, now.day);
  final scopeIds = scope.topics.map((topic) => topic.id).toList()..sort();
  final excludedIds = scope.excluded.toList()..sort();

  final roadmap =
      await ref.read(roadmapControllerProvider).today(request.examId);

  return QuizPreparationStamp(
    contentRevision: installedContentRevision ?? contentSeedVersion,
    accountLifetimeToken: '${_authToken(authState)}:$accountLifetimeGeneration',
    examId: request.examId,
    topicId: request.topicId,
    scopeToken: scopeIds.join('|'),
    topicExclusionToken: excludedIds.join('|'),
    ordering: _sessionOrdering(preferences.ordering),
    sessionLength: preferences.sessionLength,
    roadmapToken: '${dayKey(roadmap.snapshot.day)}|'
        '${roadmap.snapshot.digest.encode()}|'
        '${roadmap.snapshot.plan.advancedIds.length}',
    historyRevision: history.toString(),
    sessionStateRevision: sessionRevision,
    localDay: day,
    nextDueExpiry: nextDueExpiry,
  );
}

Future<_ScopeSnapshot> _readScope(Ref ref, ExamId examId) async {
  final scope = await readScopedTopics(
    ref.read(contentRepositoryProvider),
    ref.read(customTrackRepositoryProvider),
    examId,
  );
  return _ScopeSnapshot(topics: scope.topics, excluded: scope.excluded);
}

Question _selectionQuestion(QuestionSelectionRow row, ExamId examId) {
  return Question(
    id: row.id,
    version: row.version,
    examIds: [examId],
    topicId: row.topicId,
    language: '',
    stem: '',
    choices: const [],
    explanation: '',
    lessonId: row.lessonId,
    passageId: row.passageId,
    figureSpecJson: row.hasFigure ? '{}' : null,
  );
}

String _authToken(AuthState state) {
  return switch (state) {
    AnonymousAuthState(:final uid) => 'anonymous:$uid',
    SignedInAuthState(:final user) => 'signed-in:${user.uid}',
    SignedOutAuthState() => 'signed-out',
    UnknownAuthState() => 'unknown',
  };
}

SessionOrdering _sessionOrdering(QuizOrdering ordering) {
  return switch (ordering) {
    QuizOrdering.blocked => SessionOrdering.blocked,
    QuizOrdering.interleavedTail => SessionOrdering.interleavedTail,
    QuizOrdering.fullyMixed => SessionOrdering.fullyMixed,
  };
}

QuizOrdering _quizOrdering(SessionOrdering ordering) {
  return switch (ordering) {
    SessionOrdering.blocked => QuizOrdering.blocked,
    SessionOrdering.interleavedTail => QuizOrdering.interleavedTail,
    SessionOrdering.fullyMixed => QuizOrdering.fullyMixed,
  };
}

class _ScopeSnapshot {
  const _ScopeSnapshot({required this.topics, required this.excluded});

  final List<Topic> topics;
  final Set<TopicId> excluded;
}
