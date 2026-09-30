import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/fsrs/fsrs_scheduler.dart';
import 'package:pantas/core/fsrs/rating.dart';
import 'package:pantas/core/storage/domain/review_state.dart';

void main() {
  const scheduler = FsrsScheduler();
  final lastReview = DateTime.utc(2026, 9, 30, 12);
  final seed = ReviewState.seed(
    questionId: 'q',
    questionVersion: 1,
    now: lastReview,
  );
  final state = scheduler.next(
    prev: seed,
    rating: Rating.good,
    now: lastReview,
  );

  test('retrievability is one at the last review', () {
    expect(scheduler.retrievability(state, lastReview), 1.0);
  });

  test('retrievability floors elapsed time at zero', () {
    expect(
      scheduler.retrievability(
        state,
        lastReview.subtract(const Duration(days: 1)),
      ),
      1.0,
    );
  });

  test('retrievability decreases as elapsed time grows', () {
    final shortlyAfter = scheduler.retrievability(
      state,
      lastReview.add(const Duration(hours: 6)),
    );
    final later = scheduler.retrievability(
      state,
      lastReview.add(const Duration(days: 3)),
    );

    expect(shortlyAfter, lessThan(1));
    expect(later, lessThan(shortlyAfter));
    expect(later, greaterThan(0));
  });

  for (final (rating, elapsed) in [
    (Rating.hard, const Duration(hours: 6)),
    (Rating.good, const Duration(hours: 36)),
    (Rating.easy, const Duration(hours: 243)),
  ]) {
    test('retrievability matches the formula for ${rating.name}', () {
      final sample = scheduler.next(
        prev: seed,
        rating: rating,
        now: lastReview,
      );
      final elapsedDays = elapsed.inMicroseconds / Duration.microsecondsPerDay;
      final decay = -scheduler.weights[20];
      final factor = math.pow(0.9, 1.0 / decay).toDouble() - 1.0;
      final expected = math
          .pow(1.0 + factor * elapsedDays / sample.stability, decay)
          .toDouble();

      expect(
        scheduler.retrievability(sample, lastReview.add(elapsed)),
        closeTo(expected, 1e-12),
      );
    });
  }
}
