import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/onboarding/presentation/onboarding_welcome_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders headline, subtitle, and Get started CTA',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
          theme: buildLightTheme(),
        home: Scaffold(
          body: OnboardingWelcomeStep(onAdvance: () {}),
        ),
      ),
    );

    expect(find.text('Build your study plan'), findsOneWidget);
    expect(
      find.text("Pick your exam — we'll guide what to study first."),
      findsOneWidget,
    );
    expect(find.text('Get started'), findsOneWidget);
  });

  testWidgets('tapping Get started invokes onAdvance', (tester) async {
    var advanced = 0;
    await tester.pumpWidget(
      MaterialApp(
          theme: buildLightTheme(),
        home: Scaffold(
          body: OnboardingWelcomeStep(onAdvance: () => advanced++),
        ),
      ),
    );

    await tester.tap(find.text('Get started'));
    await tester.pump();

    expect(advanced, equals(1));
  });
}
