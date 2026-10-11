import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

import '../../../helpers/accessibility.dart';
import 'w2_test_support.dart';

void main() {
  setUpAll(() async {
    final fonts = FontLoader('Geist')
      ..addFont(rootBundle.load('assets/fonts/Geist-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Geist-Bold.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Geist-SemiBold.ttf'));
    await fonts.load();
  });
  for (final brightness in Brightness.values) {
    testWidgets(
        'full state matches SY_Error metrics and real backgrounds $brightness',
        (tester) async {
      final state =
          StateView.fullScreen(onRetry: () {}, error: Exception('private'));
      await pumpAccessibilitySurface(
        tester,
        state,
        brightness: brightness,
        viewportSize: const Size(390, 844),
        disableAnimations: true,
      );
      final circle = tester
          .widget<Container>(find.byKey(const ValueKey('state-mark-circle')));
      final fill = (circle.decoration! as BoxDecoration).color!;
      final context = tester.element(find.byType(StateView));
      expect(
        tester.getSize(find.byKey(const ValueKey('state-mark-circle'))),
        const Size(72, 72),
      );
      expect(fill, context.colors.fill);
      final mark = tester
          .widget<IconTheme>(find.byKey(const ValueKey('state-icon-theme')));
      expect(mark.data.size, 36);
      expect(mark.data.color, context.colors.secondaryLabel);
      final icon = tester.widget<Icon>(
        find.descendant(
          of: find.byKey(const ValueKey('state-mark')),
          matching: find.byType(Icon),
        ),
      );
      expect(icon.icon!.codePoint, 0xe4e2);
      expect(icon.icon!.fontFamily, 'Phosphor');
      final title = tester.widget<Text>(find.text('Something went wrong.'));
      final detail =
          tester.widget<Text>(find.text("Nothing you've done is lost."));
      expect(title.style!.fontSize, 24);
      expect(title.style!.fontWeight, FontWeight.w700);
      expect(title.style!.height, 1.25);
      expect(title.style!.letterSpacing, -.288);
      expect(detail.style!.fontSize, 16);
      expect(detail.style!.fontWeight, FontWeight.w400);
      expect(detail.style!.height, 1.45);
      expect(
        tester.getTopLeft(find.text('Something went wrong.')).dy -
            tester
                .getBottomLeft(
                  find.byKey(const ValueKey('state-mark-circle')),
                )
                .dy,
        14,
      );
      expect(
        tester.getTopLeft(find.text("Nothing you've done is lost.")).dy -
            tester.getBottomLeft(find.text('Something went wrong.')).dy,
        14,
      );
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('state-mark-circle'))).dy,
        closeTo(289.4, 1),
      );
      expect(tester.getSize(find.byType(PantasButton)), const Size(358, 52));
      expect(
        tester.getTopLeft(find.byType(PantasButton)),
        const Offset(16, 762),
      );
      expect(find.byType(BottomNavigationBar), findsNothing);
      expect(
        tester
            .widget<Scaffold>(
              find.descendant(
                of: find.byType(StateView),
                matching: find.byType(Scaffold),
              ),
            )
            .bottomNavigationBar,
        isNull,
      );
      final button = tester.widget<TextButton>(find.byType(TextButton));
      final background = tester
          .widget<Scaffold>(
            find.descendant(
              of: find.byType(StateView),
              matching: find.byType(Scaffold),
            ),
          )
          .backgroundColor!;
      expectContrast(title.style!.color!, background);
      expectContrast(detail.style!.color!, background);
      expectContrast(
        tester.widget<Text>(find.text('Try Again')).style!.color!,
        button.style!.backgroundColor!.resolve({})!,
      );
      expect(find.textContaining('private'), findsNothing);
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && (w.properties.liveRegion ?? false),
        ),
        findsWidgets,
      );
      await expectSurvivesTextScale(
        tester,
        state,
        brightness: brightness,
        viewportSize: const Size(390, 844),
        disableAnimations: true,
      );
    });
  }
}
