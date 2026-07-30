import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/signals/flag_revisit_signal.dart';

void main() {
  test('counts flagged questions that were answered', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final submittedAt = DateTime.utc(2026, 6);
    await db.into(db.mockAttempts).insert(
          MockAttemptsCompanion.insert(
            id: 'm1',
            userId: 'user_1',
            examId: 'exam_cse',
            blueprintId: 'bp',
            blueprintName: 'Mock',
            durationMinutes: 90,
            status: 'completed',
            strictMode: false,
            sampledQuestionsJson: '[]',
            flagsJson: const Value('["q1","q2"]'),
            answersJson: const Value('{"q1":{"selectedIndex":0,"atSec":1}}'),
            submittedAt: Value(submittedAt),
            startedAt: submittedAt.subtract(const Duration(minutes: 90)),
            lastFlushedAt: submittedAt,
            updatedAt: submittedAt,
          ),
        );

    final result = await FlagRevisitSignal(db).compute(
      window: _window(),
      examId: 'exam_cse',
    );

    expect(result, isNotNull);
    expect(result!.flaggedCount, 2);
    expect(result.revisitedCount, 1);
    expect(result.ratio, 0.5);
  });
}

ResolvedMetricsWindow _window() => ResolvedMetricsWindow(
      window: MetricsWindow.prepWindow,
      start: DateTime.utc(2026, 5),
      end: DateTime.utc(2026, 6, 10),
      sessionCount: 14,
      minSessionCount: 14,
    );
