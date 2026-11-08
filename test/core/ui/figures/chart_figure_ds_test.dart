import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/data_table.dart';
import 'package:pantas/core/ui/figures/chart_figure.dart';

import '../../../helpers/ds_matrix.dart';

ChartFigure _chart(int count, {String type = 'bar'}) => ChartFigure(
      type: type,
      labels: [for (var i = 1; i <= count; i++) 'W$i'],
      values: [for (var i = 1; i <= count; i++) 40.0 + i * 3],
    );

void main() {
  dsMatrix(
    'chart: 220 plot, no note when every column fits',
    (context) => SizedBox(width: 358, child: _chart(6)),
    check: (tester, cell) async {
      final plot = find.descendant(
        of: find.byType(ChartFigure),
        matching: find.byType(CustomPaint),
      );
      expect(tester.getSize(plot.first).height, 220);
      // Six columns at 44 each fit 358 at default text; at 200% they do not.
      if (cell.scale == 1) {
        expect(find.textContaining('The table has all'), findsNothing);
        expect(find.text('Show Table'), findsNothing);
      } else {
        expect(find.textContaining('The table has all 6'), findsOneWidget);
        expect(find.text('Show Table'), findsOneWidget);
      }
    },
  );

  testWidgets('hidden columns stay readable through Show Table',
      (tester) async {
    await pumpDs(
      tester,
      dsCells.first,
      SizedBox(width: 200, child: _chart(12, type: 'line')),
    );
    // 200 - 40 - 16 = 144 of plot: three 44 px columns.
    expect(
      find.text('Showing the last 3. The table has all 12.'),
      findsOneWidget,
    );
    expect(find.byType(PantasDataTable), findsNothing);
    await tester.tap(find.text('Show Table'));
    await tester.pump();
    expect(find.byType(PantasDataTable), findsOneWidget);
    expect(find.text('Hide Table'), findsOneWidget);
    // Every value is in the table, including the hidden oldest ones.
    expect(find.text('W1'), findsOneWidget);
    expect(find.text('43'), findsOneWidget);
    expect(find.text('W12'), findsOneWidget);
    await tester.tap(find.text('Hide Table'));
    await tester.pump();
    expect(find.byType(PantasDataTable), findsNothing);
    // The button is a 44 px target.
    expect(
      tester.getSize(find.byKey(const ValueKey('chart-table-toggle'))).height,
      greaterThanOrEqualTo(44),
    );
  });
}
