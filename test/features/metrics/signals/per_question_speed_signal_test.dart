import 'dart:math' as math;

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/signals/per_question_speed_signal.dart';

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
    expect(result.correctCount, 1);
    expect(result.incorrectCount, 1);
    expect(result.correctLogMean, closeTo(math.log(8000), 1e-12));
    expect(result.incorrectLogMean, closeTo(math.log(14000), 1e-12));
    expect(result.correctLogVariance, 0);
    expect(result.incorrectLogVariance, 0);
  });

  test('log moments use sample variance and exclude nonpositive durations',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.into(db.attemptsLocal).insert(
          AttemptsLocalCompanion.insert(
            id: 'logs',
            examId: 'exam_cse',
            startedAt: DateTime.utc(2026, 6),
            completedAt: Value(DateTime.utc(2026, 6, 1, 1)),
            itemsJson: '''
[
 {"questionId":"a","questionVersion":1,"chosenChoiceId":"a","correctChoiceId":"a","responseMs":1000},
 {"questionId":"b","questionVersion":1,"chosenChoiceId":"a","correctChoiceId":"a","responseMs":4000},
 {"questionId":"c","questionVersion":1,"chosenChoiceId":"b","correctChoiceId":"a","responseMs":2000},
 {"questionId":"d","questionVersion":1,"chosenChoiceId":"b","correctChoiceId":"a","responseMs":8000},
 {"questionId":"e","questionVersion":1,"chosenChoiceId":"a","correctChoiceId":"a","responseMs":0},
 {"questionId":"f","questionVersion":1,"chosenChoiceId":"b","correctChoiceId":"a","responseMs":-1}
]
''',
          ),
        );
    final speed = (await PerQuestionSpeedSignal(db).compute(
      window: _window(),
      examId: 'exam_cse',
    ))!;
    // log(1000),log(4000): mean=log(2000), s^2=log(4)^2/2.
    expect(speed.sampleCount, 4);
    expect(speed.correctCount, 2);
    expect(speed.incorrectCount, 2);
    expect(speed.averageMs, 3750);
    expect(speed.correctLogMean, closeTo(math.log(2000), 1e-12));
    expect(speed.incorrectLogMean, closeTo(math.log(4000), 1e-12));
    expect(
      speed.correctLogVariance,
      closeTo(math.pow(math.log(4), 2) / 2, 1e-12),
    );
    expect(
      speed.incorrectLogVariance,
      closeTo(math.pow(math.log(4), 2) / 2, 1e-12),
    );
  });

  test('an assessment row contributes no latency', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.into(db.attemptsLocal).insert(
          AttemptsLocalCompanion.insert(
            id: 'a1',
            examId: 'exam_cse',
            startedAt: DateTime.utc(2026, 6),
            completedAt: Value(DateTime.utc(2026, 6, 1, 1)),
            origin: const Value('assessment'),
            itemsJson: '''
[
  {"questionId":"q1","questionVersion":1,"chosenChoiceId":"a","correctChoiceId":"a","responseMs":0},
  {"questionId":"q2","questionVersion":1,"chosenChoiceId":"b","correctChoiceId":"c","responseMs":0}
]
''',
          ),
        );
    await db.into(db.attemptsLocal).insert(
          AttemptsLocalCompanion.insert(
            id: 'a2',
            examId: 'exam_cse',
            startedAt: DateTime.utc(2026, 6),
            completedAt: Value(DateTime.utc(2026, 6, 1, 1)),
            origin: const Value('today_topic'),
            itemsJson: '''
[
  {"questionId":"q3","questionVersion":1,"chosenChoiceId":"a","correctChoiceId":"a","responseMs":8000}
]
''',
          ),
        );

    final result = await PerQuestionSpeedSignal(db).compute(
      window: _window(),
      examId: 'exam_cse',
    );

    expect(
      result!.averageMs,
      8000,
      reason: 'the untimed row must not drag the average toward zero',
    );
  });

  test('with only untimed rows there is no distribution at all', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.into(db.attemptsLocal).insert(
          AttemptsLocalCompanion.insert(
            id: 'a1',
            examId: 'exam_cse',
            startedAt: DateTime.utc(2026, 6),
            completedAt: Value(DateTime.utc(2026, 6, 1, 1)),
            origin: const Value('assessment'),
            itemsJson: '''
[
  {"questionId":"q1","questionVersion":1,"chosenChoiceId":"a","correctChoiceId":"a","responseMs":0}
]
''',
          ),
        );

    expect(
      await PerQuestionSpeedSignal(db).compute(
        window: _window(),
        examId: 'exam_cse',
      ),
      isNull,
    );
  });
}

ResolvedMetricsWindow _window() => ResolvedMetricsWindow(
      window: MetricsWindow.rolling30d,
      start: DateTime.utc(2026, 5, 11),
      end: DateTime.utc(2026, 6, 10),
      sessionCount: 7,
      minSessionCount: 7,
    );
