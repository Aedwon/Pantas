import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/routes/settings_routes.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/legal/legal.dart';
import 'package:pantas/features/onboarding/application/onboarding_flow.dart';
import 'package:pantas/features/settings/presentation/pages/delete_account_page.dart';
import 'package:pantas/features/settings/settings.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

final _settingsRoutes = Provider(settingsRoutes);
void main() {
  testWidgets(
      'successful anonymous deletion returns to Welcome and clears completion',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final prefs = AppPreferencesRepository(db);
    await prefs.setCompletedOnboarding(value: true);
    await prefs.setPassedAgeGate(value: true);
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        isAnonymousProvider.overrideWith((ref) async => true),
      ],
    );
    addTearDown(container.dispose);
    await container.read(isAnonymousProvider.future);
    expect(
      (await container.read(onboardingProgressProvider.future)).agePassed,
      isTrue,
    );
    final router = GoRouter(
      initialLocation: '/settings/account/delete',
      routes: [
        ...container.read(_settingsRoutes),
        GoRoute(path: '/onboarding', builder: (_, __) => const Text('Welcome')),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: buildLightTheme(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete My Data'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome'), findsOneWidget);
    expect(await prefs.hasCompletedOnboarding(), isFalse);
    expect(
      (await container.read(onboardingProgressProvider.future)).resumeStep,
      OnboardingStep.welcome,
    );
  });
  test('named delete cancels notifications before AuthRepository.deleteAccount',
      () async {
    final log = <String>[];

    await deleteAccountFromSettings(
      isAnonymous: false,
      cancelNotifications: () async => log.add('cancelAll'),
      deleteNamedAccount: () async => log.add('deleteAccount'),
      wipeAnonymousData: () async => log.add('wipeAnonymousData'),
    );

    expect(log, ['cancelAll', 'deleteAccount']);
  });

  test('anonymous delete cancels notifications before local wipe', () async {
    final log = <String>[];

    await deleteAccountFromSettings(
      isAnonymous: true,
      cancelNotifications: () async => log.add('cancelAll'),
      deleteNamedAccount: () async => log.add('deleteAccount'),
      wipeAnonymousData: () async => log.add('wipeAnonymousData'),
    );

    expect(log, ['cancelAll', 'wipeAnonymousData']);
    expect(log, isNot(contains('deleteAccount')));
  });

  testWidgets('delete confirmation shows the approved consequences and choices',
      (tester) async {
    await tester.pumpAppWithProviders(
      DeleteAccountPage(
        isAnonymous: false,
        entitlement: const SettingsEntitlementSnapshot.free(),
        dpoEmail: defaultLegalContact.dpoEmail,
        onDelete: () async {},
      ),
    );
    expect(find.text('Your account is removed.'), findsOneWidget);
    expect(find.text('Anything backed up to it is erased.'), findsOneWidget);
    expect(find.text('Progress on this phone is erased too.'), findsOneWidget);
    expect(find.text('Delete My Data'), findsOneWidget);
    expect(find.text('Keep My Account'), findsOneWidget);
    expect(find.byType(AppBar), findsNothing);
  });

  testWidgets('delete button shows loading while request is in flight',
      (tester) async {
    final completer = Completer<void>();

    await tester.pumpAppWithProviders(
      DeleteAccountPage(
        isAnonymous: false,
        entitlement: const SettingsEntitlementSnapshot.free(),
        dpoEmail: defaultLegalContact.dpoEmail,
        onDelete: () => completer.future,
      ),
    );

    await tester.tap(find.text('Delete My Data'));
    await tester.pump();

    expect(find.text('Deleting...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('delete failure shows retry and DPO fallback', (tester) async {
    await tester.pumpAppWithProviders(
      DeleteAccountPage(
        isAnonymous: false,
        entitlement: const SettingsEntitlementSnapshot.free(),
        dpoEmail: defaultLegalContact.dpoEmail,
        onDelete: () async => throw StateError('backend unavailable'),
      ),
    );

    await tester.tap(find.text('Delete My Data'));
    await tester.pumpAndSettle();

    expect(find.text('Try again'), findsOneWidget);
    final status = find.bySemanticsLabel(
      RegExp(defaultLegalContact.dpoEmail),
    );
    expect(status, findsOneWidget);
    expect(
      tester.getSemantics(status).flagsCollection.isLiveRegion,
      isTrue,
    );
  });

  testWidgets('delete success becomes a live status', (tester) async {
    await tester.pumpAppWithProviders(
      DeleteAccountPage(
        isAnonymous: false,
        entitlement: const SettingsEntitlementSnapshot.free(),
        dpoEmail: defaultLegalContact.dpoEmail,
        onDelete: () async {},
      ),
    );

    await tester.tap(find.text('Delete My Data'));
    await tester.pumpAndSettle();

    final status = find.bySemanticsLabel('Deletion request completed.');
    expect(status, findsOneWidget);
    expect(
      tester.getSemantics(status).flagsCollection.isLiveRegion,
      isTrue,
    );
  });
}
