import 'package:cse_cet_reviewer/features/mock_exam/domain/part_clock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('urgency', () {
    test('ample above five minutes', () {
      expect(
        urgencyFor(const Duration(minutes: 5, seconds: 1)),
        ClockUrgency.ample,
      );
    });

    test('closing at five minutes and below', () {
      expect(urgencyFor(const Duration(minutes: 5)), ClockUrgency.closing);
      expect(
        urgencyFor(const Duration(minutes: 1, seconds: 1)),
        ClockUrgency.closing,
      );
    });

    test('last at one minute and below', () {
      expect(urgencyFor(const Duration(minutes: 1)), ClockUrgency.last);
      expect(urgencyFor(Duration.zero), ClockUrgency.last);
    });
  });

  group('the four calls', () {
    test('fires once as the clock crosses a threshold', () {
      expect(
        callThresholdCrossed(
          before: const Duration(minutes: 20, seconds: 1),
          after: const Duration(minutes: 20),
        ),
        20,
      );
    });

    test('does not fire again while sitting on the same side', () {
      expect(
        callThresholdCrossed(
          before: const Duration(minutes: 19),
          after: const Duration(minutes: 18, seconds: 59),
        ),
        isNull,
      );
    });

    test('all four thresholds fire', () {
      for (final minutes in [20, 10, 5, 1]) {
        expect(
          callThresholdCrossed(
            before: Duration(minutes: minutes, seconds: 1),
            after: Duration(minutes: minutes),
          ),
          minutes,
        );
      }
    });

    test('a jump past two thresholds reports the lower one only', () {
      // A device that slept through both. The student is at 4 minutes and
      // telling them 10 minutes remain would be false.
      expect(
        callThresholdCrossed(
          before: const Duration(minutes: 11),
          after: const Duration(minutes: 4),
        ),
        5,
      );
    });

    test('never fires at zero', () {
      expect(
        callThresholdCrossed(
          before: const Duration(seconds: 1),
          after: Duration.zero,
        ),
        isNull,
      );
    });
  });

  test('remaining never goes below zero', () {
    expect(
      remainingInPart(
        partLength: const Duration(minutes: 30),
        elapsedInPart: const Duration(minutes: 31),
      ),
      Duration.zero,
    );
  });
}
