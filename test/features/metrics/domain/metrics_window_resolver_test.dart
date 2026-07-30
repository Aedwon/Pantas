import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/signals/metrics_window_resolver.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late MetricsWindowResolver resolver;
  final now = DateTime.utc(2026, 6, 10, 12);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    resolver = MetricsWindowResolver(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('rolling30d starts 30 days before now and requires 7 sessions',
      () async {
    for (var i = 0; i < 6; i += 1) {
      await _insertQuizSession(db, id: 'session_$i', completedAt: now);
    }

    final below = await resolver.resolve(
      examId: 'exam_cse',
      window: MetricsWindow.rolling30d,
      now: now,
    );

    expect(below.start, DateTime.utc(2026, 5, 11, 12));
    expect(below.end, now);
    expect(below.sessionCount, 6);
    expect(below.hasEnoughData, isFalse);

    await _insertQuizSession(db, id: 'session_6', completedAt: now);

    final enough = await resolver.resolve(
      examId: 'exam_cse',
      window: MetricsWindow.rolling30d,
      now: now,
    );

    expect(enough.sessionCount, 7);
    expect(enough.hasEnoughData, isTrue);
  });

  test('prepWindow uses original prep start and requires 14 sessions',
      () async {
    final prepStartedAt = DateTime.utc(2026, 4);
    for (var i = 0; i < 14; i += 1) {
      await _insertQuizSession(
        db,
        id: 'session_$i',
        completedAt: prepStartedAt.add(Duration(days: i)),
      );
    }
    await _insertQuizSession(
      db,
      id: 'old_session',
      completedAt: DateTime.utc(2026, 3, 31, 23),
    );

    final resolved = await resolver.resolve(
      examId: 'exam_cse',
      window: MetricsWindow.prepWindow,
      now: now,
      prepStartedAt: prepStartedAt,
    );

    expect(resolved.start, prepStartedAt);
    expect(resolved.end, now);
    expect(resolved.sessionCount, 14);
    expect(resolved.hasEnoughData, isTrue);
  });

  test('allTime has no start and requires one session', () async {
    final empty = await resolver.resolve(
      examId: 'exam_cse',
      window: MetricsWindow.allTime,
      now: now,
    );

    expect(empty.start, isNull);
    expect(empty.end, now);
    expect(empty.sessionCount, 0);
    expect(empty.hasEnoughData, isFalse);

    await _insertQuizSession(db, id: 'session_1', completedAt: now);

    final resolved = await resolver.resolve(
      examId: 'exam_cse',
      window: MetricsWindow.allTime,
      now: now,
    );

    expect(resolved.sessionCount, 1);
    expect(resolved.hasEnoughData, isTrue);
  });

  test('counts completed mocks as sessions for threshold checks', () async {
    for (var i = 0; i < 6; i += 1) {
      await _insertQuizSession(db, id: 'session_$i', completedAt: now);
    }
    await _insertMockAttempt(db, id: 'mock_1', submittedAt: now);

    final resolved = await resolver.resolve(
      examId: 'exam_cse',
      window: MetricsWindow.rolling30d,
      now: now,
    );

    expect(resolved.sessionCount, 7);
    expect(resolved.hasEnoughData, isTrue);
  });
}

Future<void> _insertQuizSession(
  AppDatabase db, {
  required String id,
  required DateTime completedAt,
}) {
  return db.into(db.quizSessions).insert(
        QuizSessionsCompanion.insert(
          id: id,
          userId: 'user_1',
          examId: 'exam_cse',
          origin: 'today_topic',
          questionIdsJson: '[]',
          startedAt: completedAt.subtract(const Duration(minutes: 10)),
          completedAt: Value(completedAt),
        ),
      );
}

Future<void> _insertMockAttempt(
  AppDatabase db, {
  required String id,
  required DateTime submittedAt,
}) {
  return db.into(db.mockAttempts).insert(
        MockAttemptsCompanion.insert(
          id: id,
          userId: 'user_1',
          examId: 'exam_cse',
          blueprintId: 'bp_1',
          blueprintName: 'Practice Mock',
          durationMinutes: 90,
          status: 'completed',
          strictMode: false,
          sampledQuestionsJson: '[]',
          submittedAt: Value(submittedAt),
          startedAt: submittedAt.subtract(const Duration(minutes: 90)),
          lastFlushedAt: submittedAt,
          updatedAt: submittedAt,
        ),
      );
}
