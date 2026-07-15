import 'dart:math' as math;

enum ClockUrgency { ample, closing, last }

/// Minutes remaining at which the proctor speaks. Descending, because a
/// clock that jumped past two of them must report the one the student is
/// actually at.
const callThresholdsMinutes = [1, 5, 10, 20];

Duration remainingInPart({
  required Duration partLength,
  required Duration elapsedInPart,
}) {
  final left = partLength - elapsedInPart;
  return left.isNegative ? Duration.zero : left;
}

ClockUrgency urgencyFor(Duration remaining) {
  if (remaining <= const Duration(minutes: 1)) return ClockUrgency.last;
  if (remaining <= const Duration(minutes: 5)) return ClockUrgency.closing;
  return ClockUrgency.ample;
}

/// The threshold just crossed, or null. Called on every tick with the
/// previous and current remaining time.
int? callThresholdCrossed({
  required Duration before,
  required Duration after,
}) {
  // Time up is its own event and the transition screen handles it. A call
  // saying "1 minute left" as the part ends would be a lie.
  if (after <= Duration.zero) return null;

  for (final minutes in callThresholdsMinutes) {
    final mark = Duration(minutes: minutes);
    if (before > mark && after <= mark) return minutes;
  }
  return null;
}

/// A part's length as a fraction still to run, for the retreating rule.
double remainingFraction({
  required Duration partLength,
  required Duration remaining,
}) {
  if (partLength <= Duration.zero) return 0;
  final f = remaining.inMilliseconds / partLength.inMilliseconds;
  return math.min(1, math.max(0, f));
}
