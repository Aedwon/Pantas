import 'dart:convert';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/home/application/performance/topic_detail.dart';

import '../../../../helpers/in_memory_database.dart';

const examId = 'exam_upcat';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;
  late ProviderContainer container;
  var today = <String>{};

  setUp(() async {
    today = {};
    db = inMemoryDatabase();
    contentDb = ContentDatabase(NativeDatabase.memory());
    await seedContentTopicWithQuestions(
      contentDb,
      examId: examId,
      subjectId: 'math',
      topicId: 'geo',
      topicName: 'Geometry',
      questionIds: ['q1', 'q2', 'q3'],
      lessonIds: const ['l1', 'l2', 'l3'],
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
        todayLessonIdsProvider.overrideWith((ref, examId) async => today),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
    await contentDb.close();
  });

  Future<void> answered(List<bool> results) =>
      db.into(db.attemptsLocal).insertOnConflictUpdate(
            AttemptsLocalCompanion.insert(
              id: 'a1',
              examId: examId,
              origin: const Value('practice'),
              startedAt: DateTime(2026, 8),
              completedAt: Value(DateTime(2026, 8, 1, 0, 20)),
              itemsJson: jsonEncode([
                for (var i = 0; i < results.length; i++)
                  {
                    'questionId': 'q${i + 1}',
                    'questionVersion': 1,
                    'chosenChoiceId': results[i] ? 'c_a' : 'c_b',
                    'correctChoiceId': 'c_a',
                    'responseMs': 9000,
                  },
              ]),
            ),
          );

  test('carries the measured accuracy, answered count and parent subject',
      () async {
    await answered([true, false, false, true]);
    final detail = await container.read(topicDetailProvider('geo').future);
    expect(detail.name, 'Geometry');
    expect(detail.subject, 'Mathematics');
    expect(detail.answered, 3);
    expect(detail.correct, 1);
  });

  test('lists the topic lessons in order with their stored read state',
      () async {
    await db.into(db.lessonProgressLocal).insertOnConflictUpdate(
          LessonProgressLocalCompanion(
            lessonId: const Value('l1'),
            readAt: Value(DateTime(2026, 8)),
          ),
        );
    final detail = await container.read(topicDetailProvider('geo').future);
    expect(detail.lessons.map((l) => l.id), ['l1', 'l2', 'l3']);
    expect(detail.lessons.map((l) => l.read), [true, false, false]);
    expect(detail.lessonsRead, 1);
  });

  test('tags only the lessons actually planned for today', () async {
    today = {'l3'};
    final detail = await container.read(topicDetailProvider('geo').future);
    expect(detail.lessons.map((l) => l.today), [false, false, true]);
  });

  test('an unknown topic fails recoverably', () async {
    await expectLater(
      container.read(topicDetailProvider('nope').future),
      throwsA(isA<StateError>()),
    );
  });
}
