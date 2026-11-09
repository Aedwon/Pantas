import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_chart.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_results_page.dart';

import '../../../helpers/ds_matrix.dart';
import 'mock_results_page_test.dart' show result;

/// The "Versus past results" chart draws the points the page has, on the
/// shared Chart, at every width, theme and text scale.
void main() {
  formatTests();
  tearDown(() => debugWebPlatformOverride = null);
  const past = [
    MockPastPoint(percent: 50, label: 'Sep 5'),
    MockPastPoint(percent: 60, label: 'Sep 19'),
  ];

  for (final cell in dsShellCells.where((c) => c.width != 900)) {
    testWidgets('results chart shows the page points ($cell)', (tester) async {
      tester.view
        ..physicalSize = Size(cell.width, 1400)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final web = cell.width >= 1024;
      debugWebPlatformOverride = web;
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(
            size: Size(cell.width, 1400),
            textScaler: TextScaler.linear(cell.scale),
            disableAnimations: true,
          ),
          child: MaterialApp(
            theme: cell.dark
                ? buildDarkTheme(web: web)
                : buildLightTheme(web: web),
            home: MockResultsPage(
              results: result,
              proIsActive: true,
              blueprintName: 'UPCAT simulation',
              dateFormatted: 'Saturday, Oct 3',
              onDone: () {},
              onReviewTap: () {},
              onFullRecord: () {},
              pastResults: past,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(PantasChart), findsOneWidget);
      // No painted chart text and no old painter.
      expect(find.text('VERSUS PAST RESULTS'), findsOneWidget);
      final chart = find.byType(PantasChart);
      // Every earlier mock and this one are points on the chart or in its
      // table; at default text size all three fit and print their values.
      if (cell.scale == 1) {
        for (final text in ['Sep 5', 'Sep 19', 'Today', '50.0%', '60.0%']) {
          expect(
            find.descendant(of: chart, matching: find.text(text)),
            findsOneWidget,
            reason: text,
          );
        }
      }
      // The summary comes from the points' own values.
      expect(
        find.descendant(
          of: chart,
          matching: find.textContaining('ranged from 50.0% to 61.2%'),
        ),
        findsOneWidget,
      );
    });
  }

  test('the summary of one point says so', () {
    expect(
      mockPastSummary(const [PantasChartPoint(label: 'Today', value: 61.2)]),
      'One result so far.',
    );
  });
}

void formatTests() {
  testWidgets('the Today value keeps one decimal, as the old chart did',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: Scaffold(
          body: mockPastChart(
            const [MockPastPoint(percent: 50, label: 'Sep 5')],
            currentPercent: 68,
            currentLabel: 'Today',
          ),
        ),
      ),
    );
    expect(find.text('68.0%'), findsOneWidget);
    expect(find.text('50.0%'), findsOneWidget);
  });
}
