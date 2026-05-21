class ContentSyncThrottle {
  ContentSyncThrottle({
    required this.now,
    this.window = const Duration(hours: 6),
  });

  final DateTime Function() now;
  final Duration window;

  bool isStale(DateTime? lastSyncedAt) {
    if (lastSyncedAt == null) return true;
    return !now().difference(lastSyncedAt).isNegative &&
        now().difference(lastSyncedAt) >= window;
  }
}
