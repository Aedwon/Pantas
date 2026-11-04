import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/sync/providers.dart';
import 'package:pantas/core/sync/sync_status.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/settings/presentation/pages/account_page.dart';
import 'package:pantas/features/settings/presentation/pages/backup_page.dart';
import 'package:pantas/features/settings/presentation/settings_home_page.dart';

void main() {
  group('Silent sync invariants', () {
    testWidgets(
        'SettingsHomePage backup subtitle never exposes queue counter or '
        'failure', (tester) async {
      const syncStatus = SyncPartialFailure(
        failedCollections: ['progress'],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isAnonymousProvider.overrideWith((ref) => false),
            syncStatusProvider.overrideWith((ref) => Stream.value(syncStatus)),
          ],
          child: MaterialApp(
            theme: buildLightTheme(),
            home: const SettingsHomePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining("Couldn't back up"), findsNothing);
      expect(find.textContaining('pending'), findsNothing);
      expect(find.textContaining('items left'), findsNothing);
    });

    testWidgets('AccountPage sign out never exposes pending queue count',
        (tester) async {
      const syncStatus = Syncing(pendingCount: 5);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) => null),
            isAnonymousProvider.overrideWith((ref) => false),
            syncStatusProvider.overrideWith((ref) => Stream.value(syncStatus)),
          ],
          child: MaterialApp(
            theme: buildLightTheme(),
            home: const AccountPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('items not yet backed up'), findsNothing);
      expect(find.textContaining('pending'), findsNothing);
    });

    testWidgets(
        'native BackupPage shows measured work without network internals',
        (tester) async {
      const syncStatus = Syncing(pendingCount: 12);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isAnonymousProvider.overrideWith((ref) => false),
            syncStatusProvider.overrideWith((ref) => Stream.value(syncStatus)),
          ],
          child: MaterialApp(
            theme: buildLightTheme(),
            home: const BackupPage(),
          ),
        ),
      );
      // Backing up has a continuous spinner, so settling is not completion.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Backing up'), findsOneWidget);
      expect(find.text('12 changes'), findsOneWidget);
      expect(find.textContaining('Pending queue'), findsNothing);
      expect(find.textContaining('Network'), findsNothing);
    });
  });
}
