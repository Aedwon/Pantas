import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/figures/chart_figure.dart';
import 'package:pantas/core/ui/figures/concept_diagram_figure.dart';
import 'package:pantas/core/ui/figures/coordinate_graph_figure.dart';
import 'package:pantas/core/ui/figures/gear_train_figure.dart';
import 'package:pantas/core/ui/figures/geometry_diagram_figure.dart';
import 'package:pantas/core/ui/figures/lesson_figure_widget.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('a lesson uses the same legacy gear painter as a question', (
    tester,
  ) async {
    await tester.pumpApp(
      const LessonFigureWidget(
        spec: {
          'kind': 'gear-train',
          'gears': 3,
          'firstTurns': 'clockwise',
        },
        semanticsLabel: 'Three meshed gears.',
      ),
    );

    expect(find.byType(GearTrainFigure), findsOneWidget);
  });

  testWidgets('all four lesson painter families resolve', (tester) async {
    const cases = <(Map<String, Object?>, String, Type)>[
      (
        {
          'kind': 'coordinate-graph',
          'type': 'parabola',
          'formula': 'y=x^2',
          'points': [
            [0, 0],
            [1, 1],
          ],
        },
        'A parabola.',
        CoordinateGraphFigure,
      ),
      (
        {
          'kind': 'geometry-diagram',
          'type': 'triangle',
          'labels': ['A', 'B', 'C'],
        },
        'Triangle ABC.',
        GeometryDiagramFigure,
      ),
      (
        {
          'kind': 'chart',
          'type': 'bar',
          'labels': ['A', 'B'],
          'values': [1, 2],
        },
        'Two bars.',
        ChartFigure,
      ),
      (
        {
          'kind': 'concept-diagram',
          'type': 'sequence',
          'nodes': ['A', 'B'],
          'edges': [
            [0, 1],
          ],
        },
        'A two-step sequence.',
        ConceptDiagramFigure,
      ),
    ];

    for (final entry in cases) {
      await tester.pumpApp(
        LessonFigureWidget(
          spec: entry.$1,
          semanticsLabel: entry.$2,
        ),
      );
      expect(find.byType(entry.$3), findsOneWidget);
    }
  });

  testWidgets('a bad lesson spec uses lesson failure copy', (tester) async {
    await tester.pumpApp(
      const LessonFigureWidget(
        spec: {
          'kind': 'chart',
          'type': 'bar',
          'labels': ['A'],
          'values': [1, 2],
        },
        semanticsLabel: 'Broken chart figure.',
      ),
    );

    expect(
      find.text('This lesson needs a diagram that has not been drawn yet.'),
      findsOneWidget,
    );
    expect(find.byType(ChartFigure), findsNothing);
  });
}
