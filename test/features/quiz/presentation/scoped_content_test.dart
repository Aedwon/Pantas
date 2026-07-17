import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/review_state_repository.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/storage/track_scope.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/practice_picker_providers.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/today_providers.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = inMemoryDatabase();

    // Exam
    await db.into(db.exams).insert(
          ExamsCompanion.insert(
            id: 'exam_cse',
            code: 'CSE',
            name: 'Civil Service Exam',
            shortName: 'CSE',
            language: 'en',
          ),
        );

    // Subject
    await db.into(db.subjects).insert(
          SubjectsCompanion.insert(
            id: 'sub_math',
            examId: 'exam_cse',
            name: 'Mathematics',
            ordering: 1,
          ),
        );

    // Topics
    await db.into(db.topics).insert(
          TopicsCompanion.insert(
            id: 'top_alg',
            subjectId: 'sub_math',
            name: 'Algebra',
            ordering: 1,
          ),
        );
    await db.into(db.topics).insert(
          TopicsCompanion.insert(
            id: 'top_geo',
            subjectId: 'sub_math',
            name: 'Geometry',
            ordering: 2,
          ),
        );
    await db.into(db.topics).insert(
          TopicsCompanion.insert(
            id: 'top_trig',
            subjectId: 'sub_math',
            name: 'Trigonometry',
            ordering: 3,
          ),
        );

    // Questions for topics
    for (final topicId in ['top_alg', 'top_geo', 'top_trig']) {
      for (var i = 1; i <= 5; i++) {
        await db.into(db.questions).insert(
              QuestionsCompanion.insert(
                id: 'q_${topicId}_$i',
                version: 1,
                examIdsJson: jsonEncode(['exam_cse']),
                topicId: topicId,
                language: 'en',
                stem: 'Question $i for $topicId',
                choicesJson: jsonEncode([
                  {'id': 'c1', 'label': 'A', 'text': 'A', 'isCorrect': true},
                  {'id': 'c2', 'label': 'B', 'text': 'B', 'isCorrect': false},
                ]),
                explanation: 'Explanation',
              ),
            );
      }
    }
  });

  tearDown(() => db.close());

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
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
      ContentRepository(db),
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
