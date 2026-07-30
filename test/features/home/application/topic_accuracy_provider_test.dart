import 'dart:convert';

import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/home/application/topic_accuracy_provider.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;
  late ProviderContainer container;

  setUp(() {
    db = inMemoryDatabase();
    contentDb = openTestContentDatabase();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> setupExam(String examId) async {
    await AppPreferencesRepository(db).setSelectedExamId(examId);
  }

  Future<void> insertAttempt(
    AppDatabase db, {
    required String id,
    required String examId,
    required List<({String questionId, bool isCorrect})> items,
    DateTime? completedAt,
    bool isCompleted = true,
    String origin = 'today_topic',
  }) async {
    final itemsJson = jsonEncode([
      for (final item in items)
        {
          'questionId': item.questionId,
          'questionVersion': 1,
          'chosenChoiceId': item.isCorrect ? 'c_a' : 'c_b',
          'correctChoiceId': 'c_a',
          'responseMs': 1000,
        },
    ]);
    await db.into(db.attemptsLocal).insert(
          AttemptsLocalCompanion.insert(
            id: id,
            examId: examId,
            startedAt: DateTime.now(),
            completedAt:
                Value(isCompleted ? (completedAt ?? DateTime.now()) : null),
            origin: Value(origin),
            itemsJson: itemsJson,
          ),
        );
  }

  test('ranks measured topics weakest first', () async {
    await setupExam('upcat');
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'upcat',
      topicId: 'chemistry',
      topicName: 'Chemistry',
      questionIds: ['q_chem_1', 'q_chem_2', 'q_chem_3', 'q_chem_4', 'q_chem_5'],
    );
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'upcat',
      topicId: 'algebra',
      topicName: 'Algebra',
      questionIds: ['q_alg_1', 'q_alg_2', 'q_alg_3', 'q_alg_4', 'q_alg_5'],
    );
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'upcat',
      topicId: 'geometry',
      topicName: 'Geometry',
      questionIds: ['q_geo_1', 'q_geo_2', 'q_geo_3', 'q_geo_4', 'q_geo_5'],
    );

    // Chemistry 1/5, Algebra 3/5, Geometry 5/5.
    await insertAttempt(
      db,
      id: 'att_1',
      examId: 'upcat',
      items: [
        (questionId: 'q_chem_1', isCorrect: true),
        (questionId: 'q_chem_2', isCorrect: false),
        (questionId: 'q_chem_3', isCorrect: false),
        (questionId: 'q_chem_4', isCorrect: false),
        (questionId: 'q_chem_5', isCorrect: false),
        (questionId: 'q_alg_1', isCorrect: true),
        (questionId: 'q_alg_2', isCorrect: true),
        (questionId: 'q_alg_3', isCorrect: true),
        (questionId: 'q_alg_4', isCorrect: false),
        (questionId: 'q_alg_5', isCorrect: false),
        (questionId: 'q_geo_1', isCorrect: true),
        (questionId: 'q_geo_2', isCorrect: true),
        (questionId: 'q_geo_3', isCorrect: true),
        (questionId: 'q_geo_4', isCorrect: true),
        (questionId: 'q_geo_5', isCorrect: true),
      ],
    );

    final ranked = await container.read(topicAccuracyProvider.future);

    expect(
      ranked.take(3).map((t) => t.topicId),
      ['chemistry', 'algebra', 'geometry'],
    );
  });

  test('an untouched topic sorts last, never at nought per cent', () async {
    await setupExam('upcat');
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'upcat',
      topicId: 'chemistry',
      topicName: 'Chemistry',
      questionIds: ['q_chem_1', 'q_chem_2', 'q_chem_3', 'q_chem_4', 'q_chem_5'],
    );
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'upcat',
      topicId: 'physics',
      topicName: 'Physics',
      questionIds: ['q_phys_1'],
    );

    // Chemistry 1/5. Physics has no attempts at all.
    await insertAttempt(
      db,
      id: 'att_1',
      examId: 'upcat',
      items: [
        (questionId: 'q_chem_1', isCorrect: true),
        (questionId: 'q_chem_2', isCorrect: false),
        (questionId: 'q_chem_3', isCorrect: false),
        (questionId: 'q_chem_4', isCorrect: false),
        (questionId: 'q_chem_5', isCorrect: false),
      ],
    );

    final ranked = await container.read(topicAccuracyProvider.future);

    expect(ranked.first.topicId, 'chemistry');
    expect(ranked.last.topicId, 'physics');
    expect(ranked.last.answered, 0);
    expect(ranked.last.accuracy, isNull);
  });

  test('below the floor a topic is ranked and prints nothing', () async {
    await setupExam('upcat');
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'upcat',
      topicId: 'chemistry',
      topicName: 'Chemistry',
      questionIds: ['q_chem_1'],
    );

    // Chemistry 0/1: worst ratio, and unmeasurable.
    await insertAttempt(
      db,
      id: 'att_1',
      examId: 'upcat',
      items: [
        (questionId: 'q_chem_1', isCorrect: false),
      ],
    );

    final ranked = await container.read(topicAccuracyProvider.future);

    final chemistry = ranked.firstWhere((t) => t.topicId == 'chemistry');
    expect(ranked.first.topicId, 'chemistry', reason: 'still ranked first');
    expect(chemistry.isMeasured, isFalse);
    expect(chemistry.accuracy, isNull, reason: 'and prints nothing');
  });

  test('exactly three answered clears the floor', () async {
    await setupExam('upcat');
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'upcat',
      topicId: 'chemistry',
      topicName: 'Chemistry',
      questionIds: ['q_chem_1', 'q_chem_2', 'q_chem_3'],
    );

    await insertAttempt(
      db,
      id: 'att_1',
      examId: 'upcat',
      items: [
        (questionId: 'q_chem_1', isCorrect: true),
        (questionId: 'q_chem_2', isCorrect: false),
        (questionId: 'q_chem_3', isCorrect: false),
      ],
    );

    final ranked = await container.read(topicAccuracyProvider.future);
    final topic = ranked.firstWhere((t) => t.topicId == 'chemistry');

    expect(topic.answered, 3);
    expect(topic.isMeasured, isTrue);
    expect(topic.accuracy, closeTo(1 / 3, 0.001));
  });

  test('assessment attempts count toward accuracy', () async {
    await setupExam('upcat');
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'upcat',
      topicId: 'chemistry',
      topicName: 'Chemistry',
      questionIds: ['q_chem_1', 'q_chem_2', 'q_chem_3'],
    );

    // One attempt row with origin 'assessment', 3 items, 1 correct.
    await insertAttempt(
      db,
      id: 'att_1',
      examId: 'upcat',
      origin: 'assessment',
      items: [
        (questionId: 'q_chem_1', isCorrect: true),
        (questionId: 'q_chem_2', isCorrect: false),
        (questionId: 'q_chem_3', isCorrect: false),
      ],
    );

    final ranked = await container.read(topicAccuracyProvider.future);
    final topic = ranked.firstWhere((t) => t.topicId == 'chemistry');

    expect(topic.answered, 3);
    expect(topic.correct, 1);
  });

  test('an unfinished attempt is not counted', () async {
    await setupExam('upcat');
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'upcat',
      topicId: 'chemistry',
      topicName: 'Chemistry',
      questionIds: ['q_chem_1'],
    );

    // One row with completedAt null.
    await insertAttempt(
      db,
      id: 'att_1',
      examId: 'upcat',
      isCompleted: false,
      items: [
        (questionId: 'q_chem_1', isCorrect: true),
      ],
    );

    final ranked = await container.read(topicAccuracyProvider.future);
    expect(ranked.firstWhere((t) => t.topicId == 'chemistry').answered, 0);
  });

  test('a topic from another exam never appears', () async {
    await setupExam('upcat');
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'upcat',
      topicId: 'chemistry',
      topicName: 'Chemistry',
      questionIds: ['q_chem_1'],
    );
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'cse',
      topicId: 'cse-only-topic',
      topicName: 'CSE Topic',
      questionIds: ['q_cse_1'],
    );

    final ranked = await container.read(topicAccuracyProvider.future);
    expect(ranked.map((t) => t.topicId), isNot(contains('cse-only-topic')));
  });
}
