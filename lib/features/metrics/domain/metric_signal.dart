import 'package:cse_cet_reviewer/features/metrics/domain/metrics_window.dart';

abstract interface class Signal<T> {
  Set<MetricsWindow> get supportedWindows;
  int get minDataPoints;

  Future<T?> compute({
    required ResolvedMetricsWindow window,
    required String examId,
  });
}

class SignalResult<T> {
  const SignalResult({
    required this.window,
    required this.value,
  });

  final ResolvedMetricsWindow window;
  final T? value;
}
