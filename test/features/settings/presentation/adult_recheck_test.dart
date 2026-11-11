import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/guardian/application/guardian_providers.dart';
import 'package:pantas/features/onboarding/presentation/adult_recheck_page.dart';
import 'package:pantas/features/settings/presentation/pages/account_page.dart';

import '../../../helpers/in_memory_database.dart';
import '../../guardian/fake_guardian_gateway.dart';

void main() {
  late AppDatabase db;
  late FakeGuardianGateway gateway;
  setUp(() {
    db = inMemoryDatabase();
    gateway = FakeGuardianGateway();
  });
  tearDown(() => db.close());

  Future<void> pump(WidgetTester tester, {String? ageGroup}) async {
    if (ageGroup != null) {
      await AppPreferencesRepository(db).setAgeGroup(ageGroup);
    }
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, __) => const AccountPage()),
        GoRoute(
          path: '/settings/account/adult-check',
          builder: (_, __) => const AdultRecheckPage(),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          guardianGatewayProvider.overrideWithValue(gateway),
          currentUserProvider.overrideWith((ref) async => null),
        ],
        child: MaterialApp.router(
          theme: buildLightTheme(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> enterAgeAndContinue(WidgetTester tester, String age) async {
    await tester.enterText(find.byType(TextField), age);
    await tester.pump();
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
  }

  testWidgets("the I'm 18 now row shows only for a minor", (tester) async {
    await pump(tester, ageGroup: 'adult');
    expect(find.text("I'm 18 now"), findsNothing);
  });

  testWidgets("no age group on the device shows no I'm 18 now row",
      (tester) async {
    await pump(tester);
    expect(find.text("I'm 18 now"), findsNothing);
  });

  testWidgets('a minor sees the row', (tester) async {
    await pump(tester, ageGroup: 'minor');
    expect(find.text("I'm 18 now"), findsOneWidget);
  });

  testWidgets(
      'an adult age calls the callable, switches, and Settings '
      'shows the toast', (tester) async {
    await pump(tester, ageGroup: 'minor');
    await tester.tap(find.text("I'm 18 now"));
    await tester.pumpAndSettle();
    expect(find.text('How old are you?'), findsOneWidget);

    await enterAgeAndContinue(tester, '30');

    expect(gateway.adultCalls, 1);
    expect(await AppPreferencesRepository(db).ageGroup(), 'adult');
    expect(find.text('How old are you?'), findsNothing);
    expect(
      find.text('Your account is now set for 18 and over.'),
      findsOneWidget,
    );
    expect(find.text("I'm 18 now"), findsNothing);
  });

  testWidgets('under 18 changes nothing and the row stays', (tester) async {
    await pump(tester, ageGroup: 'minor');
    await tester.tap(find.text("I'm 18 now"));
    await tester.pumpAndSettle();

    await enterAgeAndContinue(tester, '15');

    expect(find.text('You are still under 18.'), findsOneWidget);
    expect(gateway.adultCalls, 0);
    expect(await AppPreferencesRepository(db).ageGroup(), 'minor');
    expect(find.text('Your account is now set for 18 and over.'), findsNothing);
  });
}
