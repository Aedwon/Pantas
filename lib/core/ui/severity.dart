import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
import 'package:flutter/painting.dart';

/// Rust below 50, amber below 70, plain ink above.
///
/// Home's practice panel and Progress's performance table show the same
/// figure for the same topic, so they must colour it the same way. A
/// second copy of these thresholds is how a student catches the app
/// disagreeing with itself at 49.6%.
Color severityFor(double accuracy, AppColors colors) {
  final pct = accuracy * 100;
  if (pct < 50) return colors.rust;
  if (pct < 70) return colors.amber;
  return colors.ink;
}
