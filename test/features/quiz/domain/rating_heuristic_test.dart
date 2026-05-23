import 'package:cse_cet_reviewer/core/fsrs/rating.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/rating_heuristic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('incorrect always → Again', () {
    expect(
      RatingHeuristic.from(isCorrect: false, responseMs: 1000),
      equals(Rating.again),
    );
    expect(
      RatingHeuristic.from(isCorrect: false, responseMs: 99999),
      equals(Rating.again),
    );
  });

  test('correct + fast under eight seconds is capped to Good for new cards',
      () {
    expect(
      RatingHeuristic.from(isCorrect: true, responseMs: 1200),
      equals(Rating.good),
    );
  });

  test('correct + normal pace derives Good', () {
    expect(
      RatingHeuristic.from(isCorrect: true, responseMs: 8000),
      equals(Rating.good),
    );
    expect(
      RatingHeuristic.from(isCorrect: true, responseMs: 25000),
      equals(Rating.good),
    );
  });

  test('correct + slow over 25 seconds derives Hard', () {
    expect(
      RatingHeuristic.from(isCorrect: true, responseMs: 25001),
      equals(Rating.hard),
    );
  });
}
