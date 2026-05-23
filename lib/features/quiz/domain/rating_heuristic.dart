import 'package:cse_cet_reviewer/core/fsrs/rating.dart';
import 'package:cse_cet_reviewer/core/fsrs/rating_heuristic.dart';

abstract final class RatingHeuristic {
  static Rating from({required bool isCorrect, required int responseMs}) {
    return FsrsRatingHeuristic.derive(
      isCorrect: isCorrect,
      responseMs: responseMs,
      currentIntervalDays: 0,
    );
  }
}
