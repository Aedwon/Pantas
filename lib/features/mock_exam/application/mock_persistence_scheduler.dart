class MockPersistenceScheduler {
  MockPersistenceScheduler({required void Function(MockFlushPayload) onFlush})
      : _onFlush = onFlush;

  static const debounceDelay = Duration(milliseconds: 500);
  static const heartbeatDelay = Duration(seconds: 30);

  final void Function(MockFlushPayload) _onFlush;
  MockFlushPayload? _pendingChange;
  MockFlushPayload? _pendingHeartbeat;
  Duration _debounceElapsed = Duration.zero;
  Duration _heartbeatElapsed = Duration.zero;

  void markChanged(MockFlushPayload payload) {
    _pendingChange = payload;
    _debounceElapsed = Duration.zero;
  }

  void heartbeat(MockFlushPayload payload) {
    _pendingHeartbeat = payload;
    _heartbeatElapsed = Duration.zero;
  }

  void forceFlush(MockFlushPayload payload) {
    _pendingChange = null;
    _pendingHeartbeat = null;
    _debounceElapsed = Duration.zero;
    _heartbeatElapsed = Duration.zero;
    _onFlush(payload);
  }

  void elapse(Duration duration) {
    final pendingChange = _pendingChange;
    if (pendingChange != null) {
      _debounceElapsed += duration;
      if (_debounceElapsed >= debounceDelay) {
        _pendingChange = null;
        _debounceElapsed = Duration.zero;
        _onFlush(pendingChange);
      }
    }

    final pendingHeartbeat = _pendingHeartbeat;
    if (pendingHeartbeat != null) {
      _heartbeatElapsed += duration;
      if (_heartbeatElapsed >= heartbeatDelay) {
        _pendingHeartbeat = null;
        _heartbeatElapsed = Duration.zero;
        _onFlush(pendingHeartbeat);
      }
    }
  }
}

class MockFlushPayload {
  const MockFlushPayload({
    required this.attemptId,
    required this.elapsedSeconds,
    required this.accumulatedPausedSeconds,
    required this.pausedAtLastFlush,
    required this.answersJson,
    required this.flagsJson,
    required this.currentIndex,
  });

  final String attemptId;
  final int elapsedSeconds;
  final int accumulatedPausedSeconds;
  final bool pausedAtLastFlush;
  final String answersJson;
  final String flagsJson;
  final int currentIndex;
}
