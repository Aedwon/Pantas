typedef QuizPerformanceSampleSink = void Function(QuizPerformanceSample sample);

enum QuizPerformancePhase {
  scopeResolution,
  metadataRead,
  historyRead,
  selection,
  hydration,
  sessionPersistence,
}

final class QuizPerformanceSample {
  const QuizPerformanceSample({
    required this.phase,
    required this.elapsed,
  });

  final QuizPerformancePhase phase;
  final Duration elapsed;

  Map<String, Object> toJson() => {
        'phase': _phaseName(phase),
        'elapsed_us': elapsed.inMicroseconds,
      };
}

final class QuizPerformanceProbe {
  const QuizPerformanceProbe.disabled() : _sink = null;

  const QuizPerformanceProbe.recording(QuizPerformanceSampleSink sink)
      : _sink = sink;

  final QuizPerformanceSampleSink? _sink;

  bool get enabled => _sink != null;

  Future<T> measureAsync<T>(
    QuizPerformancePhase phase,
    Future<T> Function() operation,
  ) {
    if (_sink == null) return operation();
    return _measureAsync(phase, operation);
  }

  T measureSync<T>(
    QuizPerformancePhase phase,
    T Function() operation,
  ) {
    final sink = _sink;
    if (sink == null) return operation();
    final stopwatch = Stopwatch()..start();
    try {
      return operation();
    } finally {
      stopwatch.stop();
      sink(QuizPerformanceSample(phase: phase, elapsed: stopwatch.elapsed));
    }
  }

  Future<T> _measureAsync<T>(
    QuizPerformancePhase phase,
    Future<T> Function() operation,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      return await operation();
    } finally {
      stopwatch.stop();
      _sink!(QuizPerformanceSample(phase: phase, elapsed: stopwatch.elapsed));
    }
  }
}

String _phaseName(QuizPerformancePhase phase) => switch (phase) {
      QuizPerformancePhase.scopeResolution => 'scope_resolution',
      QuizPerformancePhase.metadataRead => 'metadata_read',
      QuizPerformancePhase.historyRead => 'history_read',
      QuizPerformancePhase.selection => 'selection',
      QuizPerformancePhase.hydration => 'hydration',
      QuizPerformancePhase.sessionPersistence => 'session_persistence',
    };
