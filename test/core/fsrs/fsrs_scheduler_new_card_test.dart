import 'package:cse_cet_reviewer/core/fsrs/fsrs_scheduler.dart';
import 'package:cse_cet_reviewer/core/fsrs/rating.dart';
import 'package:cse_cet_reviewer/core/storage/domain/review_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 5, 9, 12);
  final seed = ReviewState.seed(questionId: 'q', questionVersion: 1, now: now);
  const scheduler = FsrsScheduler();

  test('Again on a new card -> stage=learning, stability=w0', () {
    final next = scheduler.next(prev: seed, rating: Rating.again, now: now);
    expect(next.stage, equals(ReviewStage.learning));
    expect(next.stability, closeTo(0.4072, 1e-4));
    expect(next.reps, equals(1));
    expect(next.lapses, equals(0));
    expect(next.due.isAfter(now), isTrue);
  });

  test('Good on a new card -> stage=review, stability=w2', () {
    final next = scheduler.next(prev: seed, rating: Rating.good, now: now);
    expect(next.stage, equals(ReviewStage.review));
    expect(next.stability, closeTo(3.1262, 1e-4));
    expect(next.difficulty, inInclusiveRange(1.0, 10.0));
    expect(next.reps, equals(1));
  });

  test('Easy on a new card -> stage=review, stability=w3', () {
    final next = scheduler.next(prev: seed, rating: Rating.easy, now: now);
    expect(next.stage, equals(ReviewStage.review));
    expect(next.stability, closeTo(15.4722, 1e-4));
  });

  test('Hard on a new card -> stage=learning, stability=w1', () {
    final next = scheduler.next(prev: seed, rating: Rating.hard, now: now);
    expect(next.stage, equals(ReviewStage.learning));
    expect(next.stability, closeTo(1.1829, 1e-4));
  });

  test('initial difficulty: Again > Good > Easy', () {
    final dAgain =
        scheduler.next(prev: seed, rating: Rating.again, now: now).difficulty;
    final dGood =
        scheduler.next(prev: seed, rating: Rating.good, now: now).difficulty;
    final dEasy =
        scheduler.next(prev: seed, rating: Rating.easy, now: now).difficulty;
    expect(dAgain, greaterThan(dGood));
    expect(dGood, greaterThan(dEasy));
  });
}
