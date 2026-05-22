class BackoffPolicy {
  static const _cap = Duration(minutes: 30);

  int _attempt = 0;

  Duration nextDelay() {
    final seconds = 1 << _attempt;
    _attempt += 1;
    final delay = Duration(seconds: seconds);
    return delay > _cap ? _cap : delay;
  }

  void reset() {
    _attempt = 0;
  }
}
