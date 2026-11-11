import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/check_mark.dart';

import '../../../helpers/accessibility.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('check size and real icon contrast in $brightness',
        (tester) async {
      await pumpAccessibilitySurface(
        tester,
        const CheckMark(),
        brightness: brightness,
        disableAnimations: true,
      );
      final mark = find.byKey(const ValueKey('check-mark-circle'));
      expect(tester.getSize(mark), const Size(24, 24));
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.size, 14);
      final decoration =
          tester.widget<DecoratedBox>(mark).decoration as BoxDecoration;
      final luminances = [
        decoration.color!.computeLuminance(),
        icon.color!.computeLuminance(),
      ]..sort();
      expect(
        (luminances.last + .05) / (luminances.first + .05),
        greaterThanOrEqualTo(4.5),
      );
      await expectSurvivesTextScale(
        tester,
        const CheckMark(),
        brightness: brightness,
        disableAnimations: true,
      );
    });
    testWidgets('check uses the day board pop at 210ms in $brightness',
        (tester) async {
      await pumpAccessibilitySurface(
        tester,
        const CheckMark(),
        brightness: brightness,
      );
      await tester.pump(const Duration(milliseconds: 210));
      final transform = tester
          .widget<Transform>(find.byKey(const ValueKey('check-mark-scale')));
      expect(transform.transform.entry(0, 0), closeTo(1.05244, .002));
      await tester.pump(const Duration(milliseconds: 210));
      expect(
        tester
            .widget<Transform>(find.byKey(const ValueKey('check-mark-scale')))
            .transform
            .entry(0, 0),
        1,
      );
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });
  }
}
