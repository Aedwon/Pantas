import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_welcome_step.dart';

import '../../../helpers/accessibility.dart';

void main() {
  testWidgets('launch follows O_Launch at 150, 510 and 750 milliseconds',
      (tester) async {
    var completed = 0;
    await pumpAccessibilitySurface(
      tester,
      OnboardingLaunchStep(onCompleted: () => completed++),
      viewportSize: const Size(390, 844),
    );
    double scale() => tester
        .widget<Transform>(find.byKey(const ValueKey('launch-logo-scale')))
        .transform
        .storage[0];
    double opacity() => tester
        .widget<Opacity>(find.byKey(const ValueKey('launch-logo-opacity')))
        .opacity;
    expect(
      tester.getSize(find.byKey(const ValueKey('launch-logo'))),
      const Size(120, 120),
    );
    expect(find.byType(PantasButton), findsNothing);
    await tester.pump(const Duration(milliseconds: 150));
    expect(scale(), .4);
    expect(
      tester
          .widget<Opacity>(find.byKey(const ValueKey('launch-page-fade')))
          .opacity,
      closeTo(.802403, .001),
    );
    expect(opacity(), 0);
    expect(completed, 0);
    await tester.pump(const Duration(milliseconds: 180));
    expect(scale(), closeTo(1.182928, .001));
    await tester.pump(const Duration(milliseconds: 180));
    expect(scale(), closeTo(1.12, .0001));
    expect(opacity(), 1);
    expect(completed, 0);
    await tester.pump(const Duration(milliseconds: 240));
    expect(scale(), 1);
    expect(opacity(), 1);
    expect(completed, 1);
  });

  testWidgets('reduce motion shows the final frame without a delay',
      (tester) async {
    var completed = 0;
    await pumpAccessibilitySurface(
      tester,
      OnboardingLaunchStep(onCompleted: () => completed++),
      viewportSize: const Size(390, 844),
      disableAnimations: true,
    );
    expect(
      tester
          .widget<Transform>(find.byKey(const ValueKey('launch-logo-scale')))
          .transform
          .storage[0],
      1,
    );
    expect(completed, 1);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });
}
