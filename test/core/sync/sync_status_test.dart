import 'package:cse_cet_reviewer/core/sync/sync_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('partialFailure is emitted after three consecutive failures', () {
    final tracker = SyncFailureTracker(
      now: () => DateTime.utc(2026, 5, 18),
    );

    tracker.recordFailure(collection: 'quiz_attempts');
    tracker.recordFailure(collection: 'quiz_attempts');
    final status = tracker.recordFailure(collection: 'quiz_attempts');

    expect(status, isA<SyncPartialFailure>());
    expect((status as SyncPartialFailure).failedCollections, ['quiz_attempts']);
  });

  test('failedSince is emitted after 24 hours of continuous failure', () {
    var now = DateTime.utc(2026, 5, 18);
    final tracker = SyncFailureTracker(now: () => now);

    tracker.recordFailure(collection: 'fsrs_cards');
    now = now.add(const Duration(hours: 24, seconds: 1));
    final status = tracker.recordFailure(collection: 'fsrs_cards');

    expect(status, isA<SyncFailedSince>());
    expect((status as SyncFailedSince).since, DateTime.utc(2026, 5, 18));
  });

  test('success resets failure state and emits ok', () {
    final tracker = SyncFailureTracker(
      now: () => DateTime.utc(2026, 5, 18, 1),
    );

    tracker.recordFailure(collection: 'lesson_progress');
    final status = tracker.recordSuccess(pendingCount: 0);

    expect(status, isA<SyncOk>());
    expect((status as SyncOk).pendingCount, 0);
  });
}
