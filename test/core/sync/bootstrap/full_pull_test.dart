import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/bootstrap/full_pull.dart';
import 'package:pantas/core/sync/firestore/firestore_gateway.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  test('full pull wipes local synced state before applying cloud rows',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await _seedLocalSyncedRows(db);
    final gateway = _cloudGateway();

    await FullPullBootstrap(db: db, gateway: gateway, uid: 'user-1').run();

    expect(await db.select(db.attemptsLocal).get(), hasLength(1));
    expect((await db.select(db.attemptsLocal).get()).single.id, 'cloud_a1');
    expect(await db.select(db.assessmentResultsLocal).get(), hasLength(1));
    expect(
      (await db.select(db.reviewStateLocal).get()).single.questionId,
      'q2',
    );
    expect(
      (await db.select(db.lessonProgressLocal).get()).single.lessonId,
      'lesson_2',
    );
  });

  test('full pull mirrors root preferences into account_prefs', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final gateway = _cloudGateway();

    await FullPullBootstrap(db: db, gateway: gateway, uid: 'user-1').run();

    final prefs = await db.select(db.accountPrefs).get();
    expect(prefs.map((row) => row.key), ['reminder_time']);
    expect(prefs.single.value, '07:30');
  });

  test('full pull preserves device prefs streak and quiz nudge rows', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await db.into(db.devicePrefs).insert(
          DevicePrefsCompanion.insert(key: 'selected_exam_id', value: 'cse'),
        );
    await db.into(db.streakLocal).insert(
          StreakLocalCompanion.insert(
            current: const Value(3),
            longest: const Value(5),
            lastActiveDate: Value(DateTime.utc(2026, 5, 18)),
          ),
        );
    await db.into(db.quizNudgeDismissedLocal).insert(
          QuizNudgeDismissedLocalCompanion.insert(
            dismissedAt: DateTime.utc(2026, 5, 18),
          ),
        );

    await FullPullBootstrap(db: db, gateway: _cloudGateway(), uid: 'user-1')
        .run();

    expect(await db.select(db.devicePrefs).get(), hasLength(1));
    expect(await db.select(db.streakLocal).get(), hasLength(1));
    expect(await db.select(db.quizNudgeDismissedLocal).get(), hasLength(1));
  });

  test('full pull clears pending_full_pull marker after success', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    await FullPullBootstrap(db: db, gateway: _cloudGateway(), uid: 'user-1')
        .run();

    final marker = await (db.select(db.syncMeta)
          ..where((row) => row.key.equals('pending_full_pull')))
        .getSingleOrNull();
    expect(marker, isNull);
  });
}

FakeFirestoreGateway _cloudGateway() {
  final gateway = FakeFirestoreGateway();
  gateway.collections.addAll({
    'users/user-1/quiz_attempts': [
      {
        'id': 'cloud_a1',
        'examId': 'cse',
        'startedAt': '2026-05-18T00:00:00.000Z',
        'completedAt': null,
        'itemsJson': '[]',
      },
    ],
    'users/user-1/assessments': [
      {
        'examId': 'cse',
        'completedAt': '2026-05-18T00:00:00.000Z',
        'topicScoresJson': '{}',
      },
    ],
    'users/user-1/fsrs_cards': [
      {
        'questionId': 'q2',
        'questionVersion': 1,
        'stage': 'review',
        'stability': 1,
        'difficulty': 1,
        'due': '2026-05-19T00:00:00.000Z',
        'lastReview': '2026-05-18T00:00:00.000Z',
        'reps': 1,
        'lapses': 0,
        'elapsedDays': 1,
        'scheduledDays': 1,
      },
    ],
    'users/user-1/lesson_progress': [
      {
        'lessonId': 'lesson_2',
        'readAt': '2026-05-18T00:00:00.000Z',
      },
    ],
  });
  gateway.documents['users/user-1'] = {
    'preferences': {'reminder_time': '07:30'},
  };
  return gateway;
}

Future<void> _seedLocalSyncedRows(AppDatabase db) async {
  await db.into(db.attemptsLocal).insert(
        AttemptsLocalCompanion.insert(
          id: 'local_a1',
          examId: 'cse',
          startedAt: DateTime.utc(2026, 5, 17),
          completedAt: const Value(null),
          itemsJson: '[]',
        ),
      );
  await db.into(db.assessmentResultsLocal).insert(
        AssessmentResultsLocalCompanion.insert(
          examId: 'upcat',
          completedAt: DateTime.utc(2026, 5, 17),
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
          due: DateTime.utc(2026, 5, 18),
          lastReview: DateTime.utc(2026, 5, 17),
          reps: 1,
          lapses: 0,
          elapsedDays: 1,
          scheduledDays: 1,
        ),
      );
  await db.into(db.lessonProgressLocal).insert(
        LessonProgressLocalCompanion.insert(
          lessonId: 'lesson_1',
          readAt: DateTime.utc(2026, 5, 17),
        ),
      );
}
