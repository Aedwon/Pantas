import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_results_page.dart';

import '../../../helpers/pump_app.dart';

class _Canvas extends Mock implements Canvas {}

void main() {
  setUpAll(() {
    registerFallbackValue(Offset.zero);
    registerFallbackValue(Paint());
  });

  testWidgets('Today point uses the original 8310ms pop stop', (tester) async {
    await tester.pumpApp(
      const MockPastChart(
        points: [
          MockPastPoint(percent: 50, label: 'Sep 5'),
          MockPastPoint(percent: 60, label: 'Sep 19'),
        ],
        currentPercent: 68.4,
        currentLabel: 'Today',
        time: 8310.016,
      ),
    );
    final painter = tester
        .widget<CustomPaint>(
          find.descendant(
            of: find.byType(MockPastChart),
            matching: find.byType(CustomPaint),
          ),
        )
        .painter!;
    final canvas = _Canvas();
    final circles = <({double radius, Color color})>[];
    when(() => canvas.drawCircle(any(), any(), any())).thenAnswer((call) {
      circles.add(
        (
          radius: call.positionalArguments[1] as double,
          color: (call.positionalArguments[2] as Paint).color
        ),
      );
    });
    painter.paint(canvas, const Size(326, 132));
    expect(circles.last.radius, closeTo(2.8, .001));
    expect(circles.last.color.a, closeTo(1, .001));
  });
}
