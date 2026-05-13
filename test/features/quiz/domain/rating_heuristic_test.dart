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

  test('correct + fast (<2500ms) → Easy', () {
    expect(
      RatingHeuristic.from(isCorrect: true, responseMs: 1200),
      equals(Rating.easy),
    );
    expect(
      RatingHeuristic.from(isCorrect: true, responseMs: 2499),
      equals(Rating.easy),
    );
  });

  test('correct + normal (2500..8000ms) → Good', () {
    expect(
      RatingHeuristic.from(isCorrect: true, responseMs: 2500),
      equals(Rating.good),
    );
    expect(
      RatingHeuristic.from(isCorrect: true, responseMs: 5000),
      equals(Rating.good),
    );
    expect(
      RatingHeuristic.from(isCorrect: true, responseMs: 8000),
      equals(Rating.good),
    );
  });

  test('correct + slow (>8000ms) → Hard', () {
    expect(
      RatingHeuristic.from(isCorrect: true, responseMs: 8001),
      equals(Rating.hard),
    );
    expect(
      RatingHeuristic.from(isCorrect: true, responseMs: 25000),
      equals(Rating.hard),
    );
  });
}
