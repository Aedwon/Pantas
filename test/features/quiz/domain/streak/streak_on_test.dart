import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/repos/streak_repository.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/features/quiz/domain/streak/streak_evaluator.dart';

// P10/U61: the streak a student sees is read against today, by the rule the
// evaluator applies when the next session completes. Same dates as the
// evaluator's own scenarios: study days Monday to Friday, 2 Oct 2026 is a
// Friday.
void main() {
  final weekdays = StudyDays(const [1, 2, 3, 4, 5]);
  StreakSnapshot stored({int freezes = 1, DateTime? last}) => StreakSnapshot(
        current: 5,
        longest: 7,
        lastActiveDate: last ?? DateTime(2026, 10, 2),
        freezesRemaining: freezes,
      );

  for (final scenario in [
    (name: 'the same day', today: 2, shown: 5, freezes: 1),
    (name: 'Friday to Saturday, a rest day', today: 3, shown: 5, freezes: 1),
    (name: 'Friday to Monday keeps it', today: 5, shown: 5, freezes: 1),
    (name: 'Friday to Tuesday uses the freeze', today: 6, shown: 5, freezes: 1),
    (
      name: 'Friday to Tuesday with no freeze left',
      today: 6,
      shown: 0,
      freezes: 0
    ),
    (name: 'two missed study days', today: 7, shown: 0, freezes: 1),
    (name: 'three weeks away', today: 23, shown: 0, freezes: 1),
  ]) {
    test(scenario.name, () {
      expect(
        streakOn(
          stored(freezes: scenario.freezes),
          DateTime(2026, 10, scenario.today, 9),
          weekdays,
        ),
        scenario.shown,
      );
    });
  }

  test('a streak that was never credited stays zero', () {
    expect(
      streakOn(
        const StreakSnapshot(
          current: 0,
          longest: 0,
          lastActiveDate: null,
          freezesRemaining: 1,
        ),
        DateTime(2026, 10, 2),
        weekdays,
      ),
      0,
    );
  });

  test('reading never writes: the stored snapshot is untouched', () {
    final snapshot = stored();
    streakOn(snapshot, DateTime(2026, 10, 23), weekdays);
    expect(snapshot.current, 5);
  });
}
