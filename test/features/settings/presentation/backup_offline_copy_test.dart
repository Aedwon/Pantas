import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/sync/providers.dart';
import 'package:pantas/core/sync/sync_status.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/settings/presentation/pages/backup_page.dart';

void main() {
  group('Backup page copy', () {
    testWidgets('shows "Not backed up" when no sync date exists',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isAnonymousProvider.overrideWith((ref) => false),
            syncStatusProvider.overrideWith(
              (ref) => Stream.value(const SyncIdle()),
            ),
          ],
          child: MaterialApp(
            theme: buildLightTheme(),
            home: const BackupPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Not backed up'), findsOneWidget);
      expect(find.textContaining('items left'), findsNothing);
      expect(find.textContaining('Pending queue'), findsNothing);
    });

    testWidgets('shows the saved date in the one Backup row', (tester) async {
      final syncDate = DateTime(2026, 8, 3);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isAnonymousProvider.overrideWith((ref) => false),
            syncStatusProvider.overrideWith(
              (ref) => Stream.value(
                SyncOk(lastSyncedAt: syncDate, pendingCount: 0),
              ),
            ),
          ],
          child: MaterialApp(
            theme: buildLightTheme(),
            home: const BackupPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Saved Aug 3, 12:00'), findsOneWidget);
      expect(find.text('Last backed up'), findsNothing);
    });
  });

  group('backupLabel', () {
    final now = DateTime(2026, 11, 8, 21, 40);
    // intl puts a narrow no-break space before AM and PM.
    String saved(DateTime at) =>
        backupLabel(SyncUpToDate(lastSyncedAt: at), now: now)
            .replaceAll('\u202f', ' ');

    test('today, yesterday and older dates', () {
      expect(saved(DateTime(2026, 11, 8, 21, 39)), 'Saved today, 9:39 PM');
      expect(saved(DateTime(2026, 11, 7, 21, 39)), 'Saved yesterday, 9:39 PM');
      expect(saved(DateTime(2026, 11, 6, 21, 39)), 'Saved Nov 6, 9:39 PM');
    });

    test('no recorded time says Saved', () {
      expect(backupLabel(const SyncUpToDate(), now: now), 'Saved');
    });

    test('busy, offline and failed', () {
      expect(backupLabel(const Syncing(), now: now), 'Backing up');
      expect(backupLabel(const SyncActivating(), now: now), 'Backing up');
      expect(backupLabel(const SyncOffline(), now: now), 'Offline');
      expect(backupLabel(const SyncError(), now: now), "Couldn't back up");
      expect(backupLabel(null, now: now), 'Not backed up');
    });
  });
}
