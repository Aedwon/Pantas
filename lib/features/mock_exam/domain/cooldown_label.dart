/// The mock panel's trailing count: "9d 14h", precise to the hour.
///
/// Precise because a student setting an alarm needs to know which day it
/// reopens on, and "in 9 days" does not say. The tile this replaced read
/// `.inDays`, so 23 hours left displayed as "0 days".
///
/// Returns null when nothing is left to wait for, because the panel's header
/// carries a count or nothing at all.
String? cooldownLabel(Duration remaining) {
  if (remaining <= Duration.zero) return null;

  // Round part hours up. "0h" on a button that is still locked is a lie, and
  // the error is at most an hour on a fourteen day wait.
  final totalHours = (remaining.inMinutes / 60).ceil();
  final days = totalHours ~/ 24;
  final hours = totalHours % 24;

  if (days == 0) return '${hours}h';
  if (hours == 0) return '${days}d';
  return '${days}d ${hours}h';
}
