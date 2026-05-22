import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/sync/local_state_wiper.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  test('wipeAll deletes synced state and pending sync', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await _seedMeaningfulProgress(db);
    await db.into(db.accountPrefs).insert(
          AccountPrefsCompanion.insert(key: 'reminder_time', value: '07:30'),
        );
    await db.into(db.pendingSync).insert(
          PendingSyncCompanion.insert(
            tableType: 'quiz_attempts',
            rowId: 'a1',
            op: 'upsert',
            queuedAt: DateTime.utc(2026, 5, 18),
          ),
        );

    await SyncLocalStateWiper(db).wipeAll();

    expect(await db.select(db.attemptsLocal).get(), isEmpty);
    expect(await db.select(db.assessmentResultsLocal).get(), isEmpty);
    expect(await db.select(db.reviewStateLocal).get(), isEmpty);
    expect(await db.select(db.lessonProgressLocal).get(), isEmpty);
    expect(await db.select(db.accountPrefs).get(), isEmpty);
    expect(await db.select(db.pendingSync).get(), isEmpty);
  });

  test('wipeAll preserves device prefs streak nudge and deviceId', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await db.into(db.devicePrefs).insert(
          DevicePrefsCompanion.insert(key: 'selected_exam_id', value: 'cse'),
        );
    await db.into(db.streakLocal).insert(
          StreakLocalCompanion.insert(current: const Value(1)),
        );
    await db.into(db.quizNudgeDismissedLocal).insert(
          QuizNudgeDismissedLocalCompanion.insert(
            dismissedAt: DateTime.utc(2026, 5, 18),
          ),
        );
    await db.into(db.syncMeta).insert(
          SyncMetaCompanion.insert(key: 'deviceId', value: 'device-1'),
        );
    await db.into(db.syncMeta).insert(
          SyncMetaCompanion.insert(key: 'failedSince', value: 'yesterday'),
        );

    await SyncLocalStateWiper(db).wipeAll();

    expect(await db.select(db.devicePrefs).get(), hasLength(1));
    expect(await db.select(db.streakLocal).get(), hasLength(1));
    expect(await db.select(db.quizNudgeDismissedLocal).get(), hasLength(1));
    expect((await db.select(db.syncMeta).get()).single.key, 'deviceId');
  });
}

Future<void> _seedMeaningfulProgress(AppDatabase db) async {
  await db.into(db.attemptsLocal).insert(
        AttemptsLocalCompanion.insert(
          id: 'a1',
          examId: 'cse',
          startedAt: DateTime.utc(2026, 5, 18),
          completedAt: const Value(null),
          itemsJson: '[]',
        ),
      );
  await db.into(db.assessmentResultsLocal).insert(
        AssessmentResultsLocalCompanion.insert(
          examId: 'cse',
          completedAt: DateTime.utc(2026, 5, 18),
          topicScoresJson: '{}',
        ),
      );
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
  await db.into(db.lessonProgressLocal).insert(
        LessonProgressLocalCompanion.insert(
          lessonId: 'lesson_1',
          readAt: DateTime.utc(2026, 5, 18),
        ),
      );
}
