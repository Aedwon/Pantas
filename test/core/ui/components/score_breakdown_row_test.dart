import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/accuracy_bar.dart';
import 'package:pantas/core/ui/components/score_breakdown_row.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

import '../../../helpers/ds_matrix.dart';
import '../motion/preview_curves.dart';

// With no entrance clock, the wide 8 px bar fills like the phone's bar: 600 ms
// on houseOut. An entrance clock still drives it directly.
void main() {
  tearDown(() => debugWebPlatformOverride = null);

  Future<void> mount(
    WidgetTester tester, {
    double? animatedAccuracy,
    bool still = false,
  }) async {
    debugWebPlatformOverride = true;
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: true),
        home: MediaQuery(
          data: MediaQueryData(
            size: const Size(1440, 900),
            disableAnimations: still,
          ),
          child: Scaffold(
            body: SizedBox(
              width: 400,
              child: ScoreBreakdownRow(
                name: 'Algebra',
                correct: 3,
                total: 4,
                divider: false,
                animatedAccuracy: animatedAccuracy,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // The fill's share of the 5 high track.
  double fill(WidgetTester tester) =>
      tester.getSize(find.byKey(const ValueKey('accuracy-bar-fill'))).width /
      tester
          .getSize(
            find.descendant(
              of: find.byType(ScoreBreakdownRow),
              matching: find.byType(ClipRRect),
            ),
          )
          .width;

  testWidgets('the wide bar fills over 600 ms on houseOut', (tester) async {
    await mount(tester);
    // A bar never shrinks below its own height, so 0 still shows 5 px.
    expect(fill(tester), closeTo(0, .02));
    await tester.pump(const Duration(milliseconds: 150));
    expect(fill(tester), closeTo(.75 * previewBezier(.3, .9, .3, 1, .25), .01));
    expect(fill(tester), inExclusiveRange(0, .75));
    await tester.pump(const Duration(milliseconds: 450));
    expect(fill(tester), .75);
    await tester.pumpAndSettle();
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('the bar does not refill when the row rebuilds', (tester) async {
    await mount(tester);
    await tester.pumpAndSettle();
    await mount(tester);
    await tester.pump(const Duration(milliseconds: 16));
    expect(fill(tester), .75);
  });

  testWidgets('an entrance clock drives the bar directly', (tester) async {
    await mount(tester, animatedAccuracy: .3);
    expect(fill(tester), .3);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('reduced motion shows the bar full at once', (tester) async {
    await mount(tester, still: true);
    expect(fill(tester), .75);
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
  });

  dsMatrix(
    'stat row with a value text: name, subtitle, value, chevron and bar',
    (context) => const SizedBox(
      width: 358,
      child: Column(
        children: [
          ScoreBreakdownRow.value(
            name: 'Mathematics',
            subtitle: '12 topics',
            accuracy: .61,
            valueText: '61%',
            chevron: true,
            divider: true,
          ),
          ScoreBreakdownRow.value(
            name: 'Reading',
            accuracy: null,
            divider: false,
          ),
        ],
      ),
    ),
    check: (tester, cell) async {
      final palette = cell.dark ? PantasColors.dark : PantasColors.light;
      expect(find.text('Mathematics'), findsOneWidget);
      expect(find.text('12 topics'), findsOneWidget);
      expect(find.text('61%'), findsOneWidget);
      // The value is 16/600 in the primary ink.
      final value = tester.widget<Text>(find.text('61%'));
      expect(value.style!.fontWeight, FontWeight.w600);
      expect(value.style!.color, palette.textPrimary);
      // No data: the words, in secondary ink at 400, never 0%.
      final empty = tester.widget<Text>(find.text('No data'));
      expect(empty.style!.color, palette.textSecondary);
      expect(empty.style!.fontWeight, FontWeight.w400);
      expect(find.text('0%'), findsNothing);
      // The empty row has a track and no fill.
      expect(find.byType(AccuracyBar), findsOneWidget);
      expect(find.byKey(const ValueKey('accuracy-bar-fill')), findsOneWidget);
    },
  );

  testWidgets('the existing correct-of-total look is unchanged',
      (tester) async {
    await pumpDs(
      tester,
      dsCells.first,
      const SizedBox(
        width: 358,
        child: ScoreBreakdownRow(
          name: 'Algebra',
          correct: 3,
          total: 4,
          divider: false,
        ),
      ),
    );
    expect(find.text('3 / 4'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
  });
}
