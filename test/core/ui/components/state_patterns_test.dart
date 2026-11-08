import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

import '../../../helpers/accessibility.dart';
import 'w2_test_support.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
        'primary state matches ST_NoExam and keeps keyboard access $brightness',
        (tester) async {
      var picks = 0;
      final state = StateView(
        message: 'Choose your exam',
        detail: 'Pick the exam you are reviewing for.',
        actionLabel: 'Choose Exam',
        primaryAction: true,
        icon: Icon(PantasIcons.studyTab),
        onRetry: () => picks++,
      );
      await pumpAccessibilitySurface(
        tester,
        state,
        viewportSize: const Size(390, 844),
        brightness: brightness,
        disableAnimations: true,
      );
      final title = tester.widget<Text>(find.text('Choose your exam'));
      // `.state`: the title is phone-title-3, the line phone-callout.
      expect(title.style!.fontSize, PantasType.phoneTitle3.fontSize);
      expect(title.style!.fontWeight, FontWeight.w700);
      expect(title.style!.height, PantasType.phoneTitle3.height);
      expect(title.style!.letterSpacing, PantasType.phoneTitle3.letterSpacing);
      final detail = tester
          .widget<Text>(find.text('Pick the exam you are reviewing for.'));
      expect(detail.style!.fontSize, PantasType.phoneCallout.fontSize);
      expect(detail.style!.fontWeight, FontWeight.w400);
      expect(detail.style!.height, PantasType.phoneCallout.height);
      expect(
        tester.getSize(find.byKey(const ValueKey('state-mark'))),
        const Size(40, 40),
      );
      // Gap 12 between the parts, and the action 8 lower.
      expect(
        tester.getTopLeft(find.text('Choose your exam')).dy -
            tester.getBottomLeft(find.byKey(const ValueKey('state-mark'))).dy,
        12,
      );
      expect(
        tester
                .getTopLeft(find.text('Pick the exam you are reviewing for.'))
                .dy -
            tester.getBottomLeft(find.text('Choose your exam')).dy,
        12,
      );
      expect(
        tester.getTopLeft(find.byType(PantasButton)).dy -
            tester
                .getBottomLeft(
                  find.text('Pick the exam you are reviewing for.'),
                )
                .dy,
        20,
      );
      final action = tester.widget<PantasButton>(find.byType(PantasButton));
      expect(action.variant, PantasButtonVariant.primary);
      // The action is 44 high and keeps its natural width.
      expect(action.height, PantasSize.btn);
      expect(action.radius, PantasRadius.full);
      expect(
        tester.getSize(find.byType(PantasButton)).width,
        lessThan(390 - 48),
      );
      final padding = tester
          .widget<Padding>(find.byKey(const ValueKey('state-primary-content')));
      expect(
        padding.padding,
        const EdgeInsets.fromLTRB(24, 0, 24, PantasLayout.reserveBar),
      );
      final mark = tester
          .widget<IconTheme>(find.byKey(const ValueKey('state-icon-theme')));
      final context = tester.element(find.byType(StateView));
      expect(mark.data.color, context.colors.iconMuted);
      expectContrast(title.style!.color!, context.colors.bgPage);
      expectContrast(detail.style!.color!, context.colors.bgPage);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(picks, 1);
      await expectSurvivesTextScale(
        tester,
        state,
        viewportSize: const Size(390, 844),
        brightness: brightness,
        disableAnimations: true,
      );
    });
  }
  testWidgets('a state without an action has no hidden focusable button',
      (tester) async {
    await pumpAccessibilitySurface(
      tester,
      const StateView(
        message: 'Empty',
        detail: 'No items.',
        primaryAction: true,
      ),
    );
    expect(find.byType(PantasButton), findsNothing);
    expect(find.byType(TextButton), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    expect(find.byType(PantasButton), findsNothing);
  });
}
