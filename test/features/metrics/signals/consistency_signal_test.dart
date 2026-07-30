import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/signals/consistency_signal.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('reads current streak and completed-session weekday counts', () async {
    final window = ResolvedMetricsWindow(
      window: MetricsWindow.allTime,
      start: null,
      end: DateTime.utc(2026, 6, 10),
      sessionCount: 1,
      minSessionCount: 1,
    );
    await db.into(db.streakLocal).insert(
          StreakLocalCompanion.insert(
            current: const Value(18),
            longest: const Value(31),
            lastActiveDate: Value(DateTime.utc(2026, 6, 10)),
          ),
        );
    await _quiz(db, id: 'q1', completedAt: DateTime.utc(2026, 6, 9));
    await _mock(db, id: 'm1', submittedAt: DateTime.utc(2026, 6, 10));

    final result = await ConsistencySignal(db).compute(
      window: window,
      examId: 'exam_cse',
    );

    expect(result, isNotNull);
    expect(result!.currentStreakDays, 18);
    expect(result.longestStreakDays, 31);
    expect(result.weekdayCounts[DateTime.tuesday], 1);
    expect(result.weekdayCounts[DateTime.wednesday], 1);
  });
}

Future<void> _quiz(
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

Future<void> _mock(
  AppDatabase db, {
  required String id,
  required DateTime submittedAt,
}) {
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
          submittedAt: Value(submittedAt),
          startedAt: submittedAt.subtract(const Duration(minutes: 90)),
          lastFlushedAt: submittedAt,
          updatedAt: submittedAt,
        ),
      );
}
