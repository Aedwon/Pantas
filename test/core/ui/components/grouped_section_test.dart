import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';

import '../../../helpers/accessibility.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('group metrics and external footer in $brightness',
        (tester) async {
      const widget = GroupedSection(
        header: 'Session length',
        footer: 'How many questions in one quiz session.',
        children: [SizedBox(height: 44, child: Text('10 questions'))],
      );
      await pumpAccessibilitySurface(tester, widget, brightness: brightness);
      final group = find.byKey(const ValueKey('grouped-section-surface'));
      final decoration =
          tester.widget<DecoratedBox>(group).decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(14));
      expect(
        decoration.color,
        brightness == Brightness.light
            ? const Color(0xFFFFFFFF)
            : const Color(0xFF1C1C1E),
      );
      expect(
        find.descendant(
          of: group,
          matching: find.text('How many questions in one quiz session.'),
        ),
        findsNothing,
      );
      expect(
        tester
                .getTopLeft(
                  find.text('How many questions in one quiz session.'),
                )
                .dy -
            tester.getBottomLeft(group).dy,
        7,
      );
      final header = tester.widget<Text>(find.text('SESSION LENGTH'));
      expect(header.style!.fontSize, 13);
      expect(header.style!.fontWeight, FontWeight.w600);
      expect(header.style!.letterSpacing, .26);
      expect(header.style!.height, 1.35);
      final footer = tester
          .widget<Text>(find.text('How many questions in one quiz session.'));
      expect(footer.style!.fontSize, 13);
      expect(footer.style!.height, 1.4);
      final background = brightness == Brightness.light
          ? const Color(0xFFF5F5F7)
          : const Color(0xFF000000);
      final luminances = [
        header.style!.color!.computeLuminance(),
        background.computeLuminance(),
      ]..sort();
      expect(
        (luminances.last + .05) / (luminances.first + .05),
        greaterThanOrEqualTo(4.5),
      );
      await expectSurvivesTextScale(
        tester,
        widget,
        viewportSize: const Size(390, 844),
        brightness: brightness,
        disableAnimations: true,
      );
    });
    testWidgets('group omits optional header and footer in $brightness',
        (tester) async {
      await pumpAccessibilitySurface(
        tester,
        const GroupedSection(children: [Text('Practice')]),
        brightness: brightness,
      );
      expect(find.byType(Text), findsOneWidget);
    });
  }
}
