import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';

import '../motion/preview_curves.dart';

// Item 17, demo 4: a row's tint and value color fade together over 160 ms on
// the ease. Nothing moves and the label keeps its weight.
final _theme = buildLightTheme(web: true);

Widget _row({
  required bool selected,
  bool reduced = false,
  bool? enterFrom,
}) =>
    MaterialApp(
      theme: _theme,
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: Scaffold(
          body: SizedBox(
            width: 400,
            child: WebRow(
              title: 'Practice',
              value: '10 questions',
              selected: selected,
              enterFromSelected: enterFrom,
              selectedValueColor: const Color(0xFF0B7A68),
              onPressed: () {},
            ),
          ),
        ),
      ),
    );

double _tint(WidgetTester tester) => tester
    .widget<ColoredBox>(
      find.descendant(
        of: find.descendant(
          of: find.byType(WebRow),
          matching: find.byType(IgnorePointer),
        ),
        matching: find.byType(ColoredBox),
      ),
    )
    .color
    .a;

Color? _value(WidgetTester tester) =>
    tester.widget<Text>(find.text('10 questions')).style?.color;

void main() {
  testWidgets('choosing the row fades the tint in over 160 ms', (tester) async {
    await tester.pumpWidget(_row(selected: false));
    final base = _value(tester)!;
    await tester.pumpWidget(_row(selected: true));
    await tester.pump();
    var elapsed = 0;
    for (final ms in [40, 40, 40]) {
      await tester.pump(Duration(milliseconds: ms));
      elapsed += ms;
      final p = previewEase(elapsed / 160);
      expect(_tint(tester), closeTo(p, .01), reason: '$elapsed ms');
      final want = Color.lerp(base, const Color(0xFF0B7A68), p)!;
      expect(_value(tester)!.g, closeTo(want.g, .01), reason: '$elapsed ms');
    }
    await tester.pump(const Duration(milliseconds: 40));
    expect(_tint(tester), 1);
    expect(_value(tester), const Color(0xFF0B7A68));
    await tester.pumpAndSettle();
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('leaving the row fades the tint out', (tester) async {
    await tester.pumpWidget(_row(selected: true));
    expect(_tint(tester), 1);
    await tester.pumpWidget(_row(selected: false));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    expect(_tint(tester), closeTo(1 - previewEase(.5), .01));
    await tester.pumpAndSettle();
    expect(_tint(tester), 0);
  });

  testWidgets('a row built after the choice fades from the earlier one',
      (tester) async {
    await tester.pumpWidget(_row(selected: false, enterFrom: true));
    expect(_tint(tester), 1);
    await tester.pump(const Duration(milliseconds: 80));
    expect(_tint(tester), closeTo(1 - previewEase(.5), .01));
    await tester.pumpAndSettle();
    expect(_tint(tester), 0);
  });

  testWidgets('a row that starts selected is tinted at once', (tester) async {
    await tester.pumpWidget(_row(selected: true));
    expect(_tint(tester), 1);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('reduced motion shows the final tint in one frame',
      (tester) async {
    await tester.pumpWidget(_row(selected: false, reduced: true));
    await tester.pumpWidget(_row(selected: true, reduced: true));
    await tester.pump();
    expect(_tint(tester), 1);
    expect(_value(tester), const Color(0xFF0B7A68));
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('a row that is never selected carries no tint layer',
      (tester) async {
    await tester.pumpWidget(_row(selected: false));
    // The keyboard ring has its own IgnorePointer layer; the tint is a
    // ColoredBox.
    expect(
      find.descendant(
        of: find.descendant(
          of: find.byType(WebRow),
          matching: find.byType(IgnorePointer),
        ),
        matching: find.byType(ColoredBox),
      ),
      findsNothing,
    );
  });

  testWidgets('the first selection flip keeps the focused button',
      (tester) async {
    await tester.pumpWidget(_row(selected: false));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    final focused = FocusManager.instance.primaryFocus;
    final button = tester.element(find.byType(TextButton));
    expect(focused, isNotNull);

    await tester.pumpWidget(_row(selected: true));
    await tester.pump();
    expect(FocusManager.instance.primaryFocus, same(focused));
    expect(focused!.hasPrimaryFocus, isTrue);
    expect(
      identical(tester.element(find.byType(TextButton)), button),
      isTrue,
      reason: 'the button was rebuilt as a new element',
    );
    await tester.pumpAndSettle();
    expect(FocusManager.instance.primaryFocus, same(focused));
  });
}
