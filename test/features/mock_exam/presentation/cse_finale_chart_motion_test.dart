import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/ui/components/pantas_chart.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_results_page.dart';

import '../../../helpers/pump_app.dart';

class _Canvas extends Mock implements Canvas {}

void main() {
  setUpAll(() {
    registerFallbackValue(Offset.zero);
    registerFallbackValue(Paint());
  });

  Future<List<({double radius, Color color})>> circlesAt(
    WidgetTester tester,
    double? time,
  ) async {
    await tester.pumpApp(
      mockPastChart(
        const [
          MockPastPoint(percent: 50, label: 'Sep 5'),
          MockPastPoint(percent: 60, label: 'Sep 19'),
        ],
        currentPercent: 68.4,
        currentLabel: 'Today',
        time: time,
      ),
    );
    final painter = tester
        .widgetList<CustomPaint>(
          find.descendant(
            of: find.byType(PantasChart),
            matching: find.byType(CustomPaint),
          ),
        )
        .map((p) => p.painter)
        .whereType<CustomPainter>()
        .firstWhere((p) => p.runtimeType.toString() == '_PlotPainter');
    final canvas = _Canvas();
    final circles = <({double radius, Color color})>[];
    when(() => canvas.drawCircle(any(), any(), any())).thenAnswer((call) {
      circles.add(
        (
          radius: call.positionalArguments[1] as double,
          color: (call.positionalArguments[2] as Paint).color,
        ),
      );
    });
    painter.paint(canvas, const Size(326, 252));
    return circles;
  }

  testWidgets('Today point uses the original 8310ms pop stop', (tester) async {
    final circles = await circlesAt(tester, 8310.016);
    // The board's pop scale at 8310 ms is 0.4 of the point's size.
    expect(circles.last.radius, closeTo(PantasSpace.s4 * .4, .001));
    expect(circles.last.color.a, closeTo(1, .001));
  });

  testWidgets('with no clock the point is drawn at rest', (tester) async {
    final circles = await circlesAt(tester, null);
    expect(circles.last.radius, PantasSpace.s4);
    expect(circles.last.color.a, closeTo(1, .001));
  });

  testWidgets('the Today label and value fade in on the finale clock',
      (tester) async {
    await tester.pumpApp(
      mockPastChart(
        const [MockPastPoint(percent: 50, label: 'Sep 5')],
        currentPercent: 68.4,
        currentLabel: 'Today',
        time: 0,
      ),
    );
    // Before the label's track starts, it is not visible.
    final label = tester.widget<Opacity>(
      find.ancestor(of: find.text('Today'), matching: find.byType(Opacity)),
    );
    expect(label.opacity, lessThan(1));
    final value = tester.widget<Opacity>(
      find.ancestor(of: find.text('68.4%'), matching: find.byType(Opacity)),
    );
    expect(value.opacity, lessThan(1));
  });
}
