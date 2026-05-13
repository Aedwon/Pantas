import 'package:cse_cet_reviewer/core/fsrs/rating.dart';

abstract final class RatingHeuristic {
  static const _fastThresholdMs = 2500;
  static const _slowThresholdMs = 8000;

  static Rating from({required bool isCorrect, required int responseMs}) {
    if (!isCorrect) return Rating.again;
    if (responseMs < _fastThresholdMs) return Rating.easy;
    if (responseMs > _slowThresholdMs) return Rating.hard;
    return Rating.good;
  }
}
