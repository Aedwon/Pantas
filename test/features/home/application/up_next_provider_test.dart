import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/lesson_meta.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/home/application/up_next_provider.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';
import 'package:pantas/features/roadmap/domain/day_snapshot.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;
  late ProviderContainer container;
  late _MetadataRepository content;
  late RoadmapToday today;
  final day = DateTime(2026, 10);

  RoadmapToday planned({
    List<String> lessons = const [],
    List<String>? remainingLessons,
    List<String> scope = const ['chemistry', 'algebra'],
    RoadmapState state = RoadmapState.planning,
  }) {
    final plan = DayPlan(
      day: day,
      lessonIds: lessons,
      reviewQuestionIds: const [],
      newQuestionIds: const [],
      isMockDay: false,
      advancedIds: const {},
    );
    return RoadmapToday(
      snapshot: DaySnapshot(
        plan: plan,
        digest: RoadmapDigest(
          examId: 'upcat',
          examDate: '2026-12-07:day',
          scopeTopicIds: scope,
          contentRevision: 'test',
          assessmentCompleted: state != RoadmapState.needsAssessment,
          recordedMockCount: 0,
        ),
        topicOrderHead: scope,
        state: state,
      ),
      remaining: DayPlan(
        day: day,
        lessonIds: remainingLessons ?? lessons,
        reviewQuestionIds: const [],
        newQuestionIds: const [],
        isMockDay: false,
        advancedIds: const {},
      ),
      originalDone: (remainingLessons ?? lessons).isEmpty,
    );
  }

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = openTestContentDatabase();
    content = _MetadataRepository(contentDb);
    today = planned();
    await seedContentExam(contentDb, examId: 'upcat');
    await AppPreferencesRepository(db).setSelectedExamId('upcat');
    for (final topic in ['chemistry', 'algebra']) {
      await seedContentSubject(
        contentDb,
        subjectId: 'subj_$topic',
        examId: 'upcat',
        name: topic == 'chemistry' ? 'Science' : 'Mathematics',
      );
      await seedContentTopic(
        contentDb,
        topicId: topic,
        subjectId: 'subj_$topic',
      );
    }
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
        contentRepositoryProvider.overrideWithValue(content),
        roadmapTodayProvider('upcat').overrideWith((ref) async => today),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> lesson(String id, String topic, {int minutes = 9}) =>
      seedContentLesson(
        contentDb,
        lessonId: id,
        topicId: topic,
        title: 'Title $id',
        estimatedMinutes: minutes,
        // Invalid bodies must not be decoded by a metadata consumer.
        bodyJson: 'not lesson JSON',
      );

  Future<void> read(String id) =>
      db.into(db.lessonProgressLocal).insertOnConflictUpdate(
            LessonProgressLocalCompanion.insert(lessonId: id, readAt: day),
          );

  test('shows remaining lessons in plan order with metadata', () async {
    await lesson('chem-01', 'chemistry');
    await lesson('chem-02', 'chemistry', minutes: 7);
    await lesson('alg-01', 'algebra', minutes: 12);
    today = planned(lessons: ['alg-01', 'chem-02']);

    final result = await container.read(upNextProvider.future);

    expect(result.lessons, const [
      UpNextLesson(
        lessonId: 'alg-01',
        title: 'Title alg-01',
        topicId: 'algebra',
        subjectName: 'Mathematics',
        estimatedMinutes: 12,
      ),
      UpNextLesson(
        lessonId: 'chem-02',
        title: 'Title chem-02',
        topicId: 'chemistry',
        subjectName: 'Science',
        estimatedMinutes: 7,
      ),
    ]);
    expect(result.allReadInWeakTopics, isFalse);
    expect(
      content.metadataScopes,
      [
        unorderedEquals(['chemistry', 'algebra']),
      ],
    );
  });

  test('does not cap the roadmap at three lessons', () async {
    for (final id in ['chem-01', 'chem-02', 'chem-03', 'chem-04']) {
      await lesson(id, 'chemistry');
    }
    today = planned(lessons: ['chem-04', 'chem-02', 'chem-01', 'chem-03']);

    final result = await container.read(upNextProvider.future);

    expect(
      result.lessons.map((lesson) => lesson.lessonId),
      ['chem-04', 'chem-02', 'chem-01', 'chem-03'],
    );
  });

  test('uses remaining lessons instead of the original snapshot', () async {
    await lesson('chem-01', 'chemistry');
    await lesson('chem-02', 'chemistry');
    await read('chem-01');
    today = planned(
      lessons: ['chem-01', 'chem-02'],
      remainingLessons: ['chem-02'],
    );

    final result = await container.read(upNextProvider.future);

    expect(result.lessons.map((lesson) => lesson.lessonId), ['chem-02']);
  });

  test('a done day is not all read while other scoped lessons remain',
      () async {
    await lesson('chem-01', 'chemistry');
    await lesson('chem-02', 'chemistry');
    await read('chem-01');
    today = planned(lessons: ['chem-01'], remainingLessons: []);

    final result = await container.read(upNextProvider.future);

    expect(result.lessons, isEmpty);
    expect(result.allReadInWeakTopics, isFalse);
  });

  test('excluded lessons neither appear nor prevent all read', () async {
    await lesson('chem-01', 'chemistry');
    await lesson('alg-01', 'algebra');
    await read('chem-01');
    today = planned(scope: ['chemistry']);

    final result = await container.read(upNextProvider.future);

    expect(result.lessons, isEmpty);
    expect(result.allReadInWeakTopics, isTrue);
    expect(
      content.metadataScopes,
      [
        equals(['chemistry']),
      ],
    );
  });

  test('no scoped lessons is not all read', () async {
    today = planned(state: RoadmapState.noContent);

    final result = await container.read(upNextProvider.future);

    expect(result.lessons, isEmpty);
    expect(result.allReadInWeakTopics, isFalse);
  });

  test('roadmap invalidation updates the remaining lessons', () async {
    await lesson('chem-01', 'chemistry');
    await lesson('chem-02', 'chemistry');
    today = planned(lessons: ['chem-01', 'chem-02']);
    final subscription = container.listen(upNextProvider, (_, __) {});
    addTearDown(subscription.close);
    await container.read(upNextProvider.future);
    await read('chem-01');
    today = planned(
      lessons: ['chem-01', 'chem-02'],
      remainingLessons: ['chem-02'],
    );
    container.invalidate(roadmapTodayProvider('upcat'));

    final result = await container.read(upNextProvider.future);

    expect(result.lessons.map((lesson) => lesson.lessonId), ['chem-02']);
  });

  test('custom track lessons keep their source subject names', () async {
    await seedContentExam(contentDb, examId: 'custom', isCustom: true);
    await AppPreferencesRepository(db).setSelectedExamId('custom');
    await lesson('alg-01', 'algebra');
    today = planned(lessons: ['alg-01'], scope: ['algebra']);
    container.dispose();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
        contentRepositoryProvider.overrideWithValue(content),
        roadmapTodayProvider('upcat').overrideWith((ref) async => today),
        roadmapTodayProvider('custom').overrideWith((ref) async => today),
      ],
    );

    final result = await container.read(upNextProvider.future);

    expect(result.lessons.single.subjectName, 'Mathematics');
  });

  test('no selected exam gives no lessons without reading a roadmap', () async {
    await AppPreferencesRepository(db).setSelectedExamId('missing');

    final result = await container.read(upNextProvider.future);

    expect(result.lessons, isEmpty);
    expect(result.allReadInWeakTopics, isFalse);
    expect(content.metadataScopes, isEmpty);
  });
}

class _MetadataRepository extends ContentRepository {
  _MetadataRepository(super.db);

  final metadataScopes = <List<TopicId>>[];

  @override
  Future<Map<TopicId, List<LessonMeta>>> lessonMetaByTopics(
    Iterable<TopicId> topicIds,
  ) {
    final scope = topicIds.toList();
    metadataScopes.add(scope);
    return super.lessonMetaByTopics(scope);
  }
}
