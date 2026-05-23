import 'package:cse_cet_reviewer/core/fsrs/rating.dart';
import 'package:cse_cet_reviewer/core/fsrs/rating_heuristic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('wrong answers derive Again', () {
    expect(
      FsrsRatingHeuristic.derive(
        isCorrect: false,
        responseMs: 1000,
        currentIntervalDays: 0,
      ),
      Rating.again,
    );
  });

  test('correct answers over 25 seconds derive Hard', () {
    expect(
      FsrsRatingHeuristic.derive(
        isCorrect: true,
        responseMs: 25001,
        currentIntervalDays: 0,
      ),
      Rating.hard,
    );
  });

  test('correct normal pace answers derive Good', () {
    expect(
      FsrsRatingHeuristic.derive(
        isCorrect: true,
        responseMs: 12000,
        currentIntervalDays: 0,
      ),
      Rating.good,
    );
  });

  test('correct under 8 seconds derives Easy only for mature cards', () {
    expect(
      FsrsRatingHeuristic.derive(
        isCorrect: true,
        responseMs: 7999,
        currentIntervalDays: 21,
      ),
      Rating.easy,
    );
    expect(
      FsrsRatingHeuristic.derive(
        isCorrect: true,
        responseMs: 7999,
        currentIntervalDays: 20.999,
      ),
      Rating.good,
    );
  });

  test('exact boundary values preserve the spec table', () {
    expect(
      FsrsRatingHeuristic.derive(
        isCorrect: true,
        responseMs: 25000,
        currentIntervalDays: 0,
      ),
      Rating.good,
    );
    expect(
      FsrsRatingHeuristic.derive(
        isCorrect: true,
        responseMs: 8000,
        currentIntervalDays: 21,
      ),
      Rating.good,
    );
  });
}
