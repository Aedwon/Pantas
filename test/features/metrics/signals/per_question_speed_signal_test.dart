import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/metrics_window.dart';
import 'package:cse_cet_reviewer/features/metrics/signals/per_question_speed_signal.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('computes average response speed by correctness', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.into(db.attemptsLocal).insert(
          AttemptsLocalCompanion.insert(
            id: 'a1',
            examId: 'exam_cse',
            startedAt: DateTime.utc(2026, 6),
            completedAt: Value(DateTime.utc(2026, 6, 1, 1)),
            itemsJson: '''
[
  {"questionId":"q1","questionVersion":1,"chosenChoiceId":"a","correctChoiceId":"a","responseMs":8000},
  {"questionId":"q2","questionVersion":1,"chosenChoiceId":"b","correctChoiceId":"c","responseMs":14000}
]
''',
          ),
        );

    final result = await PerQuestionSpeedSignal(db).compute(
      window: _window(),
      examId: 'exam_cse',
    );

    expect(result, isNotNull);
    expect(result!.averageMs, 11000);
    expect(result.correctAverageMs, 8000);
    expect(result.incorrectAverageMs, 14000);
  });
}

ResolvedMetricsWindow _window() => ResolvedMetricsWindow(
      window: MetricsWindow.rolling30d,
      start: DateTime.utc(2026, 5, 11),
      end: DateTime.utc(2026, 6, 10),
      sessionCount: 7,
      minSessionCount: 7,
    );
