import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/guardian/application/guardian_providers.dart';
import 'package:pantas/features/onboarding/presentation/child/under_thirteen_screen.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_age_gate_step.dart';

import '../../../../helpers/in_memory_database.dart';
import '../../../guardian/fake_guardian_gateway.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = inMemoryDatabase());
  tearDown(() => db.close());

  Future<GoRouter> pump(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => OnboardingAgeGateStep(onAgeGatePassed: () {}),
        ),
        GoRoute(
          path: underThirteenPath,
          builder: (_, __) => const Text('guardian screen'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          guardianGatewayProvider.overrideWithValue(FakeGuardianGateway()),
        ],
        child: MaterialApp.router(
          theme: buildLightTheme(web: false),
          routerConfig: router,
        ),
      ),
    );
    return router;
  }

  testWidgets('a stored under-13 block opens the guardian screen',
      (tester) async {
    await AppPreferencesRepository(db).setBlockedMinimumAge(13);
    await pump(tester);
    await tester.pumpAndSettle();
    expect(find.text('guardian screen'), findsOneWidget);
  });

  testWidgets('an age of 12 opens the guardian screen', (tester) async {
    await pump(tester);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '12');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('guardian screen'), findsOneWidget);
    expect(await AppPreferencesRepository(db).blockedMinimumAge(), 13);
  });
}
