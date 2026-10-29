import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/content/content_seed_version.dart';
import 'package:pantas/core/storage/domain/attempt_origins.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/lesson_meta.dart';
import 'package:pantas/core/storage/domain/question_selection_row.dart';
import 'package:pantas/core/storage/domain/topic.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/core/time/local_day.dart';
import 'package:pantas/features/metrics/signals/attempt_item_reader.dart';
import 'package:pantas/features/mock_exam/application/mock_availability_provider.dart';
import 'package:pantas/features/mock_exam/data/custom_blueprint_repository.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/roadmap/data/topic_prerequisites.dart';
import 'package:pantas/features/roadmap/domain/day_snapshot.dart';
import 'package:pantas/features/roadmap/domain/roadmap_inputs.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

/// The prerequisite links the plan orders by. A provider so tests can use
/// their own topics.
final topicPrerequisitesProvider = Provider<Map<TopicId, List<TopicId>>>(
  (_) => topicPrerequisites,
);

/// Reads what the plan is built from. Metadata only: question and lesson
/// rows without stems, choices, explanations, figures or lesson bodies
/// (quiz loading rule QLP-1).
class RoadmapInputsReader {
  RoadmapInputsReader(this._ref);

  final Ref _ref;

  /// The inputs whose change rebuilds today's plan. Cheap: no question rows.
  Future<RoadmapDigest> digest(ExamId examId) async {
    final settings = await _ref.read(userSettingsProvider.future);
    final examDate = settings.examDate;
    final scope = await _scope(examId);
    return RoadmapDigest(
      examId: examId,
      examDate: examDate == null
          ? ''
          : '${examDate.storageValue}:${examDate.precision.name}',
      scopeTopicIds: [for (final topic in scope.topics) topic.id],
      excludedLessonIds: (await _ref
              .read(customTrackRepositoryProvider)
              .excludedLessonIds(examId))
          .toList(),
      contentRevision: await _contentRevision(),
      assessmentCompleted: await _ref
          .read(assessmentRepositoryProvider)
          .hasCompletedForExam(examId),
      recordedMockCount:
          await _ref.read(attemptsRepositoryProvider).countForOrigin(
                examId: examId,
                origin: AttemptOrigins.mock,
              ),
      studyDays: settings.studyDays,
    );
  }

  /// What is done since [day] began, for judging an earlier stored day: a
  /// review counts as done if the question was answered at any point since,
  /// which the review state alone cannot say once it is reviewed again.
  Future<CompletionFacts> completionSince(ExamId examId, DateTime day) async {
    final now = await completion(day);
    final answered = await _ref
        .read(attemptsRepositoryProvider)
        .questionIdsAnsweredSince(examId: examId, since: localDay(day));
    return CompletionFacts(
      readLessonIds: now.readLessonIds,
      seenQuestionIds: now.seenQuestionIds,
      reviewedTodayIds: {...now.reviewedTodayIds, ...answered},
    );
  }

  /// What is done, as of now, for subtracting from a stored day.
  Future<CompletionFacts> completion(DateTime today) async {
    final db = _ref.read(appDatabaseProvider);
    final read = await db.select(db.lessonProgressLocal).get();
    final states = await _ref.read(reviewStateRepositoryProvider).allStates();
    final day = localDay(today);
    return CompletionFacts(
      readLessonIds: {for (final row in read) row.lessonId},
      seenQuestionIds: {for (final state in states) state.questionId},
      reviewedTodayIds: {
        for (final state in states)
          if (localDay(state.lastReview.toLocal()) == day) state.questionId,
      },
    );
  }

  /// Everything the plan for [today] is built from.
  Future<RoadmapInputs> inputs(
    ExamId examId,
    DateTime today, {
    DateTime? anchoredReviewOnlyFrom,
    bool treatTodayAsStudyDay = false,
  }) async {
    final content = _ref.read(contentRepositoryProvider);
    final now = _ref.read(nowProvider)();
    final day = localDay(today);
    final scope = await _scope(examId);
    final topicIds = [for (final topic in scope.topics) topic.id];

    final excludedLessons = await _ref
        .read(customTrackRepositoryProvider)
        .excludedLessonIds(examId);
    final selection = await content.selectionRowsByTopics(topicIds);
    final lessonMeta = await content.lessonMetaByTopics(topicIds);
    final db = _ref.read(appDatabaseProvider);
    final readAt = {
      for (final row in await db.select(db.lessonProgressLocal).get())
        row.lessonId: row.readAt,
    };
    final states = await _ref.read(reviewStateRepositoryProvider).allStates();
    final scheduler = _ref.read(fsrsSchedulerProvider);

    final questions = [
      for (final topicId in topicIds)
        for (final row in selection[topicId] ?? const <QuestionSelectionRow>[])
          if (!excludedLessons.contains(row.lessonId))
            RoadmapQuestion(
              id: row.id,
              topicId: row.topicId,
              lessonId: row.lessonId,
              passageId: row.passageId,
            ),
    ];
    final scopedQuestionIds = {for (final q in questions) q.id};
    final endOfToday = DateTime(day.year, day.month, day.day + 1);

    final scores = await _scores(examId, {
      for (final q in questions) q.id: q.topicId,
    });
    final settings = await _ref.read(userSettingsProvider.future);
    final mockRepo = _ref.read(mockAttemptRepoProvider);
    final lastMock = await mockRepo.lastCooldownAttempt(
      quizLocalUserId,
      examId,
    );
    final blueprints = await _ref.read(mockBlueprintRepoProvider).byExam(
          examId,
        );

    return RoadmapInputs(
      today: day,
      examId: examId,
      examDate: settings.examDate,
      studyDays: settings.studyDays,
      treatTodayAsStudyDay: treatTodayAsStudyDay,
      topics: [
        for (var i = 0; i < scope.topics.length; i++)
          RoadmapTopic(
            id: scope.topics[i].id,
            authoredIndex: i,
            name: scope.topics[i].name,
          ),
      ],
      lessons: [
        for (final topicId in topicIds)
          for (final lesson in lessonMeta[topicId] ?? const <LessonMeta>[])
            if (!excludedLessons.contains(lesson.id))
              RoadmapLesson(
                id: lesson.id,
                topicId: lesson.topicId,
                ordering: lesson.ordering,
                readAt: readAt[lesson.id],
              ),
      ],
      questions: questions,
      seenQuestionIds: {for (final state in states) state.questionId},
      dueReviews: [
        for (final state in states)
          if (scopedQuestionIds.contains(state.questionId) &&
              state.due.isBefore(endOfToday))
            RoadmapReview(
              id: state.questionId,
              due: state.due,
              retrievability: scheduler.retrievability(state, now),
            ),
      ],
      scores: scores,
      answeredPerActiveDay: await _ref
          .read(attemptsRepositoryProvider)
          .answeredPerActiveDay(examId: examId),
      mock: RoadmapMockFacts(
        examHasMock: blueprints.isNotEmpty ||
            await CustomBlueprintRepository(db).read(examId) != null,
        proIsActive: _ref.read(mockEntitlementProvider).proIsActive,
        lastSubmittedAt: lastMock?.submittedAt,
      ),
      assessmentCompleted: await _ref
          .read(assessmentRepositoryProvider)
          .hasCompletedForExam(examId),
      contentRevision: await _contentRevision(),
      anchoredReviewOnlyFrom: anchoredReviewOnlyFrom,
    );
  }

  /// Correct and answered per topic over every completed attempt, the same
  /// counting as the Progress table's topic rows, from answer records and
  /// question metadata only (QLP-1: no question or lesson bodies).
  Future<Map<TopicId, RoadmapTopicScore>> _scores(
    ExamId examId,
    Map<QuestionId, TopicId> topicOf,
  ) async {
    final db = _ref.read(appDatabaseProvider);
    final rows = await (db.select(db.attemptsLocal)
          ..where((a) => a.examId.equals(examId) & a.completedAt.isNotNull()))
        .get();
    final correct = <TopicId, int>{};
    final answered = <TopicId, int>{};
    for (final row in rows) {
      for (final item in const AttemptItemReader().read(row.itemsJson)) {
        final topicId = topicOf[item.questionId];
        if (topicId == null) continue;
        answered[topicId] = (answered[topicId] ?? 0) + 1;
        if (item.isCorrect) correct[topicId] = (correct[topicId] ?? 0) + 1;
      }
    }
    return {
      for (final entry in answered.entries)
        entry.key: RoadmapTopicScore(
          id: entry.key,
          correct: correct[entry.key] ?? 0,
          answered: entry.value,
        ),
    };
  }

  Future<String> _contentRevision() async =>
      await _ref
          .read(appPreferencesRepositoryProvider)
          .installedContentSeedVersion() ??
      contentSeedVersion;

  Future<({List<Topic> topics, Set<TopicId> excluded})> _scope(
    ExamId examId,
  ) =>
      readScopedTopics(
        _ref.read(contentRepositoryProvider),
        _ref.read(customTrackRepositoryProvider),
        examId,
      );
}
