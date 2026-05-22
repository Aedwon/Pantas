import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/sync/bootstrap/full_push.dart';
import 'package:cse_cet_reviewer/core/sync/firestore/firestore_gateway.dart';
import 'package:cse_cet_reviewer/core/sync/firestore/functions_gateway.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  test('full push calls resetCloudUserData before writing rows', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final gateway = RecordingGateway();
    final functions = RecordingFunctionsGateway(gateway.events);

    await FullPushBootstrap(
      db: db,
      gateway: gateway,
      functionsGateway: functions,
      uid: 'user-1',
      deviceId: 'device-1',
      now: () => DateTime.utc(2026, 5, 18),
    ).run();

    expect(gateway.events.first, 'reset');
  });

  test('full push writes all current local synced rows', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await _seedSyncedRows(db);
    final gateway = RecordingGateway();

    await FullPushBootstrap(
      db: db,
      gateway: gateway,
      functionsGateway: RecordingFunctionsGateway(gateway.events),
      uid: 'user-1',
      deviceId: 'device-1',
      now: () => DateTime.utc(2026, 5, 18),
    ).run();

    expect(gateway.paths, contains('users/user-1/quiz_attempts/attempt_1'));
    expect(gateway.paths, contains('users/user-1/assessments/cse'));
    expect(gateway.paths, contains('users/user-1/fsrs_cards/q1'));
    expect(gateway.paths, contains('users/user-1/lesson_progress/lesson_1'));
  });

  test('full push writes account preferences to root user document', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await db.into(db.accountPrefs).insert(
          AccountPrefsCompanion.insert(
            key: 'reminder_time',
            value: '07:30',
          ),
        );
    final gateway = RecordingGateway();

    await FullPushBootstrap(
      db: db,
      gateway: gateway,
      functionsGateway: RecordingFunctionsGateway(gateway.events),
      uid: 'user-1',
      deviceId: 'device-1',
      now: () => DateTime.utc(2026, 5, 18),
    ).run();

    final rootWrite =
        gateway.writes.singleWhere((write) => write.path == 'users/user-1');
    expect(rootWrite.data['preferences'], {'reminder_time': '07:30'});
  });

  test('full push clears pending_full_push marker after success', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    await FullPushBootstrap(
      db: db,
      gateway: RecordingGateway(),
      functionsGateway: FakeSyncFunctionsGateway(),
      uid: 'user-1',
      deviceId: 'device-1',
      now: () => DateTime.utc(2026, 5, 18),
    ).run();

    final marker = await (db.select(db.syncMeta)
          ..where((row) => row.key.equals('pending_full_push')))
        .getSingleOrNull();
    expect(marker, isNull);
  });

  test('full push leaves pending_full_push marker after retryable failure',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    await FullPushBootstrap(
      db: db,
      gateway: ThrowingGateway(),
      functionsGateway: FakeSyncFunctionsGateway(),
      uid: 'user-1',
      deviceId: 'device-1',
      now: () => DateTime.utc(2026, 5, 18),
    ).run();

    final marker = await (db.select(db.syncMeta)
          ..where((row) => row.key.equals('pending_full_push')))
        .getSingle();
    expect(marker.value, '1');
  });
}

Future<void> _seedSyncedRows(AppDatabase db) async {
  await db.into(db.attemptsLocal).insert(
        AttemptsLocalCompanion.insert(
          id: 'attempt_1',
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

class RecordingGateway extends FakeFirestoreGateway {
  final events = <String>[];

  List<FirestoreWrite> get writes =>
      committedBatches.expand((batch) => batch).toList(growable: false);

  List<String> get paths => writes.map((write) => write.path).toList();

  @override
  Future<void> commitBatch(List<FirestoreWrite> writes) async {
    events.add('commit');
    await super.commitBatch(writes);
  }
}

class RecordingFunctionsGateway implements SyncFunctionsGateway {
  RecordingFunctionsGateway(this.events);

  final List<String> events;

  @override
  Future<void> resetCloudUserData() async {
    events.add('reset');
  }
}

class ThrowingGateway implements FirestoreGateway {
  @override
  Future<void> commitBatch(List<FirestoreWrite> writes) async {
    throw const SyncGatewayException('unavailable');
  }
}
