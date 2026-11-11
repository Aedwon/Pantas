// lib/core/storage/domain/attempt_origins.dart

/// Origins whose attempt rows carry no per-question timing.
///
/// The assessment records which choice was made and nothing about how long
/// it took, so its items are written with `responseMs: 0`. Any signal that
/// reads a millisecond figure must skip these rows, or it will read those
/// zeros as twenty-one questions answered instantly.
///
/// Remove an origin from this set the moment it starts capturing timing.
abstract final class AttemptOrigins {
  const AttemptOrigins._();

  static const Set<String> untimed = {'assessment', mock};

  /// A submitted mock recorded as ordinary answers. The mock records the clock
  /// per section, not per question, so its items are untimed too.
  static const String mock = 'mock';

  /// Origins whose rows repeat a record kept in another table. A reader that
  /// already counts that other table must skip these rows, or it counts the
  /// same answers twice: `mock` rows repeat `mock_attempts`.
  static const Set<String> mirrored = {mock};
}
