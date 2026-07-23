import 'dart:convert';

import 'package:cse_cet_reviewer/core/content/content.dart';
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/home/application/up_next_provider.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
            origin: const Value('today_topic'),
            itemsJson: itemsJson,
          ),
        );
  }

  Future<void> seedLesson(
    AppDatabase db, {
    required String lessonId,
    required String topicId,
    required String title,
    required String subjectName,
    int estimatedMinutes = 9,
    int ordering = 0,
  }) async {
    final topicRow = await (db.select(db.topics)
          ..where((t) => t.id.equals(topicId)))
        .getSingleOrNull();
    if (topicRow == null) {
      final subjectId = 'subj_$topicId';
      await db.into(db.subjects).insertOnConflictUpdate(
            SubjectsCompanion.insert(
              id: subjectId,
              examId: 'upcat',
              name: subjectName,
              ordering: 0,
            ),
          );
      await db.into(db.topics).insertOnConflictUpdate(
            TopicsCompanion.insert(
              id: topicId,
              subjectId: subjectId,
              name: topicId,
              ordering: 0,
            ),
          );
    }
    await db.into(db.lessons).insertOnConflictUpdate(
          LessonsCompanion.insert(
            id: lessonId,
            topicId: topicId,
            title: title,
            summary: 'summary',
            bodyJson: jsonEncode([]),
            estimatedMinutes: estimatedMinutes,
            ordering: Value(ordering),
          ),
        );
  }

  Future<void> markLessonRead(AppDatabase db, String lessonId) async {
    await db.into(db.lessonProgressLocal).insertOnConflictUpdate(
          LessonProgressLocalCompanion.insert(
            lessonId: lessonId,
            readAt: DateTime.now(),
          ),
        );
  }

  test('takes unread lessons from the weakest topics first', () async {
    await setupExam('upcat');
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'upcat',
      topicId: 'chemistry',
      topicName: 'Chemistry',
      subjectId: 'subj_chem',
      questionIds: ['q_chem_1', 'q_chem_2', 'q_chem_3', 'q_chem_4', 'q_chem_5'],
    );
    await db.into(db.subjects).insertOnConflictUpdate(
          SubjectsCompanion.insert(
            id: 'subj_chem',
            examId: 'upcat',
            name: 'Chemistry',
            ordering: 0,
          ),
        );
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'upcat',
      topicId: 'algebra',
      topicName: 'Algebra',
      subjectId: 'subj_alg',
      questionIds: ['q_alg_1', 'q_alg_2', 'q_alg_3', 'q_alg_4', 'q_alg_5'],
    );
    await db.into(db.subjects).insertOnConflictUpdate(
          SubjectsCompanion.insert(
            id: 'subj_alg',
            examId: 'upcat',
            name: 'Algebra',
            ordering: 0,
          ),
        );
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'upcat',
      topicId: 'geometry',
      topicName: 'Geometry',
      subjectId: 'subj_geo',
      questionIds: ['q_geo_1', 'q_geo_2', 'q_geo_3', 'q_geo_4', 'q_geo_5'],
    );
    await db.into(db.subjects).insertOnConflictUpdate(
          SubjectsCompanion.insert(
            id: 'subj_geo',
            examId: 'upcat',
            name: 'Geometry',
            ordering: 0,
          ),
        );

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
        (questionId: 'q_alg_3', isCorrect: false),
        (questionId: 'q_alg_4', isCorrect: false),
        (questionId: 'q_geo_1', isCorrect: true),
        (questionId: 'q_geo_2', isCorrect: true),
        (questionId: 'q_geo_3', isCorrect: true),
        (questionId: 'q_geo_4', isCorrect: true),
        (questionId: 'q_geo_5', isCorrect: true),
      ],
    );

    await seedLesson(
      db,
      lessonId: 'chem-01',
      topicId: 'chemistry',
      title: 'Chem 1',
      subjectName: 'Chemistry',
      ordering: 1,
    );
    await seedLesson(
      db,
      lessonId: 'chem-02',
      topicId: 'chemistry',
      title: 'Chem 2',
      subjectName: 'Chemistry',
      ordering: 2,
    );
    await seedLesson(
      db,
      lessonId: 'alg-01',
      topicId: 'algebra',
      title: 'Alg 1',
      subjectName: 'Algebra',
      ordering: 1,
    );
    await seedLesson(
      db,
      lessonId: 'alg-02',
      topicId: 'algebra',
      title: 'Alg 2',
      subjectName: 'Algebra',
      ordering: 2,
    );
    await seedLesson(
      db,
      lessonId: 'alg-03',
      topicId: 'algebra',
      title: 'Alg 3',
      subjectName: 'Algebra',
      ordering: 3,
    );

    final day = await container.read(upNextProvider.future);

    expect(
      day.lessons.map((l) => l.topicId),
      ['chemistry', 'chemistry', 'algebra'],
    );
  });

  test('never returns a lesson already read', () async {
    await setupExam('upcat');
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'upcat',
      topicId: 'chemistry',
      topicName: 'Chemistry',
      subjectId: 'subj_chem',
      questionIds: ['q_chem_1', 'q_chem_2', 'q_chem_3'],
    );
    await db.into(db.subjects).insertOnConflictUpdate(
          SubjectsCompanion.insert(
            id: 'subj_chem',
            examId: 'upcat',
            name: 'Chemistry',
            ordering: 0,
          ),
        );
    await insertAttempt(
      db,
      id: 'att_1',
      examId: 'upcat',
      items: [
        (questionId: 'q_chem_1', isCorrect: false),
        (questionId: 'q_chem_2', isCorrect: false),
        (questionId: 'q_chem_3', isCorrect: false),
      ],
    );
    await seedLesson(
      db,
      lessonId: 'chem-01',
      topicId: 'chemistry',
      title: 'Chem 1',
      subjectName: 'Chemistry',
      ordering: 1,
    );
    await seedLesson(
      db,
      lessonId: 'chem-02',
      topicId: 'chemistry',
      title: 'Chem 2',
      subjectName: 'Chemistry',
      ordering: 2,
    );

    await markLessonRead(db, 'chem-01');

    final day = await container.read(upNextProvider.future);

    expect(day.lessons.map((l) => l.lessonId), isNot(contains('chem-01')));
    expect(day.lessons.map((l) => l.lessonId), contains('chem-02'));
  });

  test('stops at three', () async {
    await setupExam('upcat');
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'upcat',
      topicId: 'chemistry',
      topicName: 'Chemistry',
      subjectId: 'subj_chem',
      questionIds: ['q_chem_1', 'q_chem_2', 'q_chem_3'],
    );
    await db.into(db.subjects).insertOnConflictUpdate(
          SubjectsCompanion.insert(
            id: 'subj_chem',
            examId: 'upcat',
            name: 'Chemistry',
            ordering: 0,
          ),
        );
    await insertAttempt(
      db,
      id: 'att_1',
      examId: 'upcat',
      items: [
        (questionId: 'q_chem_1', isCorrect: false),
        (questionId: 'q_chem_2', isCorrect: false),
        (questionId: 'q_chem_3', isCorrect: false),
      ],
    );
    await seedLesson(
      db,
      lessonId: 'chem-01',
      topicId: 'chemistry',
      title: 'Chem 1',
      subjectName: 'Chemistry',
      ordering: 1,
    );
    await seedLesson(
      db,
      lessonId: 'chem-02',
      topicId: 'chemistry',
      title: 'Chem 2',
      subjectName: 'Chemistry',
      ordering: 2,
    );
    await seedLesson(
      db,
      lessonId: 'chem-03',
      topicId: 'chemistry',
      title: 'Chem 3',
      subjectName: 'Chemistry',
      ordering: 3,
    );
    await seedLesson(
      db,
      lessonId: 'chem-04',
      topicId: 'chemistry',
      title: 'Chem 4',
      subjectName: 'Chemistry',
      ordering: 4,
    );

    final day = await container.read(upNextProvider.future);
    expect(day.lessons, hasLength(3));
  });

  test('all read in the weak topics is a distinct state from no content',
      () async {
    await setupExam('upcat');
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'upcat',
      topicId: 'chemistry',
      topicName: 'Chemistry',
      subjectId: 'subj_chem',
      questionIds: ['q_chem_1', 'q_chem_2', 'q_chem_3'],
    );
    await db.into(db.subjects).insertOnConflictUpdate(
          SubjectsCompanion.insert(
            id: 'subj_chem',
            examId: 'upcat',
            name: 'Chemistry',
            ordering: 0,
          ),
        );
    await insertAttempt(
      db,
      id: 'att_1',
      examId: 'upcat',
      items: [
        (questionId: 'q_chem_1', isCorrect: false),
        (questionId: 'q_chem_2', isCorrect: false),
        (questionId: 'q_chem_3', isCorrect: false),
      ],
    );
    await seedLesson(
      db,
      lessonId: 'chem-01',
      topicId: 'chemistry',
      title: 'Chem 1',
      subjectName: 'Chemistry',
    );
    await markLessonRead(db, 'chem-01');

    final day = await container.read(upNextProvider.future);

    expect(day.lessons, isEmpty);
    expect(day.allReadInWeakTopics, isTrue);
  });

  test('no lessons at all is not reported as all read', () async {
    await setupExam('upcat');
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'upcat',
      topicId: 'chemistry',
      topicName: 'Chemistry',
      subjectId: 'subj_chem',
      questionIds: ['q_chem_1', 'q_chem_2', 'q_chem_3'],
    );
    await db.into(db.subjects).insertOnConflictUpdate(
          SubjectsCompanion.insert(
            id: 'subj_chem',
            examId: 'upcat',
            name: 'Chemistry',
            ordering: 0,
          ),
        );

    final day = await container.read(upNextProvider.future);

    expect(day.lessons, isEmpty);
    expect(day.allReadInWeakTopics, isFalse);
  });

  test('a topic with no answered questions does not jump the ranking',
      () async {
    await setupExam('upcat');
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'upcat',
      topicId: 'chemistry',
      topicName: 'Chemistry',
      subjectId: 'subj_chem',
      questionIds: ['q_chem_1', 'q_chem_2', 'q_chem_3'],
    );
    await db.into(db.subjects).insertOnConflictUpdate(
          SubjectsCompanion.insert(
            id: 'subj_chem',
            examId: 'upcat',
            name: 'Chemistry',
            ordering: 0,
          ),
        );
    await seedContentTopicWithQuestions(
      contentDb,
      examId: 'upcat',
      topicId: 'algebra',
      topicName: 'Algebra',
      subjectId: 'subj_alg',
      questionIds: ['q_alg_1', 'q_alg_2', 'q_alg_3'],
    );
    await db.into(db.subjects).insertOnConflictUpdate(
          SubjectsCompanion.insert(
            id: 'subj_alg',
            examId: 'upcat',
            name: 'Algebra',
            ordering: 0,
          ),
        );

    await insertAttempt(
      db,
      id: 'att_1',
      examId: 'upcat',
      items: [
        (questionId: 'q_chem_1', isCorrect: false),
        (questionId: 'q_chem_2', isCorrect: false),
        (questionId: 'q_chem_3', isCorrect: false),
      ],
    );

    await seedLesson(
      db,
      lessonId: 'chem-01',
      topicId: 'chemistry',
      title: 'Chem 1',
      subjectName: 'Chemistry',
    );
    await seedLesson(
      db,
      lessonId: 'alg-01',
      topicId: 'algebra',
      title: 'Alg 1',
      subjectName: 'Algebra',
    );

    final day = await container.read(upNextProvider.future);

    expect(day.lessons.first.topicId, 'chemistry');
  });
}
