import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_consent_step.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = inMemoryDatabase();
  });

  tearDown(() => db.close());

  Future<void> pumpStep(
    WidgetTester tester, {
    VoidCallback? onCompleted,
    List<String>? pushedRoutes,
  }) async {
    final router = GoRouter(
      initialLocation: '/onboarding',
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => Scaffold(
            body: OnboardingConsentStep(
              onCompleted: onCompleted ?? () {},
            ),
          ),
        ),
        GoRoute(
          path: '/legal/terms',
          builder: (context, state) {
            pushedRoutes?.add('/legal/terms');
            return const Scaffold(body: Text('Terms Page'));
          },
        ),
        GoRoute(
          path: '/legal/privacy',
          builder: (context, state) {
            pushedRoutes?.add('/legal/privacy');
            return const Scaffold(body: Text('Privacy Page'));
          },
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          settingsRepositoryProvider.overrideWithValue(
            DriftSettingsRepository(db),
          ),
        ],
        child: MaterialApp.router(
          theme: buildLightTheme(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Continue is disabled initially and usage tick starts off',
      (tester) async {
    await pumpStep(tester);

    expect(find.text('Terms & Privacy'), findsOneWidget);
    final cont = tester
        .widget<BoardButton>(find.widgetWithText(BoardButton, 'Continue'));
    expect(cont.onPressed, isNull);
  });

  testWidgets('the terms tick alone enables Continue, and usage stays false',
      (tester) async {
    var completed = false;
    await pumpStep(tester, onCompleted: () => completed = true);

    await tester.tap(find.text('I agree to the '));
    await tester.pumpAndSettle();

    final cont = tester
        .widget<BoardButton>(find.widgetWithText(BoardButton, 'Continue'));
    expect(cont.onPressed, isNotNull);

    await tester.tap(find.widgetWithText(BoardButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(completed, isTrue);
    final settings = await DriftSettingsRepository(db).readUserSettings();
    expect(settings.acceptedTermsAt, isNotNull);
    expect(settings.helpImproveApp, isFalse);
  });

  testWidgets('turning usage tick on writes true for helpImproveApp',
      (tester) async {
    var completed = false;
    await pumpStep(tester, onCompleted: () => completed = true);

    await tester.tap(find.text('I agree to the '));
    await tester.pumpAndSettle();

    await tester.tap(
      find.text('Help improve Pantas by sharing anonymous usage data'),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(BoardButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(completed, isTrue);
    final settings = await DriftSettingsRepository(db).readUserSettings();
    expect(settings.acceptedTermsAt, isNotNull);
    expect(settings.helpImproveApp, isTrue);
  });

  testWidgets('tapping document titles navigates to legal routes',
      (tester) async {
    final pushed = <String>[];
    await pumpStep(tester, pushedRoutes: pushed);

    await tester.tap(find.text('Terms of Service'));
    await tester.pumpAndSettle();
    expect(pushed, contains('/legal/terms'));

    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();
    expect(pushed, contains('/legal/privacy'));
  });
}
