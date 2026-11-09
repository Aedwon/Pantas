import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_welcome_step.dart';

import '../../../helpers/accessibility.dart';

void main() {
  for (final brightness in Brightness.values) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('Welcome has board type and spacing at $brightness $scale',
          (tester) async {
        await pumpAccessibilitySurface(
          tester,
          OnboardingWelcomeStep(onAdvance: () {}),
          viewportSize: const Size(390, 844),
          textScale: scale,
          brightness: brightness,
          disableAnimations: true,
        );
        expect(find.text('Welcome to Pantas'), findsOneWidget);
        expect(
          find.text('Your personal review companion\nfor Philippine exams.'),
          findsOneWidget,
        );
        final title = tester.widget<Text>(find.text('Welcome to Pantas'));
        // D180: the large title steps down to title 2 under 12rem.
        expect(title.style!.fontSize, scale > 1.5 ? 22 : 34);
        expect(title.style!.fontWeight, FontWeight.w700);
        expect(title.style!.height, scale > 1.5 ? 1.35 : 1.12);
        expect(title.style!.letterSpacing, scale > 1.5 ? -.264 : -.748);
        final subtitle = tester.widget<Text>(
          find.text('Your personal review companion\nfor Philippine exams.'),
        );
        expect(subtitle.style!.fontSize, 17);
        expect(subtitle.style!.height, 1.45);
        expect(tester.takeException(), isNull);
        final start = find.byType(PantasButton);
        expect(start, findsOneWidget);
        expect(tester.getSize(start).width, 350);
        expect(tester.getSize(start).height, greaterThanOrEqualTo(52));
        await expectMeetsAccessibilityGuidelines(tester);
      });
    }
  }
  testWidgets('Get Started is keyboard reachable and starts the flow once',
      (tester) async {
    var advanced = 0;
    await pumpAccessibilitySurface(
      tester,
      OnboardingWelcomeStep(onAdvance: () => advanced++),
      viewportSize: const Size(390, 844),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(advanced, 1);
  });
  testWidgets('wide Get Started is 260 px, like the HTML Welcome (7W-1)',
      (tester) async {
    debugWebPlatformOverride = true;
    addTearDown(() => debugWebPlatformOverride = null);
    await pumpAccessibilitySurface(
      tester,
      OnboardingWelcomeStep(onAdvance: () {}),
      viewportSize: const Size(1440, 900),
      disableAnimations: true,
    );
    expect(tester.getSize(find.byType(WebButton)).width, 260);
    expect(tester.takeException(), isNull);
  });
  for (final width in [600.0, 768.0, 900.0, 1023.0]) {
    testWidgets('Get Started stays in the 640 column at $width px (2E-11)',
        (tester) async {
      await pumpAccessibilitySurface(
        tester,
        OnboardingWelcomeStep(onAdvance: () {}),
        viewportSize: Size(width, 900),
        disableAnimations: true,
      );
      final start = find.byType(PantasButton);
      expect(tester.getSize(start).width, width < 640 ? width - 40 : 600);
      expect(tester.getCenter(start).dx, closeTo(width / 2, .01));
    });
  }
}
