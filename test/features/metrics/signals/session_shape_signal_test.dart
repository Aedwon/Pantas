import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/metrics_window.dart';
import 'package:cse_cet_reviewer/features/metrics/signals/session_shape_signal.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('averages completed quiz and mock durations in minutes', () async {
    final window = ResolvedMetricsWindow(
      window: MetricsWindow.rolling30d,
      start: DateTime.utc(2026, 5, 11),
      end: DateTime.utc(2026, 6, 10),
      sessionCount: 7,
      minSessionCount: 7,
    );
    await _quiz(db, id: 'q1', minutes: 8);
    await _quiz(db, id: 'q2', minutes: 12);
    await _mock(db, id: 'm1', minutes: 70);

    final result = await SessionShapeSignal(db).compute(
      window: window,
      examId: 'exam_cse',
    );

    expect(result, isNotNull);
    expect(result!.sessionCount, 3);
    expect(result.averageMinutes, closeTo(30, 0.01));
  });
}

Future<void> _quiz(
  AppDatabase db, {
  required String id,
  required int minutes,
}) {
  final startedAt = DateTime.utc(2026, 6, 1, 10);
  return db.into(db.quizSessions).insert(
        QuizSessionsCompanion.insert(
          id: id,
          userId: 'user_1',
          examId: 'exam_cse',
          origin: 'today_topic',
          questionIdsJson: '[]',
          startedAt: startedAt,
          completedAt: Value(startedAt.add(Duration(minutes: minutes))),
        ),
      );
}

Future<void> _mock(
  AppDatabase db, {
  required String id,
  required int minutes,
}) {
  final submittedAt = DateTime.utc(2026, 6, 1, 12);
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
          totalTimeSeconds: Value(minutes * 60),
          submittedAt: Value(submittedAt),
          startedAt: submittedAt.subtract(Duration(minutes: minutes)),
          lastFlushedAt: submittedAt,
          updatedAt: submittedAt,
        ),
      );
}
