// test/core/fsrs/fsrs_scheduler_review_test.dart
import 'package:pantas/core/fsrs/fsrs_scheduler.dart';
import 'package:pantas/core/fsrs/rating.dart';
import 'package:pantas/core/storage/domain/review_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // A card reviewed once before, due exactly when expected.
  final lastReview = DateTime.utc(2026, 5);
  final now = DateTime.utc(2026, 5, 4); // 3 days elapsed
  final prev = ReviewState(
    questionId: 'q',
    questionVersion: 1,
    stage: ReviewStage.review,
    stability: 3,
    difficulty: 5,
    due: now,
    lastReview: lastReview,
    reps: 1,
    lapses: 0,
    elapsedDays: 0,
    scheduledDays: 3,
  );
  const scheduler = FsrsScheduler();

  test('Good → stability strictly grows', () {
    final next = scheduler.next(prev: prev, rating: Rating.good, now: now);
    expect(next.stage, equals(ReviewStage.review));
    expect(next.stability, greaterThan(prev.stability));
    expect(next.lapses, equals(0));
    expect(next.reps, equals(2));
    expect(next.elapsedDays, closeTo(3, 1e-4));
  });

  test('Easy stability grows MORE than Good (easy bonus w16)', () {
    final good = scheduler.next(prev: prev, rating: Rating.good, now: now);
    final easy = scheduler.next(prev: prev, rating: Rating.easy, now: now);
    expect(easy.stability, greaterThan(good.stability));
  });

  test('Hard stability grows LESS than Good (hard penalty w15)', () {
    final hard = scheduler.next(prev: prev, rating: Rating.hard, now: now);
    final good = scheduler.next(prev: prev, rating: Rating.good, now: now);
    expect(hard.stability, lessThan(good.stability));
    expect(hard.stability, greaterThan(prev.stability));
  });

  test('Good drifts difficulty toward anchor; Hard pushes it up', () {
    final hard = scheduler.next(prev: prev, rating: Rating.hard, now: now);
    final good = scheduler.next(prev: prev, rating: Rating.good, now: now);
    expect(hard.difficulty, greaterThan(good.difficulty));
    expect(hard.difficulty, lessThanOrEqualTo(10.0));
  });

  test('next due is roughly stability days after now', () {
    final next = scheduler.next(prev: prev, rating: Rating.good, now: now);
    final intervalDays = next.due.difference(now).inSeconds / 86400.0;
    expect(intervalDays, closeTo(next.scheduledDays, 1e-3));
  });
}
