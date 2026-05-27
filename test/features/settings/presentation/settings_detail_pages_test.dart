import 'package:cse_cet_reviewer/core/auth/auth_user.dart';
import 'package:cse_cet_reviewer/core/auth/providers.dart';
import 'package:cse_cet_reviewer/core/sync/providers.dart';
import 'package:cse_cet_reviewer/core/sync/sync_status.dart';
import 'package:cse_cet_reviewer/features/settings/presentation/pages/about_page.dart';
import 'package:cse_cet_reviewer/features/settings/presentation/pages/account_page.dart';
import 'package:cse_cet_reviewer/features/settings/presentation/pages/backup_page.dart';
import 'package:cse_cet_reviewer/features/settings/presentation/pages/delete_account_page.dart';
import 'package:cse_cet_reviewer/features/settings/settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
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

    expect(find.text('Sign in with Google'), findsOneWidget);
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
    expect(find.text('Sign out'), findsOneWidget);
    expect(find.text('Delete account'), findsOneWidget);
  });

  testWidgets('delete account page renders billing warning and destructive CTA',
      (tester) async {
    await tester.pumpApp(
      const DeleteAccountPage(
        isAnonymous: false,
        entitlement: SettingsEntitlementSnapshot(
          plan: SettingsEntitlementPlan.monthly,
        ),
      ),
    );

    expect(find.text('Delete your account?'), findsOneWidget);
    expect(find.textContaining("you'll still be charged"), findsOneWidget);
    expect(find.text('Yes, delete my account'), findsOneWidget);
  });

  testWidgets('backup page shows diagnostics after expanding details',
      (tester) async {
    await tester.pumpAppWithProviders(
      const BackupPage(),
      overrides: [
        isAnonymousProvider.overrideWith((ref) async => false),
        syncStatusProvider.overrideWith(
          (ref) => Stream.value(
            SyncOk(
              lastSyncedAt: DateTime.utc(2026, 5, 22, 12),
              pendingCount: 0,
            ),
          ),
        ),
      ],
    );

    expect(find.text('Your progress is saved'), findsOneWidget);
    await tester.tap(find.text('Show details'));
    await tester.pumpAndSettle();
    expect(find.textContaining('2026-05-22T12:00:00.000Z'), findsOneWidget);
  });

  testWidgets('about page renders legal and DPO seams', (tester) async {
    await tester.pumpApp(
      const AboutPage(version: '0.1.0', buildNumber: '1'),
    );

    expect(find.text('CSE Reviewer'), findsOneWidget);
    expect(find.text('Version 0.1.0 (build 1)'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Terms of Service'), findsOneWidget);
    expect(find.text('Contact our DPO'), findsOneWidget);
    expect(find.textContaining('data export, correction'), findsOneWidget);
  });
}
