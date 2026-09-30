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
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';
import 'package:pantas/features/roadmap/domain/build_roadmap.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';
import 'package:pantas/features/roadmap/domain/roadmap_inputs.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:pantas/features/settings/domain/session_ordering.dart';
import 'package:pantas/features/settings/domain/user_settings.dart';

import '../../../helpers/in_memory_database.dart';

/// Counts the content calls the plan must never make.
class _SpyContent extends ContentRepository {
  _SpyContent(super.db, {super.onQuery});

  int hydrations = 0;
  int fullLessons = 0;

  @override
  Future<List<Question>> hydrateSelectedQuestions(List<QuestionId> ids) {
    hydrations++;
    return super.hydrateSelectedQuestions(ids);
  }

  @override
  Future<Map<TopicId, List<Lesson>>> lessonsByTopics(List<TopicId> topicIds) {
    fullLessons++;
    return super.lessonsByTopics(topicIds);
  }
}

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;
  late _SpyContent content;
  late ProviderContainer container;
  late DateTime now;
  late int builds;
  late int queries;

  UserSettings settings() => UserSettings(
        name: null,
        dailyReminderTime: null,
        examDate: ExamDate.onDay(DateTime(2026, 12, 7)),
        strictMockMode: false,
        helpImproveApp: true,
        carryOverProgress: true,
        sessionOrdering: SessionOrdering.interleavedTail,
        retainTableOrder: true,
        updatedAt: null,
      );

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = inMemoryContentDatabase();
    queries = 0;
    content = _SpyContent(contentDb, onQuery: () => queries++);
    now = DateTime(2026, 9, 30, 8);
    builds = 0;

    await seedContentExam(
      contentDb,
      examId: 'e1',
      code: 'UPCAT',
      name: 'UPCAT',
    );
    await seedContentSubject(
      contentDb,
      subjectId: 's1',
      examId: 'e1',
      name: 'Math',
    );
    for (final t in ['t1', 't2']) {
      await seedContentTopic(contentDb, topicId: t, subjectId: 's1', name: t);
      for (var l = 0; l < 4; l++) {
        await seedContentLesson(
          contentDb,
          lessonId: '${t}_l$l',
          topicId: t,
          ordering: l,
        );
        for (var q = 0; q < 5; q++) {
          await seedContentQuestion(
            contentDb,
            questionId: '${t}_l${l}_q$q',
            topicId: t,
            examId: 'e1',
            lessonId: '${t}_l$l',
          );
        }
      }
    }
    await AssessmentRepository(db).saveResult('e1', now, const []);

    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
        contentRepositoryProvider.overrideWithValue(content),
        nowProvider.overrideWithValue(() => now),
        userSettingsProvider.overrideWith((ref) async => settings()),
        topicAccuracyProvider.overrideWith((ref) async => const []),
        roadmapBuilderProvider.overrideWithValue((RoadmapInputs inputs) {
          builds++;
          return BuildRoadmap.call(inputs);
        }),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
    await contentDb.close();
  });

  RoadmapController controller() => container.read(roadmapControllerProvider);

  Future<List<RoadmapChangeCause>> causes() async => [
        for (final change in await container
            .read(roadmapChangeLogRepositoryProvider)
            .recent('e1'))
          change.cause,
      ];

  test('the first read builds and stores the day and logs it', () async {
    final today = await controller().today('e1');

    expect(builds, 1);
    expect(today.remaining.lessonIds, isNotEmpty);
    expect(today.remaining.newQuestionIds, isNotEmpty);
    expect(await causes(), [RoadmapChangeCause.newDay]);
    expect(
      await container.read(roadmapDayRepositoryProvider).read('e1', now),
      isNotNull,
    );
  });

  test('a second read the same day does not rebuild', () async {
    await controller().today('e1');
    now = DateTime(2026, 9, 30, 20);
    await controller().today('e1');
    expect(builds, 1);
  });

  test('answering and reading remove items without a rebuild', () async {
    final first = await controller().today('e1');
    final lesson = first.remaining.lessonIds.first;
    final question = first.remaining.newQuestionIds.first;
    await container.read(lessonProgressRepositoryProvider).markRead(lesson);
    await container.read(reviewStateRepositoryProvider).upsert(
          ReviewState.seed(questionId: question, questionVersion: 1, now: now),
        );

    final second = await controller().today('e1');

    expect(builds, 1);
    expect(second.remaining.lessonIds, isNot(contains(lesson)));
    expect(second.remaining.newQuestionIds, isNot(contains(question)));
  });

  test('excluding a topic rebuilds today and names why', () async {
    await controller().today('e1');
    await container
        .read(customTrackRepositoryProvider)
        .setExcluded(examId: 'e1', topicIds: {'t2'});

    await controller().today('e1');

    expect(builds, 2);
    expect(await causes(), contains(RoadmapChangeCause.scopeChanged));
  });

  test('a new day rebuilds and keeps the first review-only date', () async {
    final first = await controller().today('e1');
    now = DateTime(2026, 11, 20, 8);
    final later = await controller().today('e1');

    expect(builds, 2);
    expect(later.snapshot.reviewOnlyFrom, first.snapshot.reviewOnlyFrom);
    expect(later.snapshot.reviewOnlyFrom, DateTime(2026, 11, 30));
    expect(await causes(), contains(RoadmapChangeCause.missedWork));
  });

  test('advance adds tomorrow only once today is done', () async {
    final first = await controller().today('e1');
    expect(
      (await controller().advance('e1')).snapshot.plan.advancedIds,
      isEmpty,
    );

    for (final lesson in first.remaining.lessonIds) {
      await container.read(lessonProgressRepositoryProvider).markRead(lesson);
    }
    for (final q in first.remaining.newQuestionIds) {
      await container.read(reviewStateRepositoryProvider).upsert(
            ReviewState.seed(questionId: q, questionVersion: 1, now: now),
          );
    }

    final advanced = await controller().advance('e1');

    expect(advanced.snapshot.plan.advancedIds, isNotEmpty);
    expect(advanced.originalDone, isTrue);
    expect(await causes(), contains(RoadmapChangeCause.advanced));
  });

  test('the plan never loads question bodies or lesson bodies', () async {
    await controller().today('e1');
    expect(content.hydrations, 0);
    expect(content.fullLessons, 0);
    expect(queries, lessThan(10));
  });

  test('the plan waits for the assessment', () async {
    await db.delete(db.assessmentResultsLocal).go();
    final today = await controller().today('e1');
    expect(today.state, RoadmapState.needsAssessment);
    expect(today.remaining.questionCount, 0);
  });
}
