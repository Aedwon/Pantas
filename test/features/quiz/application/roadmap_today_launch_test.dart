import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/assessment_repository.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/lesson.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/domain/review_state.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/features/home/application/topic_accuracy_provider.dart';
import 'package:pantas/features/quiz/application/quiz_launch_coordinator.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/quiz/application/today_quiz_preparer.dart';
import 'package:pantas/features/quiz/domain/models/quiz_ordering.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';
import 'package:pantas/features/roadmap/domain/roadmap_inputs.dart';
import 'package:pantas/features/roadmap/domain/sitting_planner.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:pantas/features/settings/domain/session_ordering.dart';
import 'package:pantas/features/settings/domain/user_settings.dart';

import '../../../helpers/in_memory_database.dart';

class _ContentSpy extends ContentRepository {
  _ContentSpy(super.db, {super.onQuery});

  final hydrated = <List<QuestionId>>[];
  int fullLessons = 0;

  @override
  Future<List<Question>> hydrateSelectedQuestions(List<QuestionId> ids) {
    hydrated.add(List.of(ids));
    return super.hydrateSelectedQuestions(ids);
  }

  @override
  Future<Map<TopicId, List<Lesson>>> lessonsByTopics(List<TopicId> ids) {
    fullLessons++;
    return super.lessonsByTopics(ids);
  }
}

void main() {
  const request = QuizPreparationRequest(userId: quizLocalUserId, examId: 'e1');
  final now = DateTime(2026, 9, 30, 8);
  late AppDatabase db;
  late ContentDatabase contentDb;
  late _ContentSpy content;
  late ProviderContainer container;
  late DateTime examDay;
  late int queries;

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = inMemoryContentDatabase();
    queries = 0;
    content = _ContentSpy(contentDb, onQuery: () => queries++);
    examDay = DateTime(2026, 10, 3);
    for (final topic in ['t1', 't2']) {
      await seedContentTopicWithQuestions(
        contentDb,
        examId: 'e1',
        topicId: topic,
        topicName: topic,
        questionIds: [for (var i = 0; i < 20; i++) '${topic}_q$i'],
      );
    }
    await AssessmentRepository(db).saveResult('e1', now, const []);
    await db.into(db.accountPrefs).insertOnConflictUpdate(
          AccountPrefsCompanion.insert(key: 'quiz_session_length', value: '5'),
        );
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
        contentRepositoryProvider.overrideWithValue(content),
        nowProvider.overrideWithValue(() => now),
        topicAccuracyProvider.overrideWith((ref) async => const []),
        userSettingsProvider.overrideWith(
          (ref) async => UserSettings(
            name: null,
            dailyReminderTime: null,
            examDate: ExamDate.onDay(examDay),
            strictMockMode: false,
            helpImproveApp: true,
            carryOverProgress: true,
            sessionOrdering: SessionOrdering.interleavedTail,
            retainTableOrder: true,
            updatedAt: null,
          ),
        ),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
    await contentDb.close();
  });

  Future<List<QuestionId>> nextIds() async {
    final today = await container.read(roadmapControllerProvider).today('e1');
    final rows = await content.selectionRowsByTopics(['t1', 't2']);
    return SittingPlanner.next(
      remaining: today.remaining,
      knownLessonIds: const {},
      readLessonIds: const {},
      questionsById: {
        for (final topic in rows.values)
          for (final row in topic)
            row.id: RoadmapQuestion(id: row.id, topicId: row.topicId),
      },
      sessionLength: 5,
      ordering: QuizOrdering.interleavedTail,
      vocabularyTopicId: 'topic_upcat_vocabulary',
      rankedTopics: today.snapshot.topicOrder,
    );
  }

  test('real Start consumes successive roadmap sittings past ten new questions',
      () async {
    final preparer = container.read(todayQuizPreparerProvider);
    final coordinator = container.read(quizLaunchCoordinatorProvider);
    final allIds = <QuestionId>[];
    final day = await container.read(roadmapControllerProvider).today('e1');
    while (allIds.length < day.remaining.questionCount) {
      final expected = await nextIds();
      final prepared = await preparer.prepare(request);
      expect(prepared.orderedQuestionIds, expected);
      expect(prepared.plan.weaknessCount, 0);
      expect(prepared.plan.freshCount, expected.length);
      final result = await coordinator.launchToday(request, prepared: prepared);
      expect(result, isA<QuizLaunchStarted>());
      var session = (result as QuizLaunchStarted).session;
      expect(session.questions.map((q) => q.id), expected);
      for (final question in session.questions) {
        final outcome = await container.read(submitAnswerProvider)(
          question: question,
          chosenChoiceId: question.correctChoice.id,
          responseMs: 1000,
          now: now,
          sessionId: session.sessionId,
          userId: quizLocalUserId,
          examId: 'e1',
        );
        session = session.record(outcome).advance();
      }
      await container.read(quizCompletionCoordinatorProvider).complete(
            session: session,
            now: now,
            persisted: true,
          );
      allIds.addAll(expected);
      final remaining =
          await container.read(roadmapControllerProvider).today('e1');
      expect(
        remaining.remaining.newQuestionIds,
        isNot(contains(anyOf(expected))),
      );
    }
    expect(allIds.length, greaterThan(10));
    expect(allIds.toSet().length, allIds.length);
    expect((await preparer.prepare(request)).plan.isEmpty, isTrue);
  });

  test('roadmap rebuild replaces a prepared sitting', () async {
    final preparer = container.read(todayQuizPreparerProvider);
    final first = await preparer.prepare(request);
    examDay = DateTime(2026, 12, 7);
    container.invalidate(userSettingsProvider);
    final second = await preparer.prepare(request);
    expect(second.stamp, isNot(first.stamp));
    expect(identical(second, first), isFalse);
    expect(second.plan.questions.length, 1);
    expect(content.hydrated.length, 2);
  });

  test('preparation hydrates only the sitting and warm Start does not hydrate',
      () async {
    examDay = DateTime(2026, 12, 7);
    container.invalidate(userSettingsProvider);
    const expected = ['t1_q0'];
    // Any question payload outside this sitting is deliberately unreadable.
    await contentDb.customStatement(
      "UPDATE content_questions SET stem_json = 'INVALID', "
      "explanation_json = 'INVALID', figure_spec_json = 'INVALID' "
      'WHERE id <> ?',
      [expected.single],
    );
    queries = 0;
    final prepared =
        await container.read(todayQuizPreparerProvider).prepare(request);
    expect(prepared.orderedQuestionIds, expected);
    expect(content.hydrated, [expected]);
    expect(content.fullLessons, 0);
    expect(queries, lessThan(15));
    final before = queries;
    final result = await container
        .read(quizLaunchCoordinatorProvider)
        .launchToday(request, prepared: prepared);
    expect(result, isA<QuizLaunchStarted>());
    expect(content.hydrated, [expected]);
    expect(queries - before, lessThan(8));
  });

  test('reviews due later today count as reviews in the sitting', () async {
    await container.read(reviewStateRepositoryProvider).upsert(
          ReviewState.seed(
            questionId: 't1_q0',
            questionVersion: 1,
            now: now.subtract(const Duration(days: 1)),
          ).copyWith(
            due: now.add(const Duration(hours: 10)),
            stability: 1,
          ),
        );
    final prepared =
        await container.read(todayQuizPreparerProvider).prepare(request);
    expect(prepared.orderedQuestionIds.first, 't1_q0');
    expect(prepared.plan.dueCount, 1);
    expect(prepared.plan.freshCount, 4);
    expect(prepared.plan.weaknessCount, 0);
    expect(prepared.plan.topicId, 't1');
    expect(prepared.plan.topicName, 't1');
  });

  test('lesson metadata holds unread lessons behind available questions',
      () async {
    await seedContentLesson(contentDb, lessonId: 'unread', topicId: 't1');
    await seedContentLesson(contentDb, lessonId: 'read', topicId: 't1');
    await container.read(lessonProgressRepositoryProvider).markRead('read');
    await contentDb.customStatement(
      "UPDATE content_questions SET lesson_id = 'unread' WHERE id = 't1_q0'",
    );
    await contentDb.customStatement(
      "UPDATE content_questions SET lesson_id = 'read' WHERE id = 't1_q1'",
    );
    await contentDb
        .customStatement("UPDATE content_lessons SET body_json = 'INVALID'");
    final prepared =
        await container.read(todayQuizPreparerProvider).prepare(request);
    expect(prepared.orderedQuestionIds.first, 't1_q1');
    expect(prepared.orderedQuestionIds, isNot(contains('t1_q0')));
    await container.read(lessonProgressRepositoryProvider).markRead('unread');
    final afterRead =
        await container.read(todayQuizPreparerProvider).prepare(request);
    expect(afterRead.orderedQuestionIds, contains('t1_q0'));
    expect(identical(afterRead, prepared), isFalse);
    expect(content.fullLessons, 0);
  });

  test('advance invalidates a cached empty sitting without changing history',
      () async {
    final controller = container.read(roadmapControllerProvider);
    final today = await controller.today('e1');
    for (final id in today.remaining.newQuestionIds) {
      await container.read(reviewStateRepositoryProvider).upsert(
            ReviewState.seed(questionId: id, questionVersion: 1, now: now),
          );
    }
    final preparer = container.read(todayQuizPreparerProvider);
    final done = await preparer.prepare(request);
    expect(done.plan.isEmpty, isTrue);
    final advanced = await controller.advance('e1');
    expect(advanced.snapshot.plan.advancedIds, isNotEmpty);
    final next = await preparer.prepare(request);
    expect(next.stamp.roadmapToken, isNot(done.stamp.roadmapToken));
    expect(next.stamp.historyRevision, done.stamp.historyRevision);
    expect(next.orderedQuestionIds, await nextIds());
    expect(next.plan.isEmpty, isFalse);
  });

  test('topic All ignores legacy zero cap and daily introduction count',
      () async {
    for (final entry in {
      'quiz_session_length': '-1',
      'settings.session_ordering': 'blocked',
      'quiz_new_card_cap': '0',
    }.entries) {
      await db.into(db.accountPrefs).insertOnConflictUpdate(
            AccountPrefsCompanion.insert(key: entry.key, value: entry.value),
          );
    }
    await container.read(newCardIntroRepositoryProvider).incrementForDay(
          userId: quizLocalUserId,
          examId: 'e1',
          day: now,
          by: 100,
        );
    final result =
        await container.read(quizLaunchCoordinatorProvider).launchToday(
              const QuizPreparationRequest(
                userId: quizLocalUserId,
                examId: 'e1',
                topicId: 't2',
              ),
            );
    expect(result, isA<QuizLaunchStarted>());
    final questions = (result as QuizLaunchStarted).session.questions;
    expect(questions, hasLength(20));
    expect(questions.every((q) => q.topicId == 't2'), isTrue);
  });

  test('unassessed and empty scope return empty without hydration', () async {
    await db.delete(db.assessmentResultsLocal).go();
    final preparer = container.read(todayQuizPreparerProvider);
    expect((await preparer.prepare(request)).plan.isEmpty, isTrue);
    await AssessmentRepository(db).saveResult('e1', now, const []);
    await container.read(customTrackRepositoryProvider).setExcluded(
      examId: 'e1',
      topicIds: {'t1', 't2'},
    );
    expect((await preparer.prepare(request)).plan.isEmpty, isTrue);
    expect(content.hydrated, isEmpty);
  });
}
