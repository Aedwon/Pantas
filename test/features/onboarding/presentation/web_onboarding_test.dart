import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_age_gate_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_welcome_step.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  for (final dark in [false, true]) {
    testWidgets('wide welcome and keyboard $dark', (tester) async {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var advances = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
          home: Scaffold(
            body: OnboardingWelcomeStep(onAdvance: () => advances++),
          ),
        ),
      );
      expect(find.text('Enter'), findsOneWidget);
      expect(
        tester.getSize(find.widgetWithText(TextButton, 'Get Started')).width,
        lessThan(400),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(advances, 1);
    });
    testWidgets('wide age input and blocked state $dark', (tester) async {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = inMemoryDatabase();
      addTearDown(db.close);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: MaterialApp(
            theme:
                dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
            home: Scaffold(
              body: OnboardingAgeGateStep(
                currentYear: 2026,
                onAgeGatePassed: () {},
              ),
            ),
          ),
        ),
      );
      expect(find.bySemanticsLabel('Setup steps'), findsOneWidget);
      expect(find.text('YEAR'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '2020');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text("Pantas isn't available yet"), findsOneWidget);
      await tester.tap(find.text('Try a Different Year'));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
