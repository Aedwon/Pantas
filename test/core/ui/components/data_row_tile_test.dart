import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/data_row_tile.dart';
import 'package:pantas/core/ui/components/inline_meter.dart';
import 'package:pantas/core/ui/theme/app_colors.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('a data row is 30 tall plus 4px padding, not 44', (tester) async {
    await tester.pumpApp(
      const DataRowTile(title: 'Chemistry', primaryFigure: '31%'),
    );
    expect(tester.getSize(find.byType(DataRowTile)).height, 38);
  });

  testWidgets('a tappable row keeps the same visual box', (tester) async {
    await tester.pumpApp(
      DataRowTile(title: 'Chemistry', onTap: () {}),
    );
    expect(tester.getSize(find.byType(DataRowTile)).height, 38);
  });

  testWidgets('a row with a subtext takes the height its two lines need',
      (tester) async {
    await tester.pumpApp(
      const DataRowTile(
        title: 'Peak hour',
        subtext: 'Measured from your highest accuracy',
        primaryFigure: '9 pm',
      ),
    );
    expect(
      tester.getSize(find.byType(DataRowTile)).height,
      greaterThan(38),
    );
  });

  testWidgets('a tappable row still reaches 44 of touch target',
      (tester) async {
    await tester.pumpApp(
      DataRowTile(title: 'Chemistry', onTap: () {}),
    );
    expect(find.byType(InkWell), findsOneWidget);
  });

  testWidgets('a null figure is an empty column, never a dash or a zero',
      (tester) async {
    await tester.pumpApp(
      const DataRowTile(title: 'Chemistry'),
    );
    expect(find.text('-'), findsNothing);
    expect(find.text('0'), findsNothing);
    expect(find.text('0%'), findsNothing);
  });

  testWidgets('the inactive column is muted at 400 and carries no colour',
      (tester) async {
    await tester.pumpApp(
      DataRowTile(
        title: 'Chemistry',
        primaryFigure: '31%',
        secondaryFigure: '48s',
        primaryIsActive: false,
        primaryColor: AppColors.light.rust,
      ),
    );
    final primary = tester.widget<Text>(find.text('31%'));
    expect(primary.style?.color, AppColors.light.inkMuted);
    expect(primary.style?.fontWeight, FontWeight.w400);
  });

  testWidgets('figures are tabular', (tester) async {
    await tester.pumpApp(
      const DataRowTile(title: 'Chemistry', primaryFigure: '31%'),
    );
    final figure = tester.widget<Text>(find.text('31%'));
    expect(
      figure.style?.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
  });

  testWidgets('a row with nothing measured draws no bar but holds its slot',
      (tester) async {
    // An empty bar is a figure, and there is no figure. The slot is still
    // held so the columns beside it stay in line.
    await tester.pumpApp(
      const Column(
        children: [
          DataRowTile(
            title: 'Measured',
            primaryFigure: '68%',
            meterValue: 0.68,
            showMeterSlot: true,
          ),
          DataRowTile(
            title: 'Not started',
            showMeterSlot: true,
          ),
        ],
      ),
    );

    expect(find.byType(InlineMeter), findsOneWidget);

    final measured = tester.getRect(find.text('68%'));
    expect(measured.right, greaterThan(0));
  });

  testWidgets('the meter is off unless the row asks for it', (tester) async {
    await tester.pumpApp(
      const DataRowTile(title: 'Plain', primaryFigure: '50%', meterValue: 0.5),
    );

    expect(find.byType(InlineMeter), findsNothing);
  });
}
