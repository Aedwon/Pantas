import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';
import 'package:pantas/features/home/presentation/widgets/accuracy_line.dart';

void main() {
  Widget harness({
    required List<({DateTime weekStart, double accuracy})> series,
  }) {
    return MaterialApp(
      theme: buildLightTheme(),
      home: Scaffold(
        body: AccuracyLine(series: series),
      ),
    );
  }

  AccuracyLinePainter painterOf(WidgetTester tester) {
    final customPaintFinder = find.descendant(
      of: find.byType(AccuracyLine),
      matching: find.byType(CustomPaint),
    );
    final customPaint = tester.widget<CustomPaint>(customPaintFinder);
    return customPaint.painter! as AccuracyLinePainter;
  }

  final onePoint = [
    (weekStart: DateTime(2026, 7, 13), accuracy: 75.0),
  ];

  final sixPoints = [
    (weekStart: DateTime(2026, 6), accuracy: 50.0),
    (weekStart: DateTime(2026, 6, 8), accuracy: 55.0),
    (weekStart: DateTime(2026, 6, 15), accuracy: 60.0),
    (weekStart: DateTime(2026, 6, 22), accuracy: 65.0),
    (weekStart: DateTime(2026, 6, 29), accuracy: 70.0),
    (weekStart: DateTime(2026, 7, 6), accuracy: 75.0),
  ];

  final narrowRange58to63 = [
    (weekStart: DateTime(2026, 6), accuracy: 58.0),
    (weekStart: DateTime(2026, 6, 8), accuracy: 63.0),
  ];

  testWidgets('renders nothing below two points', (tester) async {
    await tester.pumpWidget(harness(series: onePoint));
    expect(
      find.descendant(
        of: find.byType(AccuracyLine),
        matching: find.byType(CustomPaint),
      ),
      findsNothing,
    );
  });

  testWidgets('draws one line and no decoration', (tester) async {
    await tester.pumpWidget(harness(series: sixPoints));
    expect(find.byType(AccuracyLine), findsOneWidget);
    expect(find.byType(Tooltip), findsNothing);
  });

  testWidgets('the axis is always 0 to 100, never scaled to the data',
      (tester) async {
    await tester.pumpWidget(harness(series: narrowRange58to63));
    final painter = painterOf(tester);
    expect(painter.minY, 0);
    expect(painter.maxY, 100);
  });

  testWidgets('the approved record line is dark and the gridlines use fill',
      (tester) async {
    await tester.pumpWidget(harness(series: sixPoints));
    final painter = painterOf(tester);
    expect(
      painter.lineColor,
      buildLightTheme().extension<PantasColors>()!.label,
    );
    expect(
      painter.gridColor,
      buildLightTheme().extension<PantasColors>()!.fill,
    );
  });

  testWidgets('exposes a concise spoken summary of the accuracy history',
      (tester) async {
    await tester.pumpWidget(harness(series: sixPoints));

    expect(
      find.bySemanticsLabel(
        'Accuracy history. Up 25 percentage points overall, from 50 percent '
        'to 75 percent. Lowest 50 percent. Highest 75 percent. '
        '6 weekly results.',
      ),
      findsOneWidget,
    );
  });
}
