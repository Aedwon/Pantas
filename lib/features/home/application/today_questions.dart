import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/quiz/application/quiz_launch_guard.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:pantas/features/quiz/domain/models/quiz_preferences.dart';
import 'package:pantas/features/quiz/domain/models/review_batch.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/domain/paused_quiz_conflict.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';
import 'package:pantas/features/roadmap/domain/roadmap_inputs.dart';
import 'package:pantas/features/roadmap/domain/sitting_planner.dart';
import 'package:uuid/uuid.dart';

enum TodayQuestionKind { reviews, newQuestions }

/// What Home shows about today's questions without their bodies: the counts.
/// They come from the plan and the stored Reviews batch, both local reads.
class TodayQuestionStatus {
  const TodayQuestionStatus({
    required this.today,
    required this.storedReviews,
    required this.reviewProgress,
  });
  final RoadmapToday today;
  final StoredReviewBatch? storedReviews;
  final List<int> reviewProgress;
  int get reviewsTotal => storedReviews == null
      ? today.snapshot.plan.reviewQuestionIds.length
      : storedReviews!.chunks.fold(0, (sum, c) => sum + c.length);
  int get reviewsDone => storedReviews == null
      ? reviewsTotal - today.remaining.reviewQuestionIds.length
      : reviewProgress.fold(0, (sum, n) => sum + n);
  int get newTotal => today.snapshot.plan.newQuestionIds.length;
  int get newDone => newTotal - today.remaining.newQuestionIds.length;
}

class TodayQuestionWork extends TodayQuestionStatus {
  const TodayQuestionWork({
    required this.examId,
    required super.today,
    required this.preparedReviews,
    required super.storedReviews,
    required this.newQuestions,
    required super.reviewProgress,
    required this.newRows,
    required this.guard,
  });
  final String examId;
  final PreparedReviewBatch preparedReviews;
  final List<Question> newQuestions;
  final List<({String title, int done, int total})> newRows;
  final Future<bool> Function() guard;
  List<int> get reviewSizes =>
      storedReviews?.chunks.map((c) => c.length).toList() ??
      preparedReviews.chunks.map((c) => c.length).toList();
}

final todayQuestionLauncherProvider = Provider<TodayQuestionLauncher>((ref) {
  var alive = true;
  ref.onDispose(() => alive = false);
  return TodayQuestionLauncher(ref, () => alive);
});
final todayQuestionWorkProvider =
    FutureProvider.autoDispose.family<TodayQuestionWork, String>(
  (ref, examId) => ref.watch(todayQuestionLauncherProvider).load(examId),
);

/// Shared Home/Quiz membership. Counts never select questions.
class TodayQuestionLauncher {
  TodayQuestionLauncher(this.ref, this.alive);
  final Ref ref;
  final bool Function() alive;

  /// The guard compares the account and the exam as they are now. While
  /// either is reloading (onboarding has just finished, a session is being
  /// restored) it reads as missing and the capture fails or the guard answers
  /// no at once, so wait until both have settled before capturing.
  Future<void> _settled() async {
    await ref.read(authStateProvider.future);
    await ref.read(activeExamFocusProvider.future);
  }

  Future<Future<bool> Function()> captureGuard(
    String examId, {
    required bool Function() isAlive,
  }) async {
    await _settled();
    return captureQuizLaunchGuard(
      ref,
      examId: examId,
      isAlive: () => alive() && isAlive(),
    );
  }

  /// The stored Reviews batch and how far each of its sessions has gone.
  /// Home reads this with the plan; [load] reads the same thing, so the counts
  /// on the first frame and the prepared work cannot disagree.
  Future<TodayQuestionStatus> readStatus(
    RoadmapToday today,
    String examId,
  ) async {
    final scope = ref
        .read(quizReviewBatchRepositoryProvider)
        .capture(quizLocalUserId, examId);
    if (scope == null) throw StateError('Quiz owner unavailable');
    return _status(scope, today);
  }

  Future<TodayQuestionStatus> _status(
    ReviewBatchScope scope,
    RoadmapToday today,
  ) async {
    final stored =
        await ref.read(quizReviewBatchRepositoryProvider).readCurrent(scope);
    final progress = <int>[];
    if (stored != null) {
      final db = ref.read(appDatabaseProvider);
      for (final id in stored.sessionIds) {
        final row = await (db.select(db.quizSessions)
              ..where((r) => r.id.equals(id)))
            .getSingleOrNull();
        if (row == null && id != stored.sessionIds[stored.current]) {
          progress.add(0);
        } else {
          progress.add(row?.outcomes.length ?? 0);
        }
      }
    }
    return TodayQuestionStatus(
      today: today,
      storedReviews: stored,
      reviewProgress: progress,
    );
  }

  Future<TodayQuestionWork> load(
    String examId, {
    Future<Future<bool> Function()>? originalGuard,
  }) async {
    if (originalGuard == null) await _settled();
    final guard = await (originalGuard ??
        captureQuizLaunchGuard(ref, examId: examId, isAlive: alive));
    if (!await guard()) throw StateError('Quiz owner changed');
    final today = await readRoadmapToday(ref, examId);
    if (!await guard()) throw StateError('Quiz owner changed');
    final content = ref.read(contentRepositoryProvider);
    final batches = ref.read(quizReviewBatchRepositoryProvider);
    final scope = batches.capture(quizLocalUserId, examId);
    if (scope == null) throw StateError('Quiz owner unavailable');
    // Both question sets come from the plan alone, so fetch them together
    // while the stored batch and preferences are read.
    final hydration = Future.wait([
      content.hydrateSelectedQuestions(today.remaining.reviewQuestionIds),
      content.hydrateSelectedQuestions(today.snapshot.plan.newQuestionIds),
    ]);
    unawaited(
      hydration.then<void>((_) {}, onError: (Object _, StackTrace __) {}),
    );
    final status = await _status(scope, today);
    final stored = status.storedReviews;
    final progress = status.reviewProgress;
    final prefs = await ref.read(quizPreferencesRepositoryProvider).read();
    final hydrated = await hydration;
    final reviewQuestions = hydrated[0];
    if (!const ListEquality<String>().equals(
      today.remaining.reviewQuestionIds,
      [for (final q in reviewQuestions) q.id],
    )) {
      throw StateError('Reviews content unavailable');
    }
    final orderedReviewIds = SittingPlanner.next(
      remaining: DayPlan(
        day: today.remaining.day,
        reasons: today.remaining.reasons,
        lessonIds: const [],
        reviewQuestionIds: today.remaining.reviewQuestionIds,
        newQuestionIds: const [],
        isMockDay: false,
        advancedIds: const {},
      ),
      knownLessonIds: {},
      readLessonIds: {},
      questionsById: {
        for (final q in reviewQuestions)
          q.id: RoadmapQuestion(
            id: q.id,
            topicId: q.topicId,
            lessonId: q.lessonId,
            passageId: q.passageId,
          ),
      },
      sessionLength: QuizPreferences.allDueSessionLength,
      ordering: prefs.ordering,
      vocabularyTopicId: 'topic_upcat_vocabulary',
      rankedTopics: today.snapshot.topicOrder,
    );
    final reviewById = {for (final q in reviewQuestions) q.id: q};
    final prepared = PreparedReviewBatch.fromReviews(
      scope: scope,
      preferences: prefs,
      localDay: today.remaining.day,
      orderedDueReviews: [for (final id in orderedReviewIds) reviewById[id]!],
    );
    final allNew = hydrated[1];
    if (!const ListEquality<String>().equals(
      today.snapshot.plan.newQuestionIds,
      [for (final q in allNew) q.id],
    )) {
      throw StateError('New question content unavailable');
    }
    final meta = await content
        .lessonMetaByTopics(allNew.map((q) => q.topicId).toSet().toList());
    final read =
        await ref.read(lessonProgressRepositoryProvider).readLessonIds();
    final lessonNames = {
      for (final lessons in meta.values)
        for (final lesson in lessons) lesson.id: lesson.title,
    };
    final ids = SittingPlanner.next(
      remaining: DayPlan(
        day: today.remaining.day,
        reasons: today.remaining.reasons,
        lessonIds: today.remaining.lessonIds,
        reviewQuestionIds: const [],
        newQuestionIds: today.remaining.newQuestionIds,
        isMockDay: false,
        advancedIds: const {},
      ),
      knownLessonIds: lessonNames.keys.toSet(),
      readLessonIds: read,
      questionsById: {
        for (final q in allNew)
          q.id: RoadmapQuestion(
            id: q.id,
            topicId: q.topicId,
            lessonId: q.lessonId,
            passageId: q.passageId,
          ),
      },
      sessionLength: QuizPreferences.allDueSessionLength,
      ordering: prefs.ordering,
      vocabularyTopicId: 'topic_upcat_vocabulary',
      rankedTopics: today.snapshot.topicOrder,
    );
    if (ids.length != today.remaining.newQuestionIds.length) {
      throw StateError('New question content unavailable');
    }
    final byId = {for (final q in allNew) q.id: q};
    final groups = <String, List<Question>>{};
    for (final q in allNew) {
      final key = q.lessonId ?? q.topicId;
      groups.putIfAbsent(key, () => []).add(q);
    }
    final rows = <({String title, int done, int total})>[];
    for (final entry in groups.entries) {
      final q = entry.value.first;
      final title =
          lessonNames[entry.key] ?? (await content.topicById(q.topicId))?.name;
      if (title == null) throw StateError('Question source unavailable');
      rows.add(
        (
          title: title,
          total: entry.value.length,
          done: entry.value
              .where((q) => !today.remaining.newQuestionIds.contains(q.id))
              .length
        ),
      );
    }
    if (!await guard()) throw StateError('Quiz owner changed');
    return TodayQuestionWork(
      examId: examId,
      today: today,
      preparedReviews: prepared,
      storedReviews: stored,
      newQuestions: [for (final id in ids) byId[id]!],
      reviewProgress:
          stored == null ? [for (final _ in prepared.chunks) 0] : progress,
      newRows: rows,
      guard: guard,
    );
  }

  Future<QuizSession> start(
    TodayQuestionWork work, {
    required TodayQuestionKind kind,
    required bool Function() isAlive,
  }) async {
    Future<bool> guard() async {
      if (!isAlive() || !alive()) return false;
      final current = await work.guard();
      return isAlive() && alive() && current;
    }

    if (!await guard()) throw StateError('Quiz launch changed');
    final batches = ref.read(quizReviewBatchRepositoryProvider);
    if (kind == TodayQuestionKind.reviews) {
      if (work.storedReviews == null) {
        ref.invalidate(roadmapTodayProvider(work.examId));
        final fresh = await readRoadmapToday(ref, work.examId);
        if (!const ListEquality<String>().equals(
          fresh.remaining.reviewQuestionIds,
          work.today.remaining.reviewQuestionIds,
        )) {
          throw StateError('Reviews changed');
        }
      }
      final result = work.storedReviews == null
          ? await batches.start(
              prepared: work.preparedReviews,
              content: ref.read(contentRepositoryProvider),
              now: ref.read(nowProvider)(),
              canPersist: guard,
            )
          : await batches.continueBatch(
              scope: work.preparedReviews.scope,
              content: ref.read(contentRepositoryProvider),
              now: ref.read(nowProvider)(),
              canPersist: guard,
            );
      if (result == null || !await guard()) {
        throw StateError('Reviews unavailable');
      }
      return result.session;
    }
    final paused = await ref
        .read(quizSessionRepositoryProvider)
        .activeFor(userId: quizLocalUserId, examId: work.examId);
    if (paused != null) {
      if (paused.origin != SessionOrigin.newQuestions.storageValue) {
        throw PausedQuizConflict();
      }
      final resumed = await ref.read(resumeSessionProvider)(
        userId: quizLocalUserId,
        examId: work.examId,
      );
      if (resumed == null || !await guard()) throw StateError('Quiz changed');
      return resumed;
    }
    ref.invalidate(roadmapTodayProvider(work.examId));
    final fresh = await readRoadmapToday(ref, work.examId);
    if (!const ListEquality<String>().equals(
      fresh.remaining.newQuestionIds,
      work.today.remaining.newQuestionIds,
    )) {
      throw StateError('New questions changed');
    }
    final questions = await ref
        .read(contentRepositoryProvider)
        .hydrateSelectedQuestions(work.newQuestions.map((q) => q.id).toList());
    if (!const ListEquality<String>().equals(
          [for (final q in work.newQuestions) q.id],
          [for (final q in questions) q.id],
        ) ||
        !const ListEquality<int>().equals([
          for (final q in questions) q.version,
        ], [
          for (final q in work.newQuestions) q.version,
        ])) {
      throw StateError('New questions changed');
    }
    if (questions.isEmpty || !await guard()) {
      throw StateError('New questions unavailable');
    }
    final session = QuizSession.start(
      sessionId: const Uuid().v4(),
      examId: work.examId,
      questions: questions,
      startedAt: ref.read(nowProvider)(),
      origin: SessionOrigin.newQuestions,
    );
    final repo = ref.read(quizSessionRepositoryProvider);
    final created = await repo.createGuarded(
      sessionId: session.sessionId,
      userId: quizLocalUserId,
      examId: work.examId,
      origin: session.origin,
      questionIds: session.questions.map((q) => q.id).toList(),
      startedAt: session.startedAt,
      canPersist: () async {
        if (!await guard()) return false;
        final active = await repo.activeFor(
          userId: quizLocalUserId,
          examId: work.examId,
        );
        return (active == null || active.id == session.sessionId) &&
            await guard();
      },
    );
    if (!created || !await guard()) throw StateError('Quiz launch changed');
    return session;
  }
}
