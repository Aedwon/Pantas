import 'package:pantas/core/storage/data/app_database.dart';

/// What the app remembers about asking for a review.
class ReviewPromptRecord {
  const ReviewPromptRecord({this.askedAt, this.paywallSeenAt});

  final DateTime? askedAt;
  final DateTime? paywallSeenAt;
}

abstract interface class ReviewPromptStore {
  Future<ReviewPromptRecord> read();
  Future<void> recordAsked(DateTime at);
  Future<void> recordPaywallSeen(DateTime at);
}

abstract final class ReviewPromptKeys {
  static const askedAt = 'review_prompt.asked_at';
  static const paywallSeenAt = 'review_prompt.paywall_seen_at';
}

/// Kept on the device, not the account.
///
/// A review belongs to the store account on this phone. Syncing "already
/// asked" to a second device would suppress the one honest ask there.
class DriftReviewPromptStore implements ReviewPromptStore {
  DriftReviewPromptStore(this._db);

  final AppDatabase _db;

  @override
  Future<ReviewPromptRecord> read() async {
    final rows = await _db.select(_db.devicePrefs).get();
    final values = {for (final row in rows) row.key: row.value};
    return ReviewPromptRecord(
      askedAt: DateTime.tryParse(values[ReviewPromptKeys.askedAt] ?? ''),
      paywallSeenAt: DateTime.tryParse(
        values[ReviewPromptKeys.paywallSeenAt] ?? '',
      ),
    );
  }

  @override
  Future<void> recordAsked(DateTime at) => _write(ReviewPromptKeys.askedAt, at);

  @override
  Future<void> recordPaywallSeen(DateTime at) =>
      _write(ReviewPromptKeys.paywallSeenAt, at);

  Future<void> _write(String key, DateTime at) async {
    await _db.into(_db.devicePrefs).insertOnConflictUpdate(
          DevicePrefsCompanion.insert(
            key: key,
            value: at.toUtc().toIso8601String(),
          ),
        );
  }
}

/// The default outside a booted app, including every widget test.
///
/// It forgets on restart, which is correct for a test and harmless
/// anywhere else, because the gateway in those builds shows nothing.
class InMemoryReviewPromptStore implements ReviewPromptStore {
  DateTime? _askedAt;
  DateTime? _paywallSeenAt;

  @override
  Future<ReviewPromptRecord> read() async => ReviewPromptRecord(
        askedAt: _askedAt,
        paywallSeenAt: _paywallSeenAt,
      );

  @override
  Future<void> recordAsked(DateTime at) async => _askedAt = at;

  @override
  Future<void> recordPaywallSeen(DateTime at) async => _paywallSeenAt = at;
}
