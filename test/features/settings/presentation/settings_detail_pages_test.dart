import 'package:cse_cet_reviewer/core/auth/auth_user.dart';
import 'package:cse_cet_reviewer/core/auth/providers.dart';
import 'package:cse_cet_reviewer/core/sync/providers.dart';
import 'package:cse_cet_reviewer/core/sync/sync_status.dart';
import 'package:cse_cet_reviewer/features/legal/legal.dart';
import 'package:cse_cet_reviewer/features/settings/presentation/pages/about_page.dart';
import 'package:cse_cet_reviewer/features/settings/presentation/pages/account_page.dart';
import 'package:cse_cet_reviewer/features/settings/presentation/pages/backup_page.dart';
import 'package:cse_cet_reviewer/features/settings/presentation/pages/delete_account_page.dart';
import 'package:cse_cet_reviewer/features/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

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
      AboutPage(
        version: '0.1.0',
        buildNumber: '1',
        dpoEmail: defaultLegalContact.dpoEmail,
        physicalAddress: defaultLegalContact.physicalAddress,
      ),
    );

    expect(find.text('CSE Reviewer'), findsOneWidget);
    expect(find.text('Version 0.1.0 (build 1)'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Terms of Service'), findsOneWidget);
    expect(find.text('Contact our DPO'), findsOneWidget);
    expect(find.textContaining('data export, correction'), findsOneWidget);
    expect(
      find.textContaining('Pantas. All rights reserved.'),
      findsOneWidget,
    );
  });

  testWidgets('about page shows configured DPO email and physical address',
      (tester) async {
    await tester.pumpApp(
      AboutPage(
        version: '0.1.0',
        buildNumber: '1',
        dpoEmail: defaultLegalContact.dpoEmail,
        physicalAddress: defaultLegalContact.physicalAddress,
      ),
    );

    expect(find.text(defaultLegalContact.dpoEmail), findsOneWidget);
    expect(
      find.textContaining(defaultLegalContact.physicalAddress),
      findsOneWidget,
    );
    expect(find.textContaining('example.com'), findsNothing);
  });

  testWidgets('about page privacy and terms rows navigate to legal routes',
      (tester) async {
    var location = '/settings/about';
    final router = GoRouter(
      initialLocation: location,
      routes: [
        GoRoute(
          path: '/settings/about',
          builder: (_, __) => AboutPage(
            version: '0.1.0',
            buildNumber: '1',
            dpoEmail: defaultLegalContact.dpoEmail,
            physicalAddress: defaultLegalContact.physicalAddress,
          ),
        ),
        GoRoute(
          path: '/legal/:doc',
          builder: (_, state) => Scaffold(
            body: Text('Legal ${state.pathParameters['doc']}'),
          ),
        ),
      ],
      redirect: (_, state) {
        location = state.uri.toString();
        return null;
      },
    );

    await tester.pumpAppWithRouter(router);

    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();
    expect(location, '/legal/privacy');
    expect(find.text('Legal privacy'), findsOneWidget);

    router.go('/settings/about');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Terms of Service'));
    await tester.pumpAndSettle();
    expect(location, '/legal/terms');
    expect(find.text('Legal terms'), findsOneWidget);
  });
}

Future<void> _noopDelete() async {}
