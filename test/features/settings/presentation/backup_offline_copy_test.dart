import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/sync/providers.dart';
import 'package:pantas/core/sync/sync_status.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/settings/presentation/pages/backup_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Backup page copy', () {
    testWidgets('shows "Not backed up yet" when no sync date exists',
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

      expect(find.text('Not backed up yet'), findsOneWidget);
      expect(find.textContaining('items left'), findsNothing);
      expect(find.textContaining('Pending queue'), findsNothing);
    });

    testWidgets('shows "Last backed up" with date when synced', (tester) async {
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

      expect(find.text('Last backed up 2026-08-03'), findsOneWidget);
    });
  });
}
