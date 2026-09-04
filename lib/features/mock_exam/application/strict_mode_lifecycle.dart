class StrictModeLifecycle {
  StrictModeLifecycle({
    required this.strictMode,
    required void Function() onForfeit,
  }) : _onForfeit = onForfeit;

  static const guardDelay = Duration(seconds: 5);

  final bool strictMode;
  final void Function() _onForfeit;
  Duration? _backgroundElapsed;
  DateTime? _backgroundedAt;
  var _forfeited = false;

  void paused(DateTime now) {
    if (!strictMode || _forfeited || _backgroundedAt != null) return;
    _backgroundElapsed = Duration.zero;
    _backgroundedAt = now;
  }

  void resumed(DateTime now) {
    final backgroundedAt = _backgroundedAt;
    if (strictMode &&
        !_forfeited &&
        backgroundedAt != null &&
        now.difference(backgroundedAt) > guardDelay) {
      _forfeit();
      return;
    }
    _backgroundElapsed = null;
    _backgroundedAt = null;
  }

  void elapse(Duration duration) {
    final elapsed = _backgroundElapsed;
    if (elapsed == null || _forfeited) return;
    final next = elapsed + duration;
    _backgroundElapsed = next;
    if (next > guardDelay) {
      _forfeit();
    }
  }

  void _forfeit() {
    _forfeited = true;
    _backgroundElapsed = null;
    _backgroundedAt = null;
    _onForfeit();
  }
}
