import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/auth/auth.dart';
import 'package:pantas/core/storage/age_gate.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/settings/presentation/pages/account_page.dart';

import '../../../helpers/in_memory_database.dart';

const _reader = AuthUser(
  uid: 'user-1',
  email: 'reader@example.com',
  displayName: 'Reader',
);

void main() {
  testWidgets('Sign Out returns to the first onboarding page, Welcome',
      (tester) async {
    final harness = await _signedInStudent(tester, ageGroup: 'minor');

    await _signOut(tester);

    expect(harness.location(), '/onboarding');
    expect(find.text('onboarding'), findsOneWidget);
    final preferences = harness.preferences;
    expect(await preferences.hasCompletedOnboarding(), isFalse);
    expect(await preferences.hasPassedAgeGate(), isFalse);
    // A stale minor answer would open the guardian step before Welcome.
    expect(await preferences.ageGroup(), isNull);
    expect(await harness.container.read(passedAgeGateProvider.future), isFalse);
    expect(
      await harness.container.read(onboardingCompleteProvider.future),
      isFalse,
    );
  });

  testWidgets('Sign Out keeps the minimum-age block', (tester) async {
    final harness = await _signedInStudent(tester);
    await harness.preferences.setBlockedMinimumAge(13);

    await _signOut(tester);

    expect(await harness.preferences.blockedMinimumAge(), 13);
  });

  testWidgets('a failed Sign Out changes nothing', (tester) async {
    final harness = await _signedInStudent(tester, failSignOut: true);

    await _signOut(tester);

    expect(harness.location(), '/');
    expect(await harness.preferences.hasCompletedOnboarding(), isTrue);
    expect(await harness.preferences.hasPassedAgeGate(), isTrue);
  });
}

Future<void> _signOut(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Sign Out'));
  await tester.tap(find.text('Sign Out'));
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(
      of: find.byType(CenteredDialog),
      matching: find.widgetWithText(PantasButton, 'Sign Out'),
    ),
  );
  await tester.pumpAndSettle();
}

class _Harness {
  _Harness(this.preferences, this.container, this.router);

  final AppPreferencesRepository preferences;
  final ProviderContainer container;
  final GoRouter router;

  String location() =>
      router.routerDelegate.currentConfiguration.last.matchedLocation;
}

Future<_Harness> _signedInStudent(
  WidgetTester tester, {
  String? ageGroup,
  bool failSignOut = false,
}) async {
  final db = inMemoryDatabase();
  addTearDown(db.close);
  final preferences = AppPreferencesRepository(db);
  await preferences.setPassedAgeGate(value: true);
  await preferences.setCompletedOnboarding(value: true);
  if (ageGroup != null) await preferences.setAgeGroup(ageGroup);
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, __) => const AccountPage()),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const Text('onboarding'),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        currentUserProvider.overrideWith((ref) => _reader),
        authRepositoryProvider.overrideWithValue(_Auth(fail: failSignOut)),
      ],
      child: MaterialApp.router(
        theme: buildLightTheme(),
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
  final container = ProviderScope.containerOf(
    tester.element(find.byType(AccountPage)),
  );
  return _Harness(preferences, container, router);
}

class _Auth implements AuthRepository {
  _Auth({required this.fail});

  final bool fail;

  @override
  Future<void> signOut() async {
    if (fail) throw const AuthGatewayException('network-request-failed');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
