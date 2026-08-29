enum SyncCausalBaseState {
  unbound,
  knownAbsent,
  knownVersion;

  String get storageValue => switch (this) {
        SyncCausalBaseState.unbound => 'unbound',
        SyncCausalBaseState.knownAbsent => 'knownAbsent',
        SyncCausalBaseState.knownVersion => 'knownVersion',
      };
}

class SyncCausalBase {
  const SyncCausalBase.unbound()
      : state = SyncCausalBaseState.unbound,
        updatedAt = null;

  const SyncCausalBase.knownAbsent()
      : state = SyncCausalBaseState.knownAbsent,
        updatedAt = null;

  const SyncCausalBase.knownVersion(this.updatedAt)
      : state = SyncCausalBaseState.knownVersion;

  final SyncCausalBaseState state;
  final DateTime? updatedAt;
}
