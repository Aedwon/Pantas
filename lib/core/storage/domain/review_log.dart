import 'package:cse_cet_reviewer/core/fsrs/rating.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/review_state.dart';
import 'package:meta/meta.dart';

@immutable
class ReviewLog {
  const ReviewLog({
    required this.id,
    required this.questionId,
    required this.rating,
    required this.state,
    required this.due,
    required this.stability,
    required this.difficulty,
    required this.elapsedDays,
    required this.lastElapsedDays,
    required this.scheduledDays,
    required this.review,
    required this.durationMs,
    required this.isCorrect,
    required this.heuristicVersion,
  });

  final String id;
  final QuestionId questionId;
  final Rating rating;
  final ReviewStage state;
  final DateTime due;
  final double stability;
  final double difficulty;
  final double elapsedDays;
  final double lastElapsedDays;
  final double scheduledDays;
  final DateTime review;
  final int durationMs;
  final bool isCorrect;
  final int heuristicVersion;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewLog &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          questionId == other.questionId &&
          rating == other.rating &&
          state == other.state &&
          due.millisecondsSinceEpoch == other.due.millisecondsSinceEpoch &&
          (stability - other.stability).abs() < 1e-6 &&
          (difficulty - other.difficulty).abs() < 1e-6 &&
          (elapsedDays - other.elapsedDays).abs() < 1e-6 &&
          (lastElapsedDays - other.lastElapsedDays).abs() < 1e-6 &&
          (scheduledDays - other.scheduledDays).abs() < 1e-6 &&
          review.millisecondsSinceEpoch ==
              other.review.millisecondsSinceEpoch &&
          durationMs == other.durationMs;

  @override
  int get hashCode => Object.hash(
        id,
        questionId,
        rating,
        state,
        due.millisecondsSinceEpoch,
        stability,
        difficulty,
        elapsedDays,
        lastElapsedDays,
        scheduledDays,
        review.millisecondsSinceEpoch,
        durationMs,
      );

  @override
  String toString() =>
      'ReviewLog(id: $id, questionId: $questionId, rating: $rating, '
      'state: $state, due: $due, stability: $stability, '
      'difficulty: $difficulty, elapsedDays: $elapsedDays, '
      'lastElapsedDays: $lastElapsedDays, scheduledDays: $scheduledDays, '
      'review: $review, durationMs: $durationMs, isCorrect: $isCorrect, '
      'heuristicVersion: $heuristicVersion)';
}
