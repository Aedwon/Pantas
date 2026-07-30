import 'dart:convert';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/progress/application/performance_provider.dart';
import 'package:pantas/features/progress/application/table_order_prefs.dart';

import '../../../helpers/in_memory_database.dart';

const examId = 'exam_upcat';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;
  late ProviderContainer container;

  setUp(() {
    db = inMemoryDatabase();
    contentDb = ContentDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    container.dispose();
    await db.close();
    await contentDb.close();
  });

  /// Science holds Chemistry and Physics, Mathematics holds Algebra.
  Future<void> seedSyllabus({
    Map<String, String?> questionLessons = const {},
  }) async {
    await seedContentTopicWithQuestions(
      contentDb,
      examId: examId,
      subjectId: 'sci',
      topicId: 'chem',
      topicName: 'Chemistry',
      questionIds: ['q_c1', 'q_c2', 'q_c3', 'q_c4'],
      lessonIds: const ['les_chem'],
      questionLessonMap: {
        for (final entry in questionLessons.entries)
          if (entry.value != null) entry.key: entry.value!,
      },
    );
    await seedContentTopicWithQuestions(
      contentDb,
      examId: examId,
      subjectId: 'sci',
      topicId: 'phys',
      topicName: 'Physics',
      questionIds: ['q_p1'],
    );
    await seedContentTopicWithQuestions(
      contentDb,
      examId: examId,
      subjectId: 'math',
      topicId: 'alg',
      topicName: 'Algebra',
      questionIds: ['q_a1', 'q_a2'],
    );
    // The helper names a subject after its id; these are the names the rows
    // are asserted by.
    await seedContentSubject(
      contentDb,
      subjectId: 'sci',
      examId: examId,
      name: 'Science',
      ordering: 0,
    );
    await seedContentSubject(
      contentDb,
      subjectId: 'math',
      examId: examId,
      name: 'Mathematics',
    );
    await AppPreferencesRepository(db).setSelectedExamId(examId);
  }

  /// One attempt row holding [items], each `(questionId, isCorrect)`.
  Future<void> seedAttempt(
    String id,
    List<(String, bool)> items, {
    String origin = 'practice',
  }) async {
    await db.into(db.attemptsLocal).insertOnConflictUpdate(
          AttemptsLocalCompanion.insert(
            id: id,
            examId: examId,
            origin: Value(origin),
            startedAt: DateTime(2026, 8),
            completedAt: Value(DateTime(2026, 8, 1, 0, 20)),
            itemsJson: jsonEncode([
              for (final (questionId, isCorrect) in items)
                {
                  'questionId': questionId,
                  'questionVersion': 1,
                  'chosenChoiceId': isCorrect ? 'c_a' : 'c_b',
                  'correctChoiceId': 'c_a',
                  'responseMs': 12000,
                },
            ]),
          ),
        );
  }

  /// A submitted mock whose single section covers Science and took
  /// [timeSeconds] over [total] questions.
  Future<void> seedSubmittedMock({
    int timeSeconds = 600,
    List<String> questionIds = const ['q_c1', 'q_c2', 'q_c3', 'q_c4'],
    DateTime? submittedAt,
  }) async {
    await db.into(db.mockAttempts).insertOnConflictUpdate(
          MockAttemptsCompanion.insert(
            id: 'mock_1',
            userId: 'local',
            examId: examId,
            blueprintId: 'bp_1',
            blueprintName: 'Full length',
            durationMinutes: 60,
            status: 'completed',
            strictMode: true,
            sampledQuestionsJson: jsonEncode([
              {
                'sectionId': 'sec_sci',
                'name': 'Science',
                'questionIds': questionIds,
              },
            ]),
            startedAt: DateTime(2026, 8, 2),
            lastFlushedAt: DateTime(2026, 8, 2),
            updatedAt: DateTime(2026, 8, 2),
            submittedAt: Value(submittedAt ?? DateTime(2026, 8, 2, 1)),
            totalTimeSeconds: Value(timeSeconds),
            sectionResultsJson: Value(
              jsonEncode([
                {
                  'sectionId': 'sec_sci',
                  'name': 'Science',
                  'correct': 3,
                  'total': questionIds.length,
                  'retiredCount': 0,
                  'timeSeconds': timeSeconds,
                },
              ]),
            ),
          ),
        );
  }

  /// The published paper: one Science section of 180 questions.
  Future<void> seedBlueprint({
    List<String> topicIds = const ['chem', 'phys'],
    int questionCount = 180,
  }) async {
    await contentDb
        .into(contentDb.contentMockBlueprints)
        .insertOnConflictUpdate(
          ContentMockBlueprintsCompanion.insert(
            id: 'bp_1',
            examId: examId,
            name: 'Full length',
            durationMinutes: 60,
            schemaVersion: 1,
            updatedAt: DateTime(2026, 8),
            sectionsJson: jsonEncode([
              {
                'id': 'sec_sci',
                'name': 'Science',
                'questionCount': questionCount,
                'suggestedMinutes': 60,
                'topicIds': topicIds,
                'topicWeights': <String, double>{},
              },
            ]),
          ),
        );
  }

  ProviderContainer build() {
    return container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
  }

  Future<PerformanceTable> read(
    TableLevel level, {
    String? subjectId,
  }) {
    return build().read(
      performanceProvider(
        PerformanceQuery(level: level, subjectId: subjectId),
      ).future,
    );
  }

  test('subject level groups by subject and carries the published size',
      () async {
    await seedSyllabus();
    await seedAttempt('att_1', [
      ('q_c1', true),
      ('q_c2', false),
      ('q_c3', true),
      ('q_p1', true),
    ]);
    await seedBlueprint();

    final table = await read(TableLevel.subject);

    final science = table.rows.firstWhere((r) => r.title == 'Science');
    expect(science.answered, 4);
    expect(science.correct, 3);
    expect(science.subtext, '4 of 180 questions');
  });

  test('with no blueprint the subject subtext drops the size clause', () async {
    await seedSyllabus();
    await seedAttempt('att_1', [('q_c1', true)]);

    final table = await read(TableLevel.subject);

    final science = table.rows.firstWhere((r) => r.title == 'Science');
    expect(science.subtext, isNull);
  });

  test(
      'a subject with no matching blueprint section carries null subtext '
      'rather than zero', () async {
    await seedSyllabus();
    await seedAttempt('att_1', [('q_c1', true), ('q_a1', true)]);
    // Blueprint only has Science section, not Mathematics
    await seedBlueprint();

    final table = await read(TableLevel.subject);

    final math = table.rows.firstWhere((r) => r.title == 'Mathematics');
    expect(math.subtext, isNull);
  });

  test('topic level carries the parent, never a size', () async {
    await seedSyllabus();
    await seedAttempt('att_1', [('q_c1', true), ('q_c2', false)]);

    final table = await read(TableLevel.topic);

    final chemistry = table.rows.firstWhere((r) => r.title == 'Chemistry');
    expect(chemistry.subtext, 'Science');
    expect(chemistry.subtext, isNot(contains('questions')));
  });

  test('with no mock sat, time is not measurable and every row has none',
      () async {
    await seedSyllabus();
    await seedAttempt('att_1', [('q_c1', true)]);

    final table = await read(TableLevel.subject);

    expect(table.timeIsMeasurable, isFalse);
    expect(table.rows.every((r) => r.secondsPerQuestion == null), isTrue);
  });

  test('practice time never fills the column', () async {
    await seedSyllabus();
    for (var i = 0; i < 20; i += 1) {
      await seedAttempt('att_$i', [('q_c1', true), ('q_c2', false)]);
    }

    final table = await read(TableLevel.subject);

    expect(table.timeIsMeasurable, isFalse);
  });

  test('a submitted mock makes time measurable', () async {
    await seedSyllabus();
    await seedAttempt('att_1', [('q_c1', true)]);
    await seedSubmittedMock();

    final table = await read(TableLevel.subject);

    expect(table.timeIsMeasurable, isTrue);
    final science = table.rows.firstWhere((r) => r.title == 'Science');
    expect(science.secondsPerQuestion, 150);
  });

  test('a mock in progress does not make time measurable', () async {
    await seedSyllabus();
    await seedAttempt('att_1', [('q_c1', true)]);
    await db.into(db.mockAttempts).insertOnConflictUpdate(
          MockAttemptsCompanion.insert(
            id: 'mock_open',
            userId: 'local',
            examId: examId,
            blueprintId: 'bp_1',
            blueprintName: 'Full length',
            durationMinutes: 60,
            status: 'in_progress',
            strictMode: true,
            sampledQuestionsJson: jsonEncode([]),
            startedAt: DateTime(2026, 8, 2),
            lastFlushedAt: DateTime(2026, 8, 2),
            updatedAt: DateTime(2026, 8, 2),
          ),
        );

    final table = await read(TableLevel.subject);

    expect(table.timeIsMeasurable, isFalse);
  });

  test('a forfeited mock still measures the questions it reached', () async {
    await seedSyllabus();
    await seedAttempt('att_1', [('q_c1', true)]);
    await seedSubmittedMock(
      timeSeconds: 300,
      questionIds: const ['q_c1', 'q_c2'],
    );

    final table = await read(TableLevel.subject);

    expect(table.timeIsMeasurable, isTrue);
    final science = table.rows.firstWhere((r) => r.title == 'Science');
    expect(science.secondsPerQuestion, 150);
  });

  test('a section spanning two subjects fills neither row', () async {
    await seedSyllabus();
    await seedAttempt('att_1', [('q_c1', true)]);
    await seedSubmittedMock(
      questionIds: const ['q_c1', 'q_c2', 'q_a1', 'q_a2'],
    );

    final table = await read(TableLevel.subject);

    // The section's time cannot be split between Science and Mathematics
    // without assuming how it was spent, so no row claims it and the
    // column does not render.
    expect(table.rows.every((r) => r.secondsPerQuestion == null), isTrue);
    expect(table.timeIsMeasurable, isFalse);
  });

  test('assessment attempts count toward accuracy at every level', () async {
    await seedSyllabus();
    await seedAttempt(
      'att_assessment',
      [
        ('q_c1', true),
        ('q_c2', false),
        ('q_p1', true),
        ('q_a1', true),
      ],
      origin: 'assessment',
    );

    for (final level in [TableLevel.subject, TableLevel.topic]) {
      final table = await read(level);
      expect(table.rows.fold<int>(0, (s, r) => s + r.answered), 4);
    }
  });

  test('lesson level is unavailable until questions carry a lessonId',
      () async {
    await seedSyllabus();
    await seedAttempt('att_1', [('q_c1', true)]);

    final table = await read(TableLevel.subject);

    expect(table.lessonLevelAvailable, isFalse);
  });

  test('lesson level becomes available and groups by lesson', () async {
    await seedSyllabus(questionLessons: {'q_c1': 'les_chem'});
    await seedAttempt('att_1', [('q_c1', true), ('q_c2', false)]);

    final table = await read(TableLevel.lesson);

    expect(table.lessonLevelAvailable, isTrue);
    final lesson = table.rows.firstWhere((r) => r.title == 'Lesson les_chem');
    expect(lesson.answered, 1);
    expect(lesson.subtext, 'Chemistry');
  });

  test('a row with no answered questions reports a null accuracy', () async {
    await seedSyllabus();
    await seedAttempt('att_1', [('q_c1', true)]);

    final table = await read(TableLevel.topic);
    final untouched = table.rows.firstWhere((r) => r.title == 'Physics');

    expect(untouched.answered, 0);
    expect(untouched.accuracy, isNull);
  });

  test('the subject filter scopes topic rows and drops the parent subtext',
      () async {
    await seedSyllabus();
    await seedAttempt('att_1', [('q_c1', true), ('q_a1', true)]);

    final table = await read(TableLevel.topic, subjectId: 'sci');

    expect(table.rows.map((r) => r.title), isNot(contains('Algebra')));
    final chemistry = table.rows.firstWhere((r) => r.title == 'Chemistry');
    expect(chemistry.subtext, isNull);
  });

  test('subjects carry a row count and are empty below two with data',
      () async {
    await seedSyllabus();
    await seedAttempt('att_1', [('q_c1', true)]);

    final onlyScience = await read(TableLevel.topic);
    expect(onlyScience.subjects, isEmpty);

    await seedAttempt('att_2', [('q_a1', true)]);
    final both = await read(TableLevel.topic);
    expect(both.subjects.map((s) => s.name), ['Science', 'Mathematics']);
    expect(both.subjects.first.rowCount, 2);
  });
}
