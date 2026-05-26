class StrictModeLifecycle {
  StrictModeLifecycle({
    required this.strictMode,
    required void Function() onForfeit,
  }) : _onForfeit = onForfeit;

  static const guardDelay = Duration(seconds: 5);

  final bool strictMode;
  final void Function() _onForfeit;
  Duration? _backgroundElapsed;
  var _forfeited = false;

  void paused() {
    if (!strictMode || _forfeited) return;
    _backgroundElapsed = Duration.zero;
  }

  void resumed() {
    _backgroundElapsed = null;
  }

  void elapse(Duration duration) {
    final elapsed = _backgroundElapsed;
    if (elapsed == null || _forfeited) return;
    final next = elapsed + duration;
    _backgroundElapsed = next;
    if (next > guardDelay) {
      _forfeited = true;
      _backgroundElapsed = null;
      _onForfeit();
    }
  }
}
