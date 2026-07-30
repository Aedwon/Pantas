import 'package:pantas/core/fsrs/fsrs_scheduler.dart';
import 'package:pantas/core/fsrs/rating.dart';
import 'package:pantas/core/storage/domain/review_state.dart';
import 'package:flutter_test/flutter_test.dart';

// Golden vectors derived from FSRS-6 formulas using kFsrsDefaultWeights.
void main() {
  const scheduler = FsrsScheduler();

  test('golden G1 newCard + Good', () {
    final t0 = DateTime.utc(2026, 5);
    final seed = ReviewState.seed(questionId: 'q', questionVersion: 1, now: t0);
    final next = scheduler.next(prev: seed, rating: Rating.good, now: t0);

    expect(next.stage, equals(ReviewStage.review));
    expect(next.stability, closeTo(2.3065, 1e-3));
    expect(next.difficulty, closeTo(2.1181, 1e-3));
    expect(next.reps, equals(1));
    expect(next.lapses, equals(0));
  });

  test('golden G2 newCard + Easy', () {
    final t0 = DateTime.utc(2026, 5);
    final seed = ReviewState.seed(questionId: 'q', questionVersion: 1, now: t0);
    final next = scheduler.next(prev: seed, rating: Rating.easy, now: t0);

    expect(next.stage, equals(ReviewStage.review));
    expect(next.stability, closeTo(8.2956, 1e-3));
    expect(next.difficulty, closeTo(1.0, 1e-3));
  });

  test('golden G3 review S=5 D=5 elapsed=5 Good', () {
    final t0 = DateTime.utc(2026, 5);
    final t1 = DateTime.utc(2026, 5, 6);
    final prev = ReviewState(
      questionId: 'q',
      questionVersion: 1,
      stage: ReviewStage.review,
      stability: 5,
      difficulty: 5,
      due: t1,
      lastReview: t0,
      reps: 2,
      lapses: 0,
      elapsedDays: 5,
      scheduledDays: 5,
    );
    final next = scheduler.next(prev: prev, rating: Rating.good, now: t1);

    expect(next.stability, closeTo(17.358, 1e-2));
    expect(next.difficulty, closeTo(4.996, 1e-2));
    expect(next.reps, equals(3));
  });

  test('golden G4 review S=12 D=3 elapsed=14 Hard', () {
    final t0 = DateTime.utc(2026, 5);
    final t1 = DateTime.utc(2026, 5, 15);
    final prev = ReviewState(
      questionId: 'q',
      questionVersion: 1,
      stage: ReviewStage.review,
      stability: 12,
      difficulty: 3,
      due: DateTime.utc(2026, 5, 13),
      lastReview: t0,
      reps: 4,
      lapses: 0,
      elapsedDays: 14,
      scheduledDays: 12,
    );
    final next = scheduler.next(prev: prev, rating: Rating.hard, now: t1);

    expect(next.stability, closeTo(34.914, 1e-2));
    expect(next.difficulty, closeTo(5.344, 1e-2));
    expect(next.reps, equals(5));
  });

  test('golden G5 review S=8 D=6.5 elapsed=10 Easy', () {
    final t0 = DateTime.utc(2026, 5);
    final t1 = DateTime.utc(2026, 5, 11);
    final prev = ReviewState(
      questionId: 'q',
      questionVersion: 1,
      stage: ReviewStage.review,
      stability: 8,
      difficulty: 6.5,
      due: DateTime.utc(2026, 5, 9),
      lastReview: t0,
      reps: 3,
      lapses: 0,
      elapsedDays: 10,
      scheduledDays: 8,
    );
    final next = scheduler.next(prev: prev, rating: Rating.easy, now: t1);

    expect(next.stability, closeTo(38.006, 1e-2));
    expect(next.difficulty, closeTo(5.322, 1e-2));
  });

  test('golden G6 review S=7 D=4 elapsed=8 Again', () {
    final t0 = DateTime.utc(2026, 5);
    final t1 = DateTime.utc(2026, 5, 9);
    final prev = ReviewState(
      questionId: 'q',
      questionVersion: 1,
      stage: ReviewStage.review,
      stability: 7,
      difficulty: 4,
      due: DateTime.utc(2026, 5, 8),
      lastReview: t0,
      reps: 3,
      lapses: 0,
      elapsedDays: 8,
      scheduledDays: 7,
    );
    final next = scheduler.next(prev: prev, rating: Rating.again, now: t1);

    expect(next.stage, equals(ReviewStage.relearning));
    expect(next.stability, closeTo(1.190, 1e-2));
    expect(next.difficulty, closeTo(8.019, 1e-2));
    expect(next.lapses, equals(1));
  });

  test('golden G7 same-day review S=5 D=5 elapsed=0.1 Good', () {
    final t0 = DateTime.utc(2026, 5, 1, 10);
    final t1 = DateTime.utc(2026, 5, 1, 12, 24); // 2.4 hours = 0.1 days
    final prev = ReviewState(
      questionId: 'q',
      questionVersion: 1,
      stage: ReviewStage.review,
      stability: 5,
      difficulty: 5,
      due: DateTime.utc(2026, 5, 6),
      lastReview: t0,
      reps: 2,
      lapses: 0,
      elapsedDays: 0.1,
      scheduledDays: 5,
    );
    final next = scheduler.next(prev: prev, rating: Rating.good, now: t1);

    expect(next.stage, equals(ReviewStage.review));
    expect(next.stability, closeTo(4.7255, 1e-2));
    expect(next.reps, equals(3));
  });
}
