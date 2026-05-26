import 'package:cse_cet_reviewer/features/study_plan/domain/pace_curve.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final curve = PaceCurve(
    planStart: DateTime(2026, 5),
    examDate: DateTime(2026, 5, 31),
    startMastery: 0.25,
  );

  test('expected mastery equals start mastery on plan start date', () {
    expect(curve.expectedMastery(on: DateTime(2026, 5)), 0.25);
  });

  test('expected mastery equals target mastery on exam date', () {
    expect(curve.expectedMastery(on: DateTime(2026, 5, 31)), 0.75);
  });

  test('expected mastery clamps when today is before start or after exam', () {
    expect(curve.expectedMastery(on: DateTime(2026, 4, 15)), 0.25);
    expect(curve.expectedMastery(on: DateTime(2026, 6, 15)), 0.75);
  });

  test('actual mastery within five percentage points is on pace', () {
    expect(
      curve.status(actualMastery: 0.48, on: DateTime(2026, 5, 15)),
      PaceStatus.onPace,
    );
  });

  test('actual mastery below tolerance is behind', () {
    expect(
      curve.status(actualMastery: 0.40, on: DateTime(2026, 5, 15)),
      PaceStatus.behind,
    );
  });

  test('actual mastery above tolerance is ahead', () {
    expect(
      curve.status(actualMastery: 0.60, on: DateTime(2026, 5, 15)),
      PaceStatus.ahead,
    );
  });

  test('mastery already above target remains ahead without negative workload',
      () {
    final completed = PaceCurve(
      planStart: DateTime(2026, 5),
      examDate: DateTime(2026, 6),
      startMastery: 0.80,
    );

    expect(completed.expectedMastery(on: DateTime(2026, 5, 15)), 0.75);
    expect(
      completed.status(actualMastery: 0.80, on: DateTime(2026, 5, 15)),
      PaceStatus.ahead,
    );
  });
}
