import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

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
      expect(title.style!.fontSize, 20);
      expect(title.style!.fontWeight, FontWeight.w700);
      expect(title.style!.height, 1.35);
      expect(title.style!.letterSpacing, -.2);
      final detail = tester
          .widget<Text>(find.text('Pick the exam you are reviewing for.'));
      expect(detail.style!.fontSize, 15);
      expect(detail.style!.fontWeight, FontWeight.w400);
      expect(detail.style!.height, 1.45);
      expect(
        tester.getSize(find.byKey(const ValueKey('state-mark'))),
        const Size(40, 40),
      );
      expect(
        tester.getTopLeft(find.text('Choose your exam')).dy -
            tester.getBottomLeft(find.byKey(const ValueKey('state-mark'))).dy,
        6,
      );
      expect(
        tester
                .getTopLeft(find.text('Pick the exam you are reviewing for.'))
                .dy -
            tester.getBottomLeft(find.text('Choose your exam')).dy,
        6,
      );
      expect(
        tester.getTopLeft(find.byType(PantasButton)).dy -
            tester
                .getBottomLeft(
                  find.text('Pick the exam you are reviewing for.'),
                )
                .dy,
        6,
      );
      final action = tester.widget<PantasButton>(find.byType(PantasButton));
      expect(action.variant, PantasButtonVariant.primary);
      expect(action.height, 48);
      expect(tester.getSize(find.byType(PantasButton)).height, 48);
      expect(action.radius, 14);
      final button = tester.widget<TextButton>(find.byType(TextButton));
      expect(button.style!.padding!.resolve({})!.horizontal, 52);
      expect(
        tester.getSize(find.byType(PantasButton)).width,
        closeTo(tester.getSize(find.text('Choose Exam')).width + 52, .01),
      );
      final padding = tester
          .widget<Padding>(find.byKey(const ValueKey('state-primary-content')));
      expect(padding.padding, const EdgeInsets.fromLTRB(36, 0, 36, 150));
      final mark = tester
          .widget<IconTheme>(find.byKey(const ValueKey('state-icon-theme')));
      final context = tester.element(find.byType(StateView));
      expect(mark.data.color, context.colors.chevron);
      expectContrast(title.style!.color!, context.colors.background);
      expectContrast(detail.style!.color!, context.colors.background);
      expectContrast(
        tester.widget<Text>(find.text('Choose Exam')).style!.color!,
        button.style!.backgroundColor!.resolve({})!,
      );
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
