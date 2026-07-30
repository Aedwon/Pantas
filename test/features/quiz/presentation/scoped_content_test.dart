import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/data/repos/review_state_repository.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/features/quiz/presentation/practice_picker_providers.dart';
import 'package:pantas/features/quiz/presentation/today_providers.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  // The track a student excludes and the attempts they have made are their
  // own data; the corpus they are scoping is not. This test needs both.
  late AppDatabase db;
  late ContentDatabase contentDb;

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = inMemoryContentDatabase();

    await seedContentExam(
      contentDb,
      examId: 'exam_cse',
      code: 'CSE',
      name: 'Civil Service Exam',
    );
    await seedContentSubject(
      contentDb,
      subjectId: 'sub_math',
      examId: 'exam_cse',
      name: 'Mathematics',
    );

    const topicNames = {
      'top_alg': 'Algebra',
      'top_geo': 'Geometry',
      'top_trig': 'Trigonometry',
    };
    var ordering = 1;
    for (final entry in topicNames.entries) {
      await seedContentTopic(
        contentDb,
        topicId: entry.key,
        subjectId: 'sub_math',
        name: entry.value,
        ordering: ordering++,
      );
      for (var i = 1; i <= 5; i++) {
        await seedContentQuestion(
          contentDb,
          questionId: 'q_${entry.key}_$i',
          topicId: entry.key,
          examId: 'exam_cse',
          stem: 'Question $i for ${entry.key}',
        );
      }
    }
  });

  tearDown(() async {
    await db.close();
    await contentDb.close();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
  }

  test("today's queue skips an excluded topic", () async {
    final container = createContainer();
    final repo = container.read(customTrackRepositoryProvider);
    await repo.setExcluded(examId: 'exam_cse', topicIds: {'top_geo'});

    final queue =
        await container.read(todayTopicQueueProvider('exam_cse').future);
    final topicIdsInQueue = queue.map((r) => r.topicId).toList();

    expect(topicIdsInQueue, contains('top_alg'));
    expect(topicIdsInQueue, contains('top_trig'));
    expect(topicIdsInQueue, isNot(contains('top_geo')));
  });

  test('the practice picker does not list an excluded topic', () async {
    final container = createContainer();
    final repo = container.read(customTrackRepositoryProvider);
    await repo.setExcluded(examId: 'exam_cse', topicIds: {'top_geo'});

    final index =
        await container.read(practiceIndexProvider('exam_cse').future);
    final listedTopics =
        index.subjects.expand((s) => s.topics).map((t) => t.id).toList();

    expect(listedTopics, contains('top_alg'));
    expect(listedTopics, contains('top_trig'));
    expect(listedTopics, isNot(contains('top_geo')));
  });

  test('the assessment shortens when the track narrows', () async {
    final container = createContainer();
    final selector = AssessmentQuestionSelector(
      ContentRepository(contentDb),
      ReviewStateRepository(db),
    );

    final allTopics =
        await container.read(scopedTopicsProvider('exam_cse').future);
    final initialQuestions =
        await selector.select('exam_cse', topics: allTopics);

    // Narrow track by excluding top_geo and top_trig
    final repo = container.read(customTrackRepositoryProvider);
    await repo.setExcluded(
      examId: 'exam_cse',
      topicIds: {'top_geo', 'top_trig'},
    );
    container
      ..invalidate(trackScopeProvider('exam_cse'))
      ..invalidate(scopedTopicsProvider('exam_cse'));

    final narrowedTopics =
        await container.read(scopedTopicsProvider('exam_cse').future);
    final narrowedQuestions =
        await selector.select('exam_cse', topics: narrowedTopics);

    expect(narrowedQuestions.length, lessThan(initialQuestions.length));
  });

  test('excluding a topic does not delete its attempts', () async {
    await db.into(db.attemptsLocal).insert(
          AttemptsLocalCompanion.insert(
            id: 'att_1',
            examId: 'exam_cse',
            startedAt: DateTime.now(),
            completedAt: Value(DateTime.now()),
            itemsJson: jsonEncode([]),
          ),
        );

    final container = createContainer();
    final repo = container.read(customTrackRepositoryProvider);
    await repo.setExcluded(examId: 'exam_cse', topicIds: {'top_geo'});

    final attempts = await db.select(db.attemptsLocal).get();
    expect(attempts.length, equals(1));
  });
}
