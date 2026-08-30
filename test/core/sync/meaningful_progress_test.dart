import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/engine/sync_meaningful_progress.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  test('device-local state and in-progress mocks are not sync-meaningful',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final stamp = DateTime.utc(2026, 8, 30);

    await db.into(db.accountPrefs).insert(
          AccountPrefsCompanion.insert(key: 'reminder_time', value: '07:30'),
        );
    await db.into(db.streakLocal).insert(
          StreakLocalCompanion.insert(current: const Value(5)),
        );
    await db.into(db.mockAttempts).insert(
          MockAttemptsCompanion.insert(
            id: 'mock-local',
            userId: 'user-1',
            examId: 'cse',
            blueprintId: 'bp-1',
            blueprintName: 'Practice',
            durationMinutes: 30,
            status: 'in_progress',
            strictMode: false,
            sampledQuestionsJson: '[]',
            startedAt: stamp,
            lastFlushedAt: stamp,
            updatedAt: stamp,
          ),
        );

    expect(await SyncMeaningfulProgress(db).hasMeaningfulData(), isFalse);
  });

  for (final status in ['completed', 'discarded', 'forfeited']) {
    test('terminal mock status $status is sync-meaningful', () async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final stamp = DateTime.utc(2026, 8, 30);

      await db.into(db.mockAttempts).insert(
            MockAttemptsCompanion.insert(
              id: 'mock-$status',
              userId: 'user-1',
              examId: 'cse',
              blueprintId: 'bp-1',
              blueprintName: 'Practice',
              durationMinutes: 30,
              status: status,
              strictMode: false,
              sampledQuestionsJson: '[]',
              startedAt: stamp,
              lastFlushedAt: stamp,
              submittedAt: Value(stamp),
              updatedAt: stamp,
            ),
          );

      expect(await SyncMeaningfulProgress(db).hasMeaningfulData(), isTrue);
    });
  }

  test('custom-track metadata alone is sync-meaningful', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    await db.into(db.customTrackMetaLocal).insert(
          CustomTrackMetaLocalCompanion.insert(
            examId: 'exam_custom_all',
            name: 'Everything included',
          ),
        );

    expect(await SyncMeaningfulProgress(db).hasMeaningfulData(), isTrue);
  });

  test('review logs are sync-meaningful', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final stamp = DateTime.utc(2026, 8, 30);

    await db.into(db.reviewLogs).insert(
          ReviewLogsCompanion.insert(
            id: 'review-1',
            questionId: 'q-1',
            rating: 3,
            state: 2,
            due: stamp,
            stability: 1,
            difficulty: 5,
            elapsedDays: 1,
            lastElapsedDays: 1,
            scheduledDays: 3,
            review: stamp,
            durationMs: 800,
            isCorrect: true,
          ),
        );

    expect(await SyncMeaningfulProgress(db).hasMeaningfulData(), isTrue);
  });

  test('custom blueprints are sync-meaningful', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await seedTopicWithQuestions(
      db,
      examId: 'exam_custom_1',
      topicId: 'topic-1',
      topicName: 'Topic',
      questionIds: const [],
    );

    await db.into(db.customBlueprintsLocal).insert(
          CustomBlueprintsLocalCompanion.insert(
            examId: 'exam_custom_1',
            totalQuestions: 50,
            totalMinutes: 60,
            sectionsJson: '[]',
            updatedAt: DateTime.utc(2026, 8, 30),
          ),
        );

    expect(await SyncMeaningfulProgress(db).hasMeaningfulData(), isTrue);
  });
}
