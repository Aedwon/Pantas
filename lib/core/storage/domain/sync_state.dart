enum SyncState {
  pending,
  synced,
  failed;

  static SyncState fromString(String raw) => SyncState.values.firstWhere(
        (s) => s.name == raw,
        orElse: () => SyncState.pending,
      );
}
