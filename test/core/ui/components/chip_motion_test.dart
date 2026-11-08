import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/motion/press_scale.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

import '../motion/preview_curves.dart';

// Item 17, demo 5: a chip shrinks to 96% under a press (120 ms down, 180 ms up,
// shared ease) and its fill fades over 150 ms on the ease. The web build had no
// press shrink at all.
final _theme = buildLightTheme();
final _webTheme = buildLightTheme(web: true);

Widget _chips({
  required int selected,
  bool web = false,
  bool reduced = false,
}) =>
    MaterialApp(
      theme: web ? _webTheme : _theme,
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: Scaffold(
          body: Row(
            children: [
              for (final (i, name) in ['All', 'Math', 'Language'].indexed)
                PantasButton.filterChip(
                  label: name,
                  selected: selected == i,
                  onPressed: () {},
                ),
            ],
          ),
        ),
      ),
    );

double _scale(WidgetTester tester, String label) => tester
    .widget<Transform>(
      find.descendant(
        of: find.ancestor(
          of: find.text(label),
          matching: find.byType(PressScale),
        ),
        matching: find.byType(Transform),
      ),
    )
    .transform
    .entry(0, 0);

Color _fill(WidgetTester tester, String label) => (tester
        .widget<DecoratedBox>(
          find.ancestor(
            of: find.text(label),
            matching: find.byKey(const ValueKey('chip-fill')),
          ),
        )
        .decoration as BoxDecoration)
    .color!;

Color _text(WidgetTester tester, String label) =>
    tester.widget<Text>(find.text(label)).style!.color!;

void main() {
  for (final web in [false, true]) {
    testWidgets('web=$web: a held chip shrinks to 96% in 120 ms',
        (tester) async {
      await tester.pumpWidget(_chips(selected: 0, web: web));
      expect(_scale(tester, 'Math'), 1);
      final press =
          await tester.startGesture(tester.getCenter(find.text('Math')));
      await tester.pump();
      var elapsed = 0;
      for (final ms in [30, 30, 30]) {
        await tester.pump(Duration(milliseconds: ms));
        elapsed += ms;
        expect(
          _scale(tester, 'Math'),
          closeTo(1 - .04 * previewShared(elapsed / 120), .0005),
          reason: '$elapsed ms',
        );
      }
      await tester.pump(const Duration(milliseconds: 30));
      expect(_scale(tester, 'Math'), closeTo(.96, .0001));
      expect(_scale(tester, 'All'), 1, reason: 'only the held chip');
      await press.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 90));
      expect(
        _scale(tester, 'Math'),
        closeTo(.96 + .04 * previewShared(.5), .0005),
        reason: 'back up over 180 ms',
      );
      await tester.pumpAndSettle();
      expect(_scale(tester, 'Math'), 1);
    });
  }

  testWidgets('the fill and the label color fade over 150 ms on the ease',
      (tester) async {
    await tester.pumpWidget(_chips(selected: 0));
    final off = _fill(tester, 'Math');
    final on = _fill(tester, 'All');
    final textOff = _text(tester, 'Math');
    final textOn = _text(tester, 'All');
    await tester.pumpWidget(_chips(selected: 1));
    await tester.pump();
    var elapsed = 0;
    for (final ms in [40, 40, 40]) {
      await tester.pump(Duration(milliseconds: ms));
      elapsed += ms;
      final p = previewEase(elapsed / 150);
      final fill = Color.lerp(off, on, p)!;
      expect(_fill(tester, 'Math').r, closeTo(fill.r, .02), reason: '$elapsed');
      final text = Color.lerp(textOff, textOn, p)!;
      expect(_text(tester, 'Math').r, closeTo(text.r, .02), reason: '$elapsed');
    }
    await tester.pump(const Duration(milliseconds: 40));
    expect(_fill(tester, 'Math'), on);
    expect(_text(tester, 'Math'), textOn);
    await tester.pumpAndSettle();
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('reduced motion: the fill is final in one frame, no shrink',
      (tester) async {
    await tester.pumpWidget(_chips(selected: 0, reduced: true));
    final on = _fill(tester, 'All');
    await tester.pumpWidget(_chips(selected: 1, reduced: true));
    await tester.pump();
    expect(_fill(tester, 'Math'), on);
    final press =
        await tester.startGesture(tester.getCenter(find.text('Math')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(PressScale), findsWidgets);
    expect(
      find.descendant(
        of: find.ancestor(
          of: find.text('Math'),
          matching: find.byType(PressScale),
        ),
        matching: find.byType(Transform),
      ),
      findsNothing,
    );
    await press.up();
    await tester.pumpAndSettle();
  });
}
