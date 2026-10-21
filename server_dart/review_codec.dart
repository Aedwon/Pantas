// Uses the app's scheduler unchanged, with explicit UTC instants.
import 'package:pantas/core/fsrs/fsrs_scheduler.dart';
import 'package:pantas/core/fsrs/rating.dart';
import 'package:pantas/core/storage/domain/review_state.dart';

List<Map<String, Object?>> scheduleReviewStates(Map<String, Object?> input) {
  final now =
      DateTime.fromMillisecondsSinceEpoch(input['now']! as int, isUtc: true);
  final rows = input['reviews']! as List<Object?>;
  const scheduler = FsrsScheduler();
  final states = <String, ReviewState>{};
  for (final raw in rows) {
    final row = raw! as Map<String, Object?>;
    final id = row['questionId']! as String;
    final previous = row['previous'];
    final prev = states[id] ??
        (previous == null
            ? ReviewState.seed(
                questionId: id,
                questionVersion: row['questionVersion']! as int,
                now: now,
              )
            : ReviewState.fromJson((previous as Map).cast<String, dynamic>()));
    // Historical reconciliation counts the answers but cannot rewind reviews.
    states[id] = prev.lastReview.isAfter(now)
        ? prev
        : scheduler.next(
            prev: prev,
            rating: row['correct']! as bool ? Rating.good : Rating.again,
            now: now,
          );
  }
  return [for (final state in states.values) state.toJson()];
}

List<Map<String, Object?>> dueReviewInputs(Map<String, Object?> input) {
  final now =
      DateTime.fromMillisecondsSinceEpoch(input['now']! as int, isUtc: true);
  const scheduler = FsrsScheduler();
  final out = <Map<String, Object?>>[];
  for (final raw in input['states']! as List<Object?>) {
    final state = ReviewState.fromJson((raw! as Map).cast<String, dynamic>());
    out.add({
      'id': state.questionId,
      'due': state.due.millisecondsSinceEpoch,
      'retrievability': scheduler.retrievability(state, now),
    });
  }
  return out;
}
