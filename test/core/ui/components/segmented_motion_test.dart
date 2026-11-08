import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/segmented_switch.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/web/web_components.dart';

import '../motion/preview_curves.dart';

// Item 17, demo 7: one thumb slides under the labels, 240 ms on the shared
// ease, and the label color fades over 160 ms on the ease.
final _theme = buildLightTheme();
final _webTheme = buildLightTheme(web: true);

Widget _phone(int selected, {bool reduced = false}) => MaterialApp(
      theme: _theme,
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: Scaffold(
          body: Center(
            child: SizedBox(
              width: 330,
              child: SegmentedSwitch(
                labels: const ['Day', 'Week', 'Month'],
                selected: selected,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

Widget _wide(int selected, {bool reduced = false}) => MaterialApp(
      theme: _webTheme,
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: Scaffold(
          body: Center(
            child: SizedBox(
              width: 330,
              child: WebSegmentedControl(
                labels: const ['Day', 'Week', 'Month'],
                selected: selected,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

Rect _thumb(WidgetTester tester, String key) =>
    tester.getRect(find.byKey(ValueKey(key)));

Rect _wideThumb(WidgetTester tester) => tester.getRect(
      find.descendant(
        of: find.byKey(const ValueKey('segmented-control-thumb')),
        matching: find.byType(DecoratedBox),
      ),
    );

Color _label(WidgetTester tester, String label) =>
    tester.widget<Text>(find.text(label)).style!.color!;

void main() {
  group('phone', () {
    testWidgets('the thumb slides 240 ms on the shared ease', (tester) async {
      await tester.pumpWidget(_phone(0));
      final from = _thumb(tester, 'segment-thumb');
      await tester.pumpWidget(_phone(2));
      await tester.pump();
      // The thumb ends under the third segment, 2 cells to the right.
      final cell = from.width;
      var elapsed = 0;
      for (final ms in [60, 60, 60, 60]) {
        await tester.pump(Duration(milliseconds: ms));
        elapsed += ms;
        final r = _thumb(tester, 'segment-thumb');
        expect(
          r.left,
          closeTo(from.left + 2 * cell * previewShared(elapsed / 240), 1),
          reason: '$elapsed ms',
        );
        expect(r.top, from.top);
        expect(r.width, closeTo(from.width, .01), reason: 'it only moves');
        expect(r.height, closeTo(from.height, .01));
      }
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('the label color fades 160 ms on the ease', (tester) async {
      const colors = PantasColors.light;
      await tester.pumpWidget(_phone(0));
      expect(_label(tester, 'Day'), colors.label);
      expect(_label(tester, 'Week'), colors.secondaryLabel);
      await tester.pumpWidget(_phone(1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      final p = previewEase(.5);
      final week = Color.lerp(colors.secondaryLabel, colors.label, p)!;
      expect(_label(tester, 'Week').r, closeTo(week.r, .02));
      final day = Color.lerp(colors.label, colors.secondaryLabel, p)!;
      expect(_label(tester, 'Day').r, closeTo(day.r, .02));
      await tester.pump(const Duration(milliseconds: 80));
      expect(_label(tester, 'Week'), colors.label);
      expect(_label(tester, 'Day'), colors.secondaryLabel);
    });

    testWidgets('every label keeps one weight, so the text does not jump',
        (tester) async {
      await tester.pumpWidget(_phone(0));
      await tester.pumpWidget(_phone(1));
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 60));
        for (final l in ['Day', 'Week', 'Month']) {
          expect(
            tester.widget<Text>(find.text(l)).style!.fontWeight,
            FontWeight.w600,
          );
        }
      }
    });

    testWidgets('reduced motion shows the final state in one frame',
        (tester) async {
      await tester.pumpWidget(_phone(0, reduced: true));
      final from = _thumb(tester, 'segment-thumb');
      await tester.pumpWidget(_phone(2, reduced: true));
      await tester.pump();
      expect(
        _thumb(tester, 'segment-thumb').left,
        greaterThan(from.left + 100),
      );
      expect(_label(tester, 'Month'), PantasColors.light.label);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('wide', () {
    testWidgets('the thumb slides 240 ms on the shared ease', (tester) async {
      await tester.pumpWidget(_wide(0));
      final from = _wideThumb(tester);
      await tester.pumpWidget(_wide(2));
      await tester.pump();
      final cell = from.width;
      var elapsed = 0;
      for (final ms in [60, 60, 60, 60]) {
        await tester.pump(Duration(milliseconds: ms));
        elapsed += ms;
        final r = _wideThumb(tester);
        expect(
          r.left,
          closeTo(from.left + 2 * cell * previewShared(elapsed / 240), 1),
          reason: '$elapsed ms',
        );
        expect(r.top, from.top);
      }
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('reduced motion shows the final state in one frame',
        (tester) async {
      await tester.pumpWidget(_wide(0, reduced: true));
      final from = tester.getRect(
        find.descendant(
          of: find.byKey(const ValueKey('segmented-control-thumb')),
          matching: find.byType(DecoratedBox),
        ),
      );
      await tester.pumpWidget(_wide(1, reduced: true));
      await tester.pump();
      final to = tester.getRect(
        find.descendant(
          of: find.byKey(const ValueKey('segmented-control-thumb')),
          matching: find.byType(DecoratedBox),
        ),
      );
      expect(to.left, closeTo(from.left + from.width, .5));
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('the control keeps its 38 px height and its taps',
        (tester) async {
      var value = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: _webTheme,
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: WebSegmentedControl(
                labels: const ['Subjects', 'Topics'],
                selected: 0,
                onChanged: (i) => value = i,
              ),
            ),
          ),
        ),
      );
      expect(tester.getSize(find.byType(WebSegmentedControl)).height, 38);
      await tester.tap(find.text('Topics'));
      expect(value, 1);
    });
  });
}
