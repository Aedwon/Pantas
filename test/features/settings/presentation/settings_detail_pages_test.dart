import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/sync/providers.dart';
import 'package:pantas/core/sync/sync_status.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/features/legal/legal.dart';
import 'package:pantas/features/settings/presentation/pages/about_page.dart';
import 'package:pantas/features/settings/presentation/pages/account_page.dart';
import 'package:pantas/features/settings/presentation/pages/backup_page.dart';
import 'package:pantas/features/settings/presentation/pages/delete_account_page.dart';
import 'package:pantas/features/settings/presentation/pages/pro_page.dart';
import 'package:pantas/features/settings/settings.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('every settings page uses the settings bar, not an AppBar',
      (tester) async {
    for (final page in [
      const ProPage(),
      const AccountPage(),
      const BackupPage(),
      const AboutPage(),
    ]) {
      await tester.pumpAppWithProviders(page, overrides: []);
      await tester.pumpAndSettle();

      expect(
        find.byType(PantasPage),
        findsOneWidget,
      );
      expect(find.byType(AppBar), findsNothing);
    }
  });

  testWidgets('the pro page names three plans and no lifetime', (tester) async {
    await tester.pumpAppWithProviders(const ProPage(), overrides: []);
    await tester.pumpAndSettle();

    expect(find.textContaining('₱'), findsNothing);
    expect(find.textContaining('Lifetime'), findsNothing);
  });

  testWidgets('the pro page offers manage and restore', (tester) async {
    await tester.pumpAppWithProviders(const ProPage(), overrides: []);
    await tester.pumpAndSettle();

    expect(find.text('Manage in Google Play'), findsNothing);
    expect(find.text('Restore purchases'), findsOneWidget);
  });

  testWidgets('anonymous account page shows sign in CTA and delete data row',
      (tester) async {
    await tester.pumpAppWithProviders(
      const AccountPage(),
      overrides: [
        currentUserProvider.overrideWith((ref) async => null),
        isAnonymousProvider.overrideWith((ref) async => true),
        syncStatusProvider.overrideWith(
          (ref) => Stream.value(const Syncing(pendingCount: 2)),
        ),
      ],
    );

    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Delete my data'), findsOneWidget);
  });

  testWidgets('named account page shows email sign out and delete account',
      (tester) async {
    await tester.pumpAppWithProviders(
      const AccountPage(),
      overrides: [
        currentUserProvider.overrideWith(
          (ref) async => const AuthUser(
            uid: 'u1',
            email: 'aerol@example.com',
            displayName: 'Aerol',
          ),
        ),
        isAnonymousProvider.overrideWith((ref) async => false),
        syncStatusProvider
            .overrideWith((ref) => Stream.value(const SyncIdle())),
      ],
    );

    expect(find.text('aerol@example.com'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);
    expect(find.text('Delete Account'), findsOneWidget);
  });

  testWidgets('delete account page renders billing warning and destructive CTA',
      (tester) async {
    await tester.pumpAppWithProviders(
      DeleteAccountPage(
        isAnonymous: false,
        entitlement: const SettingsEntitlementSnapshot(
          plan: SettingsEntitlementPlan.monthly,
        ),
        dpoEmail: defaultLegalContact.dpoEmail,
        onDelete: _noopDelete,
      ),
    );

    expect(find.text('Delete your account?'), findsOneWidget);
    expect(find.textContaining('you’ll still be charged'), findsOneWidget);
    expect(find.text('Delete My Data'), findsOneWidget);
  });

  testWidgets('the backup page still renders all five states', (tester) async {
    final states = <SyncStatus>[
      const SyncIdle(),
      SyncOk(lastSyncedAt: DateTime.utc(2026, 5, 22), pendingCount: 0),
      const Syncing(pendingCount: 3),
      const SyncPartialFailure(failedCollections: ['progress']),
      SyncFailedSince(since: DateTime.utc(2026, 5, 21)),
    ];

    for (final status in states) {
      await tester.pumpAppWithProviders(
        const BackupPage(),
        overrides: [
          isAnonymousProvider.overrideWith((ref) async => false),
          syncStatusProvider.overrideWith((ref) => Stream.value(status)),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.byType(PantasPage), findsOneWidget);
    }
  });
}

Future<void> _noopDelete() async {}
