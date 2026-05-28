enum MetricsWindow {
  rolling30d,
  prepWindow,
  allTime,
}

class ResolvedMetricsWindow {
  const ResolvedMetricsWindow({
    required this.window,
    required this.start,
    required this.end,
    required this.sessionCount,
    required this.minSessionCount,
  });

  final MetricsWindow window;
  final DateTime? start;
  final DateTime end;
  final int sessionCount;
  final int minSessionCount;

  bool get hasEnoughData => sessionCount >= minSessionCount;
}
