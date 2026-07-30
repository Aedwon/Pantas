import 'package:pantas/features/metrics/domain/metrics_window.dart';

class MetricsThresholds {
  const MetricsThresholds._();

  static const fsrsStrongStabilityDays = 14.0;

  static int minSessionsFor(MetricsWindow window) {
    return switch (window) {
      MetricsWindow.rolling30d => 7,
      MetricsWindow.prepWindow => 14,
      MetricsWindow.allTime => 1,
    };
  }
}
