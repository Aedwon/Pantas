import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/ui/components/pantas_chart.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';

import '../../../helpers/ds_matrix.dart';

class _Canvas extends Mock implements Canvas {}

class _Paragraph extends Fake implements ui.Paragraph {}

void main() {
  setUpAll(() {
    registerFallbackValue(Offset.zero);
    registerFallbackValue(Paint());
    registerFallbackValue(Rect.zero);
    registerFallbackValue(RRect.zero);
    registerFallbackValue(Path());
    registerFallbackValue(_Paragraph());
  });

  const six = [
    PantasChartPoint(label: 'Jun 2', value: 48),
    PantasChartPoint(label: 'Jun 16', value: 55),
    PantasChartPoint(label: 'Jul 1', value: 52),
    PantasChartPoint(label: 'Aug 3', value: 61),
    PantasChartPoint(label: 'Aug 3', value: 64.5),
    PantasChartPoint(label: 'Aug 20', value: 71),
  ];
  const summary =
      'Your last 6 mocks ranged from 48% to 71%. The latest is 71%.';

  Widget chart(
    List<PantasChartPoint> points, {
    PantasChartKind kind = PantasChartKind.bar,
    List<double?>? secondary,
    double width = 358,
  }) =>
      SizedBox(
        width: width,
        child: PantasChart(
          title: 'Past results',
          summary: summary,
          points: points,
          kind: kind,
          unit: 'mocks',
          secondary: secondary,
          primaryName: 'You',
          secondaryName: 'Target',
          secondaryHeader: 'Target',
        ),
      );

  dsMatrix(
    'chart: title, summary, y axis, values and x labels are Text',
    (context) => chart(six.sublist(4)),
    check: (tester, cell) async {
      final palette = cell.dark ? PantasColors.dark : PantasColors.light;
      expect(find.text('Past results'), findsOneWidget);
      expect(find.text(summary), findsOneWidget);
      for (final y in ['0%', '25%', '50%', '75%', '100%']) {
        expect(find.text(y), findsOneWidget, reason: y);
      }
      // Every value is printed, one decimal only where it has one.
      for (final v in ['64.5%', '71%']) {
        expect(find.text(v), findsOneWidget, reason: v);
      }
      expect(find.text('Aug 3'), findsOneWidget);
      // The latest label is 600 in the primary ink.
      final latest = tester.widget<Text>(find.text('Aug 20'));
      expect(latest.style!.fontWeight, FontWeight.w600);
      expect(latest.style!.color, palette.textPrimary);
      final first = tester.widget<Text>(find.text('Aug 3'));
      expect(first.style!.color, palette.textSecondary);
      // The plot is 220 high at every width.
      final plot = tester.getSize(find.byType(CustomPaint).first);
      expect(plot.height, greaterThanOrEqualTo(PantasSize.chartH));
      // Two columns fit at this width: no clipped note, no button.
      expect(find.text('Show Table'), findsNothing);
    },
  );

  testWidgets('the painter draws no text', (tester) async {
    await pumpDs(tester, dsCells.first, chart(six, kind: PantasChartKind.line));
    await tester.pumpAndSettle();
    final painters = tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((p) => p.painter)
        .whereType<CustomPainter>();
    expect(painters, isNotEmpty);
    for (final painter in painters) {
      final canvas = _Canvas();
      painter.paint(canvas, const Size(300, 260));
      verifyNever(() => canvas.drawParagraph(any(), any()));
    }
  });

  testWidgets('a narrow chart keeps the latest points and offers the table',
      (tester) async {
    final ten = [
      for (var i = 1; i <= 10; i++)
        PantasChartPoint(label: 'W$i', value: 40.0 + i),
    ];
    await pumpDs(tester, dsCells.first, chart(ten, width: 240));
    await tester.pumpAndSettle();
    // 240 less the axis holds four 44 wide columns.
    expect(
      find.text('Showing the last 4 mocks. The table has all 10.'),
      findsOneWidget,
    );
    expect(find.text('W10'), findsOneWidget);
    expect(find.text('W1'), findsNothing);
    expect(find.text('Hide Table'), findsNothing);
    await tester.tap(find.text('Show Table'));
    await tester.pumpAndSettle();
    expect(find.text('Hide Table'), findsOneWidget);
    // The table lists every result.
    expect(find.text('W1'), findsOneWidget);
    expect(find.text('41%'), findsOneWidget);
    expect(find.text('DATE'), findsOneWidget);
    expect(find.text('SCORE'), findsOneWidget);
    await tester.tap(find.text('Hide Table'));
    await tester.pumpAndSettle();
    expect(find.text('W1'), findsNothing);
  });

  testWidgets('the table is reachable by a screen reader while closed',
      (tester) async {
    final handle = tester.ensureSemantics();
    await pumpDs(tester, dsCells.first, chart(six));
    await tester.pumpAndSettle();
    expect(
      find.bySemanticsLabel(RegExp(r'Past results table\. Jun 2: 48%')),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('no data in a point reads No data in the table and draws no mark',
      (tester) async {
    const points = [
      PantasChartPoint(label: 'A', value: 50),
      PantasChartPoint(label: 'B', value: null),
      PantasChartPoint(label: 'C', value: 60),
      PantasChartPoint(label: 'D', value: 70),
      PantasChartPoint(label: 'E', value: 80),
    ];
    await pumpDs(tester, dsCells.first, chart(points, width: 200));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show Table'));
    await tester.pumpAndSettle();
    expect(find.text('No data'), findsOneWidget);
  });

  testWidgets('empty: the message sits in the plot, gridlines stay, no table',
      (tester) async {
    await pumpDs(tester, dsCells.first, chart(const []));
    await tester.pumpAndSettle();
    expect(find.text('No results yet.'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('Show Table'), findsNothing);
  });

  testWidgets('a second series shows its legend and a column in the table',
      (tester) async {
    await pumpDs(
      tester,
      dsCells.first,
      chart(
        six,
        kind: PantasChartKind.line,
        secondary: const [50, 50, 55, 55, 60, 60],
        width: 200,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('You'), findsOneWidget);
    expect(find.text('Target'), findsOneWidget);
    await tester.tap(find.text('Show Table'));
    await tester.pumpAndSettle();
    expect(find.text('TARGET'), findsOneWidget);
  });

  testWidgets('reduced motion draws the bars at once', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          theme: buildLightTheme(),
          home: Scaffold(body: chart(six, width: 600)),
        ),
      ),
    );
    expect(tester.hasRunningAnimations, isFalse);
  });
}
