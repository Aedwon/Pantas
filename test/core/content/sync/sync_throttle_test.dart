import 'package:pantas/core/content/sync/sync_status.dart';
import 'package:pantas/core/content/sync/sync_throttle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 5, 17, 8);

  test('isStale returns true when lastSyncedAt is missing', () {
    expect(ContentSyncThrottle(now: () => now).isStale(null), isTrue);
  });

  test('isStale returns false inside six hour window', () {
    final throttle = ContentSyncThrottle(now: () => now);

    expect(throttle.isStale(now.subtract(const Duration(hours: 5))), isFalse);
  });

  test('isStale returns true at exactly six hours', () {
    final throttle = ContentSyncThrottle(now: () => now);

    expect(throttle.isStale(now.subtract(const Duration(hours: 6))), isTrue);
  });

  test('SyncStatus exposes idle syncing ok partialFailure and failure states',
      () {
    expect(const SyncStatus.idle(), isA<SyncIdle>());
    expect(const SyncStatus.syncing(), isA<Syncing>());
    expect(SyncStatus.ok(at: now, updatedCount: 1), isA<SyncOk>());
    expect(
      const SyncStatus.partialFailure(failedDoctypes: ['question']),
      isA<SyncPartialFailure>(),
    );
    expect(const SyncStatus.failure(reason: 'offline'), isA<SyncFailure>());
  });
}
