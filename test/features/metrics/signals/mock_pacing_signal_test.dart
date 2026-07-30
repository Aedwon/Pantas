import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/signals/mock_pacing_signal.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('computes average spare seconds and section timing', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await _mock(db, id: 'm1', totalSeconds: 5000, durationMinutes: 90);
    await _mock(db, id: 'm2', totalSeconds: 5200, durationMinutes: 90);

    final result = await MockPacingSignal(db).compute(
      window: _window(),
      examId: 'exam_cse',
    );

    expect(result, isNotNull);
    expect(result!.averageSpareSeconds, 300);
    expect(result.sectionTimeSeconds['general'], 5100);
  });
}

Future<void> _mock(
  AppDatabase db, {
  required String id,
  required int totalSeconds,
  required int durationMinutes,
}) {
  final submittedAt = DateTime.utc(2026, 6);
  return db.into(db.mockAttempts).insert(
        MockAttemptsCompanion.insert(
          id: id,
          userId: 'user_1',
          examId: 'exam_cse',
          blueprintId: 'bp',
          blueprintName: 'Mock',
          durationMinutes: durationMinutes,
          status: 'completed',
          strictMode: false,
          sampledQuestionsJson: '[]',
          sectionResultsJson: Value('''
{"sections":[{"sectionId":"general","name":"General","correct":1,"total":2,"retiredCount":0,"timeSeconds":$totalSeconds}]}
'''),
          totalTimeSeconds: Value(totalSeconds),
          submittedAt: Value(submittedAt),
          startedAt: submittedAt.subtract(Duration(seconds: totalSeconds)),
          lastFlushedAt: submittedAt,
          updatedAt: submittedAt,
        ),
      );
}

ResolvedMetricsWindow _window() => ResolvedMetricsWindow(
      window: MetricsWindow.prepWindow,
      start: DateTime.utc(2026, 5),
      end: DateTime.utc(2026, 6, 10),
      sessionCount: 14,
      minSessionCount: 14,
    );
