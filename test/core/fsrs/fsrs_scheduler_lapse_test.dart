// test/core/fsrs/fsrs_scheduler_lapse_test.dart
import 'package:pantas/core/fsrs/fsrs_scheduler.dart';
import 'package:pantas/core/fsrs/rating.dart';
import 'package:pantas/core/storage/domain/review_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final lastReview = DateTime.utc(2026, 5);
  final now = DateTime.utc(2026, 5, 11); // 10 days elapsed
  final prev = ReviewState(
    questionId: 'q',
    questionVersion: 1,
    stage: ReviewStage.review,
    stability: 7.5,
    difficulty: 4,
    due: now,
    lastReview: lastReview,
    reps: 3,
    lapses: 0,
    elapsedDays: 0,
    scheduledDays: 7.5,
  );
  const scheduler = FsrsScheduler();

  test('Again on a review card → stage=relearning, lapses+1, stability shrinks',
      () {
    final next = scheduler.next(prev: prev, rating: Rating.again, now: now);
    expect(next.stage, equals(ReviewStage.relearning));
    expect(next.lapses, equals(1));
    expect(next.stability, lessThan(prev.stability));
    expect(next.stability, greaterThanOrEqualTo(0.1));
    expect(next.reps, equals(4));
  });

  test('Again pushes difficulty up (toward 10)', () {
    final next = scheduler.next(prev: prev, rating: Rating.again, now: now);
    expect(next.difficulty, greaterThan(prev.difficulty));
    expect(next.difficulty, lessThanOrEqualTo(10.0));
  });

  test('Subsequent Good after lapse → stage returns to review, stability grows',
      () {
    final lapsed = scheduler.next(prev: prev, rating: Rating.again, now: now);
    final later = now.add(const Duration(minutes: 10));
    final recovered =
        scheduler.next(prev: lapsed, rating: Rating.good, now: later);
    expect(recovered.stage, equals(ReviewStage.review));
    expect(recovered.stability, greaterThan(lapsed.stability));
  });
}
