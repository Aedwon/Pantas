import 'package:pantas/core/storage/data/repos/streak_repository.dart';
import 'package:pantas/core/time/local_day.dart';
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
  const StreakEvaluator(this._streaks);

  final StreakRepository _streaks;

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

    final (nextCurrent, freezeUsed, freezesRemaining) =
        _next(snapshot, lastActive, today);
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
  ) {
    if (lastActive == null) {
      return (1, false, snapshot.freezesRemaining);
    }
    final gap = today.difference(lastActive).inDays;
    if (gap == 1) {
      return (snapshot.current + 1, false, snapshot.freezesRemaining);
    }
    if (gap == 2 && snapshot.freezesRemaining > 0) {
      return (snapshot.current + 1, true, snapshot.freezesRemaining - 1);
    }
    return (1, false, snapshot.freezesRemaining);
  }
}
