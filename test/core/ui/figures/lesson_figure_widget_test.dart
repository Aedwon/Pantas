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

  testWidgets('geometry diagram figure supports all mathematics variants', (
    tester,
  ) async {
    const cases = <(Map<String, Object?>, String)>[
      (
        {
          'kind': 'geometry-diagram',
          'type': 'basic-concepts',
          'labels': ['Point A', 'Line AB', 'Segment CD', 'Ray EF', 'Plane P'],
        },
        'Diagram of basic geometric elements.',
      ),
      (
        {
          'kind': 'geometry-diagram',
          'type': 'angle-gallery',
          'labels': [
            'Acute (<90°)',
            'Right (90°)',
            'Obtuse (>90°)',
            'Straight (180°)',
            'Reflex (>180°)',
          ],
        },
        'Five angle types side by side.',
      ),
      (
        {
          'kind': 'geometry-diagram',
          'type': 'vertical-angles',
          'labels': ['(3x + 10)°', '(5x - 20)°'],
        },
        'Two intersecting lines forming an X.',
      ),
      (
        {
          'kind': 'geometry-diagram',
          'type': 'complementary-angles',
          'labels': ['x', '90° - x', 'Diff = 24°'],
        },
        'A right angle split into complementary parts.',
      ),
      (
        {
          'kind': 'geometry-diagram',
          'type': 'supplementary-angles',
          'labels': ['2x', '3x', 'Sum = 180°'],
        },
        'Supplementary angles on a straight line.',
      ),
      (
        {
          'kind': 'geometry-diagram',
          'type': 'segment-midpoint',
          'labels': ['A', 'M', 'B', '2x + 3', '3x - 7'],
        },
        'Segment AB with midpoint M.',
      ),
      (
        {
          'kind': 'geometry-diagram',
          'type': 'angles-on-line',
          'labels': ['(2x)°', '(3x + 10)°', '(x + 20)°', '180°'],
        },
        'Three adjacent angles on a straight line.',
      ),
      (
        {
          'kind': 'geometry-diagram',
          'type': 'circle-elements',
          'labels': [
            'Radius',
            'Diameter',
            'Chord',
            'Secant',
            'Tangent',
            'Center O',
          ],
        },
        'Circle showing radius, diameter, chord, secant, and tangent.',
      ),
      (
        {
          'kind': 'geometry-diagram',
          'type': 'circle-inscribed-central',
          'labels': ['Central: 80°', 'Inscribed: 40°', 'Arc = 80°'],
        },
        'Circle with central and inscribed angles.',
      ),
      (
        {
          'kind': 'geometry-diagram',
          'type': 'circle-sector',
          'labels': ['r = 6', '60°', 'Sector', 'Arc length s'],
        },
        'Circle of radius 6 with a 60 degree sector.',
      ),
      (
        {
          'kind': 'geometry-diagram',
          'type': 'circle-inscribed-triangle',
          'labels': [
            'A',
            'B',
            'C',
            'Diameter AB = 10',
            'AC = 6',
            'BC = ?',
            '90° at C',
          ],
        },
        'Circle with inscribed right triangle.',
      ),
      (
        {
          'kind': 'geometry-diagram',
          'type': 'circle-tangent',
          'labels': [
            'Center O',
            'Point P',
            'Point T',
            'OT = 5',
            'OP = 13',
            'PT = ?',
            '90° at T',
          ],
        },
        'Circle with external tangent segment.',
      ),
      (
        {
          'kind': 'geometry-diagram',
          'type': 'circle-arc',
          'labels': ['Radius r', 'Arc length = r', 'Central Angle = 1 rad'],
        },
        'Circle with arc of length r and 1 radian angle.',
      ),
      (
        {
          'kind': 'geometry-diagram',
          'type': 'coordinate-geometry',
          'labels': ['(-3, 4)', '(5, -2)', 'run = 8', 'rise = 6', 'd = ?'],
        },
        'Coordinate plane distance right triangle.',
      ),
      (
        {
          'kind': 'geometry-diagram',
          'type': 'shape-gallery',
          'labels': [
            'Square: s²',
            'Rectangle: lw',
            'Triangle: ½bh',
            'Parallelogram: bh',
            'Trapezoid: ½(b1+b2)h',
            'Circle: πr²',
          ],
        },
        'Row of geometric shapes with formulas.',
      ),
      (
        {
          'kind': 'geometry-diagram',
          'type': 'rectangle',
          'labels': ['Length = 8 cm', 'Width = ?', 'Perimeter = 26 cm'],
        },
        'Rectangle with length 8 cm and perimeter 26 cm.',
      ),
      (
        {
          'kind': 'geometry-diagram',
          'type': 'trapezoid',
          'labels': ['b1 = 8 cm', 'b2 = 12 cm', 'h = 5 cm', '90°'],
        },
        'Trapezoid with bases 8 cm and 12 cm and height 5 cm.',
      ),
      (
        {
          'kind': 'geometry-diagram',
          'type': 'inscribed-circle-square',
          'labels': ['Square side = 10', 'Circle radius = 5', 'Shaded corners'],
        },
        'Square of side 10 with inscribed circle.',
      ),
      (
        {
          'kind': 'geometry-diagram',
          'type': '3d-box',
          'labels': ['Length = 5 cm', 'Width = 4 cm', 'Height = 3 cm'],
        },
        'Rectangular 3D box.',
      ),
      (
        {
          'kind': 'geometry-diagram',
          'type': '3d-cylinder',
          'labels': ['r = 3 cm', 'h = 10 cm'],
        },
        '3D cylinder with radius 3 cm and height 10 cm.',
      ),
      (
        {
          'kind': 'geometry-diagram',
          'type': '3d-cone',
          'labels': [
            'Radius r = 6 cm',
            'Height h = 8 cm',
            'Slant height l = ?',
            '90°',
          ],
        },
        '3D cone with radius 6 cm and height 8 cm.',
      ),
      (
        {
          'kind': 'geometry-diagram',
          'type': 'transversal',
          'labels': ['Line l', 'Line m', '65°', 'Linear pair: 115°'],
        },
        'Parallel lines cut by a transversal.',
      ),
      (
        {
          'kind': 'geometry-diagram',
          'type': 'parallel-zigzag',
          'labels': ['Line l', 'Line m', 'Point P', '30°', '40°'],
        },
        'Parallel lines zigzag angle at P.',
      ),
      (
        {
          'kind': 'geometry-diagram',
          'type': 'polygon-triangulation',
          'labels': ['Hexagon (n = 6)', '4 Triangles', '(6 - 2) × 180° = 720°'],
        },
        'Hexagon triangulation from one vertex.',
      ),
      (
        {
          'kind': 'geometry-diagram',
          'type': 'quadrilateral-tree',
          'labels': [
            'Quadrilateral',
            'Trapezoid',
            'Parallelogram',
            'Rectangle',
            'Rhombus',
            'Square',
          ],
        },
        'Quadrilateral family hierarchy tree.',
      ),
      (
        {
          'kind': 'geometry-diagram',
          'type': 'polygon',
          'labels': ['Regular Octagon (n = 8)', 'Each angle = ?'],
        },
        'Regular octagon.',
      ),
      (
        {
          'kind': 'geometry-diagram',
          'type': 'polygon-exterior',
          'labels': ['Exterior angle = 24°', 'Sum = 360°'],
        },
        'Polygon with exterior angle 24 degrees.',
      ),
      (
        {
          'kind': 'geometry-diagram',
          'type': 'parallelogram',
          'labels': [
            'A',
            'B',
            'C',
            'D',
            'Angle A: (3x + 10)°',
            'Angle C: (5x - 30)°',
            'Angle B: ?',
          ],
        },
        'Parallelogram ABCD.',
      ),
      (
        {
          'kind': 'geometry-diagram',
          'type': 'quadrilateral',
          'labels': ['x', '2x', '3x', '4x', 'Sum = 360°'],
        },
        'Four-sided quadrilateral.',
      ),
      (
        {
          'kind': 'geometry-diagram',
          'type': 'triangle-exterior',
          'labels': ['45°', '?', 'Exterior = 110°'],
        },
        'Triangle exterior angle theorem.',
      ),
      (
        {
          'kind': 'geometry-diagram',
          'type': 'similar-triangles',
          'labels': [
            'Student: h = 1.5 m',
            'Shadow = 2 m',
            'Tree: H = ?',
            'Shadow = 12 m',
          ],
        },
        'Similar right triangles for student and tree.',
      ),
      (
        {
          'kind': 'geometry-diagram',
          'type': 'special-right-triangles',
          'labels': [
            '45°-45°-90°: legs 5, hyp 5√2',
            '30°-60°-90°: hyp 12, short 6, long 6√3',
          ],
        },
        'Two special right triangles.',
      ),
      (
        {
          'kind': 'geometry-diagram',
          'type': 'coterminal-angles',
          'labels': ['400° = 360° + 40°', '-120° = 240°'],
        },
        'Coterminal angles on coordinate planes.',
      ),
      (
        {
          'kind': 'geometry-diagram',
          'type': 'right-triangle-trig',
          'labels': [
            'θ',
            'Opposite = 3',
            'Adjacent = 4',
            'Hypotenuse = 5',
            '90°',
          ],
        },
        'Right triangle with angle theta and sides 3, 4, 5.',
      ),
      (
        {
          'kind': 'geometry-diagram',
          'type': 'unit-circle',
          'labels': ['θ', 'P(cos θ, sin θ)', 'x = cos θ', 'y = sin θ'],
        },
        'Unit circle with angle theta.',
      ),
      (
        {
          'kind': 'geometry-diagram',
          'type': 'unit-circle-quadrants',
          'labels': [
            'Q I: All (+)',
            'Q II: Sine (+)',
            'Q III: Tangent (+)',
            'Q IV: Cosine (+)',
          ],
        },
        'Unit circle quadrant signs.',
      ),
      (
        {
          'kind': 'geometry-diagram',
          'type': 'elevation-depression',
          'labels': ['Elevation', 'Depression', 'Horizontal'],
        },
        'Elevation and depression angles.',
      ),
      (
        {
          'kind': 'geometry-diagram',
          'type': 'two-triangles-elevation',
          'labels': [
            'Point A: 30°',
            'Point B: 60°',
            'AB = 100 m',
            'Height = ?',
          ],
        },
        'Two observers on ground looking at building top.',
      ),
    ];

    for (final entry in cases) {
      await tester.pumpApp(
        LessonFigureWidget(
          spec: entry.$1,
          semanticsLabel: entry.$2,
        ),
      );
      expect(
        find.byType(GeometryDiagramFigure),
        findsOneWidget,
        reason: 'Failed to build geometry variant ${entry.$1['type']}',
      );
    }
  });

  testWidgets(
    'recognized geometry type with missing or empty labels shows '
    'missing figure state',
    (tester) async {
      const invalidSpecs = <Map<String, Object?>>[
        {'kind': 'geometry-diagram', 'type': 'triangle'},
        {'kind': 'geometry-diagram', 'type': 'triangle', 'labels': <String>[]},
        {
          'kind': 'geometry-diagram',
          'type': 'triangle',
          'labels': ['   '],
        },
      ];

      for (final spec in invalidSpecs) {
        await tester.pumpApp(
          LessonFigureWidget(
            spec: spec,
            semanticsLabel: 'Invalid geometry spec.',
          ),
        );

        expect(
          find.text(
            'This lesson needs a diagram that has not been drawn yet.',
          ),
          findsOneWidget,
        );
        expect(find.byType(GeometryDiagramFigure), findsNothing);
      }
    },
  );
}
