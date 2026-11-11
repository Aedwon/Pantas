import 'dart:convert';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/home/application/performance/performance_view.dart';

import '../../../../helpers/in_memory_database.dart';

const examId = 'exam_upcat';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;
  late ProviderContainer container;

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = ContentDatabase(NativeDatabase.memory());
    await seedContentTopicWithQuestions(
      contentDb,
      examId: examId,
      subjectId: 'sci',
      topicId: 'chem',
      topicName: 'Chemistry',
      questionIds: ['q_c1', 'q_c2'],
      lessonIds: const ['les_chem'],
      questionLessonMap: const {'q_c1': 'les_chem'},
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
      questionIds: ['q_a1'],
    );
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
    await contentDb.close();
  });

  Future<void> attempt(String id, String origin, List<(String, bool)> items) =>
      db.into(db.attemptsLocal).insertOnConflictUpdate(
            AttemptsLocalCompanion.insert(
              id: id,
              examId: examId,
              origin: Value(origin),
              startedAt: DateTime(2026, 8),
              completedAt: Value(DateTime(2026, 8, 1, 0, 20)),
              itemsJson: jsonEncode([
                for (final (questionId, correct) in items)
                  {
                    'questionId': questionId,
                    'questionVersion': 1,
                    'chosenChoiceId': correct ? 'c_a' : 'c_b',
                    'correctChoiceId': 'c_a',
                    'responseMs': 12000,
                  },
              ]),
            ),
          );

  test('every finished session counts whatever its origin (D-15)', () async {
    await attempt('a1', 'practice', [('q_c1', true), ('q_c2', false)]);
    await attempt('a2', 'assessment', [('q_p1', true)]);
    await attempt('a3', 'today_topic', [('q_a1', false)]);
    final view = await container.read(performanceViewProvider.future);
    final answered = view.subjects.fold(0, (sum, r) => sum + r.answered);
    expect(answered, 4);
  });

  test('topic and lesson rows map to their parent subject', () async {
    await attempt('a1', 'practice', [('q_c1', true), ('q_a1', false)]);
    final view = await container.read(performanceViewProvider.future);
    expect(view.parentSubjectIds['chem'], 'sci');
    expect(view.parentSubjectIds['alg'], 'math');
    expect(view.parentSubjectIds['les_chem'], 'sci');
  });

  test('subject counts count only topics with answers', () async {
    await attempt('a1', 'practice', [('q_c1', true), ('q_a1', false)]);
    final view = await container.read(performanceViewProvider.future);
    expect(view.subjectCounts['sci'], 1);
    expect(view.subjectCounts['math'], 1);
  });

  test('the lesson level exists once questions carry a lesson', () async {
    await attempt('a1', 'practice', [('q_c1', true)]);
    final view = await container.read(performanceViewProvider.future);
    expect(view.lessonLevelAvailable, isTrue);
    expect(view.lessons.where((r) => r.answered > 0).single.id, 'les_chem');
  });
}
