import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/placeholder_figure.dart';

import '../../../helpers/accessibility.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
        'placeholder keeps the value and hides developer reason in $brightness',
        (tester) async {
      const widget =
          PlaceholderFigure(27, reason: 'A published source is required.');
      await pumpAccessibilitySurface(
        tester,
        widget,
        brightness: brightness,
        disableAnimations: true,
      );
      expect(find.text('27'), findsOneWidget);
      expect(find.text('A published source is required.'), findsNothing);
      await expectSurvivesTextScale(
        tester,
        widget,
        viewportSize: const Size(390, 844),
        brightness: brightness,
        disableAnimations: true,
      );
    });
  }
  test('a placeholder must carry its reason', () {
    final emptyReason = StringBuffer().toString();
    expect(
      () => PlaceholderFigure(27, reason: emptyReason),
      throwsAssertionError,
    );
  });
}
