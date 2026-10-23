import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/quiz/application/quiz_launch_guard.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:pantas/features/quiz/domain/models/quiz_preferences.dart';
import 'package:pantas/features/quiz/domain/models/review_batch.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';
import 'package:pantas/features/roadmap/domain/roadmap_inputs.dart';
import 'package:pantas/features/roadmap/domain/sitting_planner.dart';
import 'package:uuid/uuid.dart';

enum TodayQuestionKind { reviews, newQuestions }

class TodayQuestionWork {
  const TodayQuestionWork({
    required this.examId,
    required this.today,
    required this.preparedReviews,
    required this.storedReviews,
    required this.newQuestions,
    required this.reviewProgress,
    required this.newRows,
    required this.guard,
  });
  final String examId;
  final RoadmapToday today;
  final PreparedReviewBatch preparedReviews;
  final StoredReviewBatch? storedReviews;
  final List<Question> newQuestions;
  final List<int> reviewProgress;
  final List<({String title, int done, int total})> newRows;
  final Future<bool> Function() guard;
  List<int> get reviewSizes =>
      storedReviews?.chunks.map((c) => c.length).toList() ??
      preparedReviews.chunks.map((c) => c.length).toList();
  int get reviewsTotal => storedReviews == null
      ? today.snapshot.plan.reviewQuestionIds.length
      : storedReviews!.chunks.fold(0, (sum, c) => sum + c.length);
  int get reviewsDone => storedReviews == null
      ? reviewsTotal - today.remaining.reviewQuestionIds.length
      : reviewProgress.fold(0, (sum, n) => sum + n);
  int get newTotal => today.snapshot.plan.newQuestionIds.length;
  int get newDone => newTotal - today.remaining.newQuestionIds.length;
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

  Future<Future<bool> Function()> captureGuard(
    String examId, {
    required bool Function() isAlive,
  }) =>
      captureQuizLaunchGuard(
        ref,
        examId: examId,
        isAlive: () => alive() && isAlive(),
      );

  Future<TodayQuestionWork> load(
    String examId, {
    Future<Future<bool> Function()>? originalGuard,
  }) async {
    final guard = await (originalGuard ??
        captureQuizLaunchGuard(ref, examId: examId, isAlive: alive));
    if (!await guard()) throw StateError('Quiz owner changed');
    final today = await ref.read(roadmapTodayProvider(examId).future);
    if (!await guard()) throw StateError('Quiz owner changed');
    final content = ref.read(contentRepositoryProvider);
    final batches = ref.read(quizReviewBatchRepositoryProvider);
    final scope = batches.capture(quizLocalUserId, examId);
    if (scope == null) throw StateError('Quiz owner unavailable');
    final stored = await batches.readCurrent(scope);
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
    final prefs = await ref.read(quizPreferencesRepositoryProvider).read();
    final reviewQuestions = await content
        .hydrateSelectedQuestions(today.remaining.reviewQuestionIds);
    if (!const ListEquality<String>().equals(
      today.remaining.reviewQuestionIds,
      [for (final q in reviewQuestions) q.id],
    )) {
      throw StateError('Reviews content unavailable');
    }
    final orderedReviewIds = SittingPlanner.next(
      remaining: DayPlan(
        day: today.remaining.day,
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
    final allNew = await content
        .hydrateSelectedQuestions(today.snapshot.plan.newQuestionIds);
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
        final fresh = await ref.read(roadmapTodayProvider(work.examId).future);
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
        throw StateError('Another quiz is paused');
      }
      final resumed = await ref.read(resumeSessionProvider)(
        userId: quizLocalUserId,
        examId: work.examId,
      );
      if (resumed == null || !await guard()) throw StateError('Quiz changed');
      return resumed;
    }
    ref.invalidate(roadmapTodayProvider(work.examId));
    final fresh = await ref.read(roadmapTodayProvider(work.examId).future);
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
