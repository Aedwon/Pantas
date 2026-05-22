import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/sync/local_state_wiper.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  test('hasMeaningfulProgress is false for only preferences', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await db.into(db.devicePrefs).insert(
          DevicePrefsCompanion.insert(key: 'selected_exam_id', value: 'cse'),
        );

    expect(await SyncLocalStateWiper(db).hasMeaningfulProgress(), isFalse);
  });

  test('hasMeaningfulProgress is true for quiz attempts', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await db.into(db.attemptsLocal).insert(
          AttemptsLocalCompanion.insert(
            id: 'a1',
            examId: 'cse',
            startedAt: DateTime.utc(2026, 5, 18),
            completedAt: const Value(null),
            itemsJson: '[]',
          ),
        );

    expect(await SyncLocalStateWiper(db).hasMeaningfulProgress(), isTrue);
  });

  test('hasMeaningfulProgress is true for lesson progress', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await db.into(db.lessonProgressLocal).insert(
          LessonProgressLocalCompanion.insert(
            lessonId: 'lesson_1',
            readAt: DateTime.utc(2026, 5, 18),
          ),
        );

    expect(await SyncLocalStateWiper(db).hasMeaningfulProgress(), isTrue);
  });

  test('hasMeaningfulProgress is true for review state', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await db.into(db.reviewStateLocal).insert(
          ReviewStateLocalCompanion.insert(
            questionId: 'q1',
            questionVersion: 1,
            stage: 'review',
            stability: 1,
            difficulty: 1,
            due: DateTime.utc(2026, 5, 19),
            lastReview: DateTime.utc(2026, 5, 18),
            reps: 1,
            lapses: 0,
            elapsedDays: 1,
            scheduledDays: 1,
          ),
        );

    expect(await SyncLocalStateWiper(db).hasMeaningfulProgress(), isTrue);
  });
}
