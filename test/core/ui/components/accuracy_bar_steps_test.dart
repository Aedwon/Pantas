import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/accuracy_bar.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';

import '../../../helpers/ds_matrix.dart';

void main() {
  const colors = PantasColors.light;

  test('five discrete steps, never a blend', () {
    expect(AccuracyBar.stepColor(colors, .44), colors.chart1);
    expect(AccuracyBar.stepColor(colors, .45), colors.chart2);
    expect(AccuracyBar.stepColor(colors, .54), colors.chart2);
    expect(AccuracyBar.stepColor(colors, .55), colors.chart3);
    expect(AccuracyBar.stepColor(colors, .64), colors.chart3);
    expect(AccuracyBar.stepColor(colors, .65), colors.chart4);
    expect(AccuracyBar.stepColor(colors, .74), colors.chart4);
    expect(AccuracyBar.stepColor(colors, .75), colors.chart5);
    expect(AccuracyBar.stepColor(colors, 1), colors.chart5);
  });

  dsMatrix(
    'accuracy bar: track fill, 5 px height, step color, min width',
    (context) => const SizedBox(
      width: 200,
      child: Column(
        children: [
          AccuracyBar(accuracy: .6),
          AccuracyBar.topicRows(accuracy: .02),
        ],
      ),
    ),
    check: (tester, cell) async {
      final palette = cell.dark ? PantasColors.dark : PantasColors.light;
      final fills = find.byKey(const ValueKey('accuracy-bar-fill'));
      expect(fills, findsNWidgets(2));
      expect(
        tester.widget<ColoredBox>(fills.first).color,
        palette.chart3,
      );
      expect(tester.getSize(find.byType(AccuracyBar).first).height, 5);
      expect(tester.getSize(find.byType(AccuracyBar).last).height, 4);
      // A low value never shrinks below the bar's own height.
      expect(tester.getSize(fills.last).width, greaterThanOrEqualTo(4));
    },
  );
}
