import 'package:flutter/painting.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';

/// Rust below 50, amber below 70, plain ink above.
///
/// Home's practice panel and Progress's performance table show the same
/// figure for the same topic, so they must colour it the same way. A
/// second copy of these thresholds is how a student catches the app
/// disagreeing with itself at 49.6%.
Color severityFor(double accuracy, PantasColors colors) {
  final pct = accuracy * 100;
  if (pct < 50) return colors.destructive;
  if (pct < 70) return colors.pro;
  return colors.label;
}
