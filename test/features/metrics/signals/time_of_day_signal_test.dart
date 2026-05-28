import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/metrics_window.dart';
import 'package:cse_cet_reviewer/features/metrics/signals/time_of_day_signal.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  final window = ResolvedMetricsWindow(
    window: MetricsWindow.rolling30d,
    start: DateTime.utc(2026, 5, 11),
    end: DateTime.utc(2026, 6, 10),
    sessionCount: 7,
    minSessionCount: 7,
  );

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('returns null below the window threshold', () async {
    final signal = TimeOfDaySignal(db);
    final below = ResolvedMetricsWindow(
      window: MetricsWindow.rolling30d,
      start: DateTime.utc(2026, 5, 11),
      end: DateTime.utc(2026, 6, 10),
      sessionCount: 6,
      minSessionCount: 7,
    );

    expect(await signal.compute(window: below, examId: 'exam_cse'), isNull);
  });

  test('aggregates completed quiz and mock accuracy by hour', () async {
    await _quiz(db, id: 'q1', hour: 21, correct: 8, total: 10);
    await _quiz(db, id: 'q2', hour: 21, correct: 6, total: 10);
    await _mock(db, id: 'm1', hour: 8, correct: 5, total: 10);

    final result = await TimeOfDaySignal(db).compute(
      window: window,
      examId: 'exam_cse',
    );

    expect(result, isNotNull);
    final buckets = {for (final b in result!.buckets) b.hour: b};
    expect(buckets[21]?.correct, 14);
    expect(buckets[21]?.total, 20);
    expect(buckets[8]?.accuracy, 0.5);
  });
}

Future<void> _quiz(
  AppDatabase db, {
  required String id,
  required int hour,
  required int correct,
  required int total,
}) {
  final startedAt = DateTime.utc(2026, 6, 1, hour);
  return db.into(db.quizSessions).insert(
        QuizSessionsCompanion.insert(
          id: id,
          userId: 'user_1',
          examId: 'exam_cse',
          origin: 'today_topic',
          questionIdsJson: '[]',
          currentIndex: Value(total),
          correctCount: Value(correct),
          startedAt: startedAt,
          completedAt: Value(startedAt.add(const Duration(minutes: 10))),
        ),
      );
}

Future<void> _mock(
  AppDatabase db, {
  required String id,
  required int hour,
  required int correct,
  required int total,
}) {
  final submittedAt = DateTime.utc(2026, 6, 1, hour);
  return db.into(db.mockAttempts).insert(
        MockAttemptsCompanion.insert(
          id: id,
          userId: 'user_1',
          examId: 'exam_cse',
          blueprintId: 'bp',
          blueprintName: 'Mock',
          durationMinutes: 90,
          status: 'completed',
          strictMode: false,
          sampledQuestionsJson: '[]',
          scoreRaw: Value(correct),
          scoreTotal: Value(total),
          submittedAt: Value(submittedAt),
          startedAt: submittedAt.subtract(const Duration(minutes: 90)),
          lastFlushedAt: submittedAt,
          updatedAt: submittedAt,
        ),
      );
}
