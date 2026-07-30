import 'package:meta/meta.dart';
import 'package:pantas/core/sync/sync_status.dart';

@immutable
class BackupDiagnostics {
  const BackupDiagnostics({
    required this.lastSyncIso,
    required this.pendingCount,
    required this.networkStatus,
  });

  final String lastSyncIso;
  final int pendingCount;
  final String networkStatus;
}

@immutable
class BackupViewState {
  const BackupViewState({
    required this.headline,
    required this.subtitle,
    required this.details,
    this.actionLabel,
  });

  factory BackupViewState.fromSync({
    required bool isAnonymous,
    required SyncStatus syncStatus,
  }) {
    if (isAnonymous) {
      return const BackupViewState(
        headline: "Your progress isn't backed up",
        subtitle: 'Sign in to save your progress across devices.',
        actionLabel: 'Sign in with Google',
        details: BackupDiagnostics(
          lastSyncIso: 'Never',
          pendingCount: 0,
          networkStatus: 'Unknown',
        ),
      );
    }

    return switch (syncStatus) {
      Syncing(:final pendingCount) => BackupViewState(
          headline: 'Backing up your progress...',
          subtitle: '$pendingCount items left',
          details: BackupDiagnostics(
            lastSyncIso: 'Pending',
            pendingCount: pendingCount,
            networkStatus: 'Unknown',
          ),
        ),
      SyncPartialFailure() || SyncFailedSince() => const BackupViewState(
          headline: "Couldn't back up",
          subtitle: 'Tap to try again.',
          actionLabel: 'Try again',
          details: BackupDiagnostics(
            lastSyncIso: 'Unknown',
            pendingCount: 0,
            networkStatus: 'Unknown',
          ),
        ),
      SyncOk(:final lastSyncedAt, :final pendingCount) => BackupViewState(
          headline: 'Your progress is saved',
          subtitle: 'Last backup completed.',
          actionLabel: 'Sync now',
          details: BackupDiagnostics(
            lastSyncIso: lastSyncedAt.toUtc().toIso8601String(),
            pendingCount: pendingCount,
            networkStatus: 'Unknown',
          ),
        ),
      SyncIdle(:final lastSyncedAt) => BackupViewState(
          headline: 'Your progress is saved',
          subtitle: 'Backup is ready.',
          actionLabel: 'Sync now',
          details: BackupDiagnostics(
            lastSyncIso: lastSyncedAt?.toUtc().toIso8601String() ?? 'Never',
            pendingCount: 0,
            networkStatus: 'Unknown',
          ),
        ),
    };
  }

  final String headline;
  final String subtitle;
  final String? actionLabel;
  final BackupDiagnostics details;
}
