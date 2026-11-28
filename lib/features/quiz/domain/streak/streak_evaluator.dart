import 'package:pantas/core/storage/data/repos/streak_repository.dart';
import 'package:pantas/core/time/local_day.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';

class StreakEvaluation {
  const StreakEvaluation({
    required this.credited,
    required this.freezeUsed,
    required this.current,
  });

  final bool credited;
  final bool freezeUsed;
  final int current;
}

class StreakEvaluator {
  StreakEvaluator(
    this._streaks, {
    Future<StudyDays> Function()? studyDaysReader,
  }) : _studyDaysReader = studyDaysReader ?? (() async => StudyDays.all);

  final StreakRepository _streaks;
  final Future<StudyDays> Function() _studyDaysReader;

  Future<StreakEvaluation> evaluate({
    required SessionOrigin origin,
    required DateTime completedAt,
  }) async {
    final snapshot = await _streaks.read();
    if (!origin.isStreakEligible) {
      return StreakEvaluation(
        credited: false,
        freezeUsed: false,
        current: snapshot.current,
      );
    }

    final today = localDay(completedAt);
    final lastActive = snapshot.lastActiveDate == null
        ? null
        : localDay(snapshot.lastActiveDate!);
    if (lastActive == today) {
      return StreakEvaluation(
        credited: false,
        freezeUsed: false,
        current: snapshot.current,
      );
    }

    final studyDays = await _studyDaysReader();
    final (nextCurrent, freezeUsed, freezesRemaining) =
        _next(snapshot, lastActive, today, studyDays);
    await _streaks.writeSnapshot(
      current: nextCurrent,
      longest: nextCurrent > snapshot.longest ? nextCurrent : snapshot.longest,
      lastActiveDate: today,
      freezesRemaining: freezesRemaining,
    );
    return StreakEvaluation(
      credited: true,
      freezeUsed: freezeUsed,
      current: nextCurrent,
    );
  }

  (int current, bool freezeUsed, int freezesRemaining) _next(
    StreakSnapshot snapshot,
    DateTime? lastActive,
    DateTime today,
    StudyDays studyDays,
  ) {
    if (lastActive == null) {
      return (1, false, snapshot.freezesRemaining);
    }
    final continuation = _continuation(snapshot, lastActive, today, studyDays);
    if (continuation == null) return (1, false, snapshot.freezesRemaining);
    return (
      snapshot.current + 1,
      continuation.freezeUsed,
      snapshot.freezesRemaining - (continuation.freezeUsed ? 1 : 0),
    );
  }
}

/// The one rule for whether a streak last credited on [lastActive] carries on
/// into [today]: no study day missed, or exactly one missed with a freeze left.
/// Null when it breaks. Credit and read both use it.
({bool freezeUsed})? _continuation(
  StreakSnapshot snapshot,
  DateTime lastActive,
  DateTime today,
  StudyDays studyDays,
) {
  final gap = studyDays.missedBetween(lastActive, today);
  if (gap == 0) return (freezeUsed: false);
  if (gap == 1 && snapshot.freezesRemaining > 0) return (freezeUsed: true);
  return null;
}

/// The streak to show on [today], read from the stored [snapshot] and never
/// written back. The stored count is only updated when a session completes, so
/// after missed days it is stale. If the next session today would start over,
/// the streak already stands at zero.
int streakOn(StreakSnapshot snapshot, DateTime today, StudyDays studyDays) {
  final stored = snapshot.lastActiveDate;
  if (snapshot.current <= 0 || stored == null) return 0;
  final continues = _continuation(
        snapshot,
        localDay(stored),
        localDay(today),
        studyDays,
      ) !=
      null;
  return continues ? snapshot.current : 0;
}
