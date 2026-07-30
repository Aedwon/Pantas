import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/sync/sync_status.dart';
import 'package:pantas/features/settings/domain/backup_status.dart';

void main() {
  test('anonymous backup status asks user to sign in', () {
    final status = BackupViewState.fromSync(
      isAnonymous: true,
      syncStatus: const SyncIdle(),
    );

    expect(status.headline, "Your progress isn't backed up");
    expect(status.actionLabel, 'Sign in with Google');
  });

  test('idle or ok status renders progress saved', () {
    final status = BackupViewState.fromSync(
      isAnonymous: false,
      syncStatus: SyncOk(
        lastSyncedAt: DateTime.utc(2026, 5, 22, 12),
        pendingCount: 0,
      ),
    );

    expect(status.headline, 'Your progress is saved');
    expect(status.details.lastSyncIso, '2026-05-22T12:00:00.000Z');
  });

  test('syncing status renders pending count', () {
    final status = BackupViewState.fromSync(
      isAnonymous: false,
      syncStatus: const Syncing(pendingCount: 3),
    );

    expect(status.headline, 'Backing up your progress...');
    expect(status.subtitle, '3 items left');
  });

  test('failed status renders retry action', () {
    final status = BackupViewState.fromSync(
      isAnonymous: false,
      syncStatus: SyncFailedSince(since: DateTime.utc(2026, 5, 22)),
    );

    expect(status.headline, "Couldn't back up");
    expect(status.actionLabel, 'Try again');
  });
}
