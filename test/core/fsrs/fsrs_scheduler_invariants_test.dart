// test/core/fsrs/fsrs_scheduler_invariants_test.dart
import 'package:pantas/core/fsrs/fsrs_scheduler.dart';
import 'package:pantas/core/fsrs/rating.dart';
import 'package:pantas/core/storage/domain/review_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const scheduler = FsrsScheduler();

  ReviewState make({double s = 5, double d = 5, int reps = 1, int lapses = 0}) {
    final t = DateTime.utc(2026);
    return ReviewState(
      questionId: 'q',
      questionVersion: 1,
      stage: ReviewStage.review,
      stability: s,
      difficulty: d,
      due: t,
      lastReview: t,
      reps: reps,
      lapses: lapses,
      elapsedDays: 0,
      scheduledDays: s,
    );
  }

  test('difficulty never escapes [1, 10]', () {
    final hi = make(d: 10);
    final lo = make(d: 1);
    for (final r in Rating.values) {
      final h = scheduler.next(
        prev: hi,
        rating: r,
        now: DateTime.utc(2026, 1, 5),
      );
      final l = scheduler.next(
        prev: lo,
        rating: r,
        now: DateTime.utc(2026, 1, 5),
      );
      expect(h.difficulty, inInclusiveRange(1.0, 10.0));
      expect(l.difficulty, inInclusiveRange(1.0, 10.0));
    }
  });

  test('stability never falls below 0.1 even after extreme lapse', () {
    final tiny = make(s: 0.2, d: 9.5);
    final later = DateTime.utc(2027); // ~1 year elapsed
    final next = scheduler.next(prev: tiny, rating: Rating.again, now: later);
    expect(next.stability, greaterThanOrEqualTo(0.1));
  });

  test('stability never exceeds 36500 days (100y)', () {
    final huge = make(s: 30000, d: 1);
    final later = DateTime.utc(2026, 1, 2);
    final next = scheduler.next(prev: huge, rating: Rating.easy, now: later);
    expect(next.stability, lessThanOrEqualTo(36500.0));
  });

  test('reps strictly increases on every call', () {
    var s = make();
    for (var i = 0; i < 5; i++) {
      final next = scheduler.next(
        prev: s,
        rating: Rating.good,
        now: s.lastReview.add(Duration(days: s.scheduledDays.round())),
      );
      expect(next.reps, equals(s.reps + 1));
      s = next;
    }
  });
}
