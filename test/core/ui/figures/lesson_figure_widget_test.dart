import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/figures/biology_diagram_figure.dart';
import 'package:pantas/core/ui/figures/chart_figure.dart';
import 'package:pantas/core/ui/figures/chemistry_diagram_figure.dart';
import 'package:pantas/core/ui/figures/concept_diagram_figure.dart';
import 'package:pantas/core/ui/figures/coordinate_graph_figure.dart';
import 'package:pantas/core/ui/figures/earth_science_diagram_figure.dart';
import 'package:pantas/core/ui/figures/gear_train_figure.dart';
import 'package:pantas/core/ui/figures/geometry_diagram_figure.dart';
import 'package:pantas/core/ui/figures/lesson_figure_widget.dart';
import 'package:pantas/core/ui/figures/physics_energy_diagram_figure.dart';
import 'package:pantas/core/ui/figures/physics_mechanics_diagram_figure.dart';
import 'package:pantas/core/ui/figures/reading_diagram_figure.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('a lesson uses the same legacy gear painter as a question', (
    tester,
  ) async {
    await tester.pumpApp(
      const LessonFigureWidget(
        spec: {
          'firstTurns': 'clockwise',
          'gears': 3,
          'kind': 'gear-train',
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
          'formula': 'y=x^2',
          'kind': 'coordinate-graph',
          'points': [
            [0, 0],
            [1, 1],
          ],
          'type': 'parabola',
        },
        'A parabola.',
        CoordinateGraphFigure,
      ),
      (
        {
          'kind': 'geometry-diagram',
          'labels': ['A', 'B', 'C'],
          'type': 'triangle',
        },
        'Triangle ABC.',
        GeometryDiagramFigure,
      ),
      (
        {
          'kind': 'chart',
          'labels': ['A', 'B'],
          'type': 'bar',
          'values': [1, 2],
        },
        'Two bars.',
        ChartFigure,
      ),
      (
        {
          'edges': [
            [0, 1],
          ],
          'kind': 'concept-diagram',
          'nodes': ['A', 'B'],
          'type': 'sequence',
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

  testWidgets('all six original lesson figure kinds resolve', (tester) async {
    const cases = <(Map<String, Object?>, Type)>[
      (
        {
          'kind': 'reading-diagram',
          'type': 'plot-arc',
          'illustrationKey':
              'reading-comprehension/text-types/short-stories-and-novels#1',
          'shape': 'rise-peak-fall',
          'stages': [
            'introduction',
            'rising action',
            'climax',
            'resolution',
          ],
        },
        ReadingDiagramFigure,
      ),
      (
        {
          'kind': 'biology-diagram',
          'type': 'stem-tissues',
          'illustrationKey': 'science/biology/botany#1',
          'outer': 'dermal tissue',
          'vascular': {
            'label': 'vascular tissue',
            'components': ['xylem', 'phloem'],
          },
          'ground': 'ground tissue',
        },
        BiologyDiagramFigure,
      ),
      (
        {
          'kind': 'chemistry-diagram',
          'type': 'atom-particles',
          'illustrationKey': 'science/chemistry/atomic-structure#1',
          'nucleus': ['proton (+)', 'neutron (neutral)'],
          'orbiting': ['electron (-)'],
        },
        ChemistryDiagramFigure,
      ),
      (
        {
          'kind': 'earth-science-diagram',
          'type': 'seasonal-orbit',
          'illustrationKey':
              'science/earth-science-astronomy/earths-motions#1',
          'earthPositions': 4,
          'axisDirection': 'constant',
          'hemisphereTilt': ['toward Sun', 'away from Sun'],
        },
        EarthScienceDiagramFigure,
      ),
      (
        {
          'kind': 'physics-mechanics-diagram',
          'type': 'accelerated-motion',
          'illustrationKey': 'science/physics/kinematics#1',
          'path': 'straight road',
          'moments': 3,
          'velocityTrend': 'increasing',
          'acceleration': 'constant',
        },
        PhysicsMechanicsDiagramFigure,
      ),
      (
        {
          'kind': 'physics-energy-diagram',
          'type': 'lens-comparison',
          'illustrationKey': 'science/physics/light-and-optics#2',
          'convexBehavior': 'parallel rays bend inward to one focus point',
          'concaveBehavior': 'parallel rays spread outward',
        },
        PhysicsEnergyDiagramFigure,
      ),
    ];

    for (final entry in cases) {
      await tester.pumpApp(
        LessonFigureWidget(
          spec: entry.$1,
          semanticsLabel: 'Original lesson figure.',
        ),
      );
      expect(
        find.byType(entry.$2),
        findsOneWidget,
        reason: 'Failed to resolve ${entry.$1['kind']}',
      );
      expect(
        find.text('This lesson needs a diagram that has not been drawn yet.'),
        findsNothing,
      );
    }
  });

  testWidgets('unknown lesson figure kind keeps the missing figure behavior', (
    tester,
  ) async {
    await tester.pumpApp(
      const LessonFigureWidget(
        spec: {'kind': 'unknown-lesson-figure'},
        semanticsLabel: 'Unknown lesson figure.',
      ),
    );

    expect(
      find.text('This lesson needs a diagram that has not been drawn yet.'),
      findsOneWidget,
    );
    expect(find.byType(ReadingDiagramFigure), findsNothing);
    expect(find.byType(BiologyDiagramFigure), findsNothing);
    expect(find.byType(ChemistryDiagramFigure), findsNothing);
    expect(find.byType(EarthScienceDiagramFigure), findsNothing);
    expect(find.byType(PhysicsMechanicsDiagramFigure), findsNothing);
    expect(find.byType(PhysicsEnergyDiagramFigure), findsNothing);
  });

  testWidgets('Worker B owned 46 lesson figures resolve to expected painters', (
    tester,
  ) async {
    const cases = <(Map<String, Object?>, String, Type)>[
      (
        {
          'kind': 'coordinate-graph',
          'type': 'vertical-line-test',
        },
        'Two graphs comparing a vertical line test on a '
            'regular parabola and a sideways parabola.',
        CoordinateGraphFigure,
      ),
      (
        {
          'kind': 'coordinate-graph',
          'type': 'linear-inequality',
          'formula': 'x + y < 3',
          'points': [
            [0, 3],
            [3, 0],
          ],
          'shaded': 'below',
        },
        'A coordinate graph with a dashed line through (0, '
            '3) and (3, 0) and the region containing the origin '
            'shaded.',
        CoordinateGraphFigure,
      ),
      (
        {
          'kind': 'concept-diagram',
          'type': 'venn',
          'sets': [
            'Chemistry',
            'Physics',
          ],
          'regions': {
            'left': '17',
            'overlap': '8',
            'right': '10',
            'outside': '5',
            'total': '40',
          },
        },
        'A two-circle Venn diagram showing 17 in Chemistry '
            'only, 8 in both, 10 in Physics only, and 5 '
            'outside.',
        ConceptDiagramFigure,
      ),
      (
        {
          'kind': 'concept-diagram',
          'type': 'venn',
          'sets': [
            'Engineering',
            'Business',
            'Computer Science',
          ],
          'center': '5',
          'overlaps': {
            'ab': '10',
            'bc': '5',
            'ca': '7',
          },
          'singleRegions': {
            'a': 'filled',
            'b': 'filled',
            'c': 'filled',
          },
        },
        'A three-circle Venn diagram showing overlaps of '
            'Engineering, Business, and Computer Science with 5 '
            'in the center.',
        ConceptDiagramFigure,
      ),
      (
        {
          'kind': 'coordinate-graph',
          'type': 'system',
          'points': [
            [3, 4],
          ],
          'formula': 'Crossing at (3, 4)',
        },
        'A coordinate graph with two lines intersecting at '
            'the point (3, 4).',
        CoordinateGraphFigure,
      ),
      (
        {
          'kind': 'coordinate-graph',
          'type': 'system',
          'points': [
            [1, -3],
            [2, 0],
          ],
          'formula': 'y = x^2 - 4 and y = 3x - 6',
        },
        'A coordinate graph of a parabola and a line '
            'intersecting at (1, -3) and (2, 0).',
        CoordinateGraphFigure,
      ),
      (
        {
          'kind': 'coordinate-graph',
          'type': 'function-gallery',
          'functions': [
            'linear',
            'quadratic',
            'rational',
            'absolute-value',
            'exponential',
            'logarithmic',
            'piecewise',
          ],
        },
        'A gallery showing graphs of linear, quadratic, '
            'rational, absolute value, exponential, '
            'logarithmic, and piecewise functions.',
        CoordinateGraphFigure,
      ),
      (
        {
          'kind': 'coordinate-graph',
          'type': 'rational',
          'formula': 'y = (x+1)/(x-2)',
          'asymptotes': [
            {
              'axis': 'x',
              'value': 2,
            },
            {
              'axis': 'y',
              'value': 1,
            },
          ],
        },
        'A rational function graph with a vertical '
            'asymptote at x = 2 and a horizontal asymptote at y '
            '= 1.',
        CoordinateGraphFigure,
      ),
      (
        {
          'kind': 'concept-diagram',
          'type': 'nested-boxes',
          'boxes': [
            'Natural Numbers',
            'Whole Numbers',
            'Integers',
            'Rational Numbers',
            'Irrational Numbers',
            'Real Numbers',
          ],
        },
        'A nested boxes diagram showing Natural Numbers '
            'inside Whole Numbers, Integers, Rational Numbers, '
            'with Irrational Numbers beside them inside Real '
            'Numbers.',
        ConceptDiagramFigure,
      ),
      (
        {
          'kind': 'chart',
          'type': 'bar',
          'labels': [
            'Factory A',
            'Factory B',
          ],
          'values': [450, 320],
          'yAxis': {
            'label': 'Units produced',
            'min': 0,
            'max': 500,
            'step': 100,
          },
        },
        'A bar chart showing Units produced with Factory A '
            'at 450 and Factory B at 320.',
        ChartFigure,
      ),
      (
        {
          'kind': 'coordinate-graph',
          'type': 'integral-area',
          'formula': 'Area from x = a to x = b',
          'points': [
            [1, 0],
            [4, 0],
          ],
        },
        'A graph showing the shaded area under a curve '
            'between x = a and x = b representing a definite '
            'integral.',
        CoordinateGraphFigure,
      ),
      (
        {
          'kind': 'concept-diagram',
          'type': 'conic-sections',
          'sections': [
            'circle',
            'ellipse',
            'parabola',
            'hyperbola',
          ],
        },
        'A diagram of a double cone sliced four ways to '
            'produce a circle, an ellipse, a parabola, and a '
            'hyperbola.',
        ConceptDiagramFigure,
      ),
      (
        {
          'kind': 'coordinate-graph',
          'type': 'conic-gallery',
          'conics': [
            'circle',
            'parabola',
            'ellipse',
            'hyperbola',
          ],
        },
        'A visual guide showing the four conic section '
            'curves: circle, parabola, ellipse, and hyperbola.',
        CoordinateGraphFigure,
      ),
      (
        {
          'kind': 'coordinate-graph',
          'type': 'circle',
          'formula': '(x-3)^2 + (y+2)^2 = 25',
          'points': [
            [3, -2],
          ],
          'radius': 5,
        },
        'A circle on a coordinate plane centered at (3, -2) '
            'with a radius of 5.',
        CoordinateGraphFigure,
      ),
      (
        {
          'kind': 'coordinate-graph',
          'type': 'ellipse',
          'formula': 'x^2/25 + y^2/9 = 1',
          'points': [
            [-5, 0],
            [5, 0],
            [0, -3],
            [0, 3],
            [-4, 0],
            [4, 0],
          ],
        },
        'An ellipse centered at the origin with vertices at '
            'plus or minus 5, co-vertices at plus or minus 3, '
            'and foci at plus or minus 4.',
        CoordinateGraphFigure,
      ),
      (
        {
          'kind': 'coordinate-graph',
          'type': 'hyperbola',
          'formula': 'x^2/16 - y^2/9 = 1',
          'points': [
            [-4, 0],
            [4, 0],
          ],
          'asymptoteSlopes': [0.75, -0.75],
        },
        'A hyperbola opening left and right with vertices '
            'at plus or minus 4 and dashed asymptotes through '
            'the origin.',
        CoordinateGraphFigure,
      ),
      (
        {
          'kind': 'coordinate-graph',
          'type': 'limits-gallery',
          'discontinuities': [
            'hole',
            'jump',
            'vertical-asymptote',
          ],
        },
        'Three mini graphs showing a removable hole, a jump '
            'between pieces, and a vertical asymptote.',
        CoordinateGraphFigure,
      ),
      (
        {
          'kind': 'coordinate-graph',
          'type': 'limit-hole',
          'formula': 'y = x + 3',
          'hole': [3, 6],
          'points': [
            [3, 6],
          ],
        },
        'A graph of y = x + 3 with an open circle hole at '
            '(3, 6).',
        CoordinateGraphFigure,
      ),
      (
        {
          'kind': 'coordinate-graph',
          'type': 'piecewise',
          'formula': 'x^2+1 for x<1, x+1 for x>=1',
          'points': [
            [1, 2],
          ],
        },
        'A continuous piecewise graph of a parabola and a '
            'line meeting at x = 1.',
        CoordinateGraphFigure,
      ),
      (
        {
          'kind': 'concept-diagram',
          'type': 'tree',
          'root': 'Outfits',
          'branches': [
            {
              'name': 'Shirt 1',
              'leaves': 3,
            },
            {
              'name': 'Shirt 2',
              'leaves': 3,
            },
            {
              'name': 'Shirt 3',
              'leaves': 3,
            },
            {
              'name': 'Shirt 4',
              'leaves': 3,
            },
          ],
          'totalLeaves': 12,
        },
        'A tree diagram with 4 shirt branches each '
            'splitting into 3 pants branches for a total of 12 '
            'leaf outfits.',
        ConceptDiagramFigure,
      ),
      (
        {
          'kind': 'chart',
          'type': 'pie',
          'labels': [
            'Food (90°)',
            'Rent (126°)',
            'Transport (72°)',
            'Savings (72°)',
          ],
          'values': [
            90,
            126,
            72,
            72,
          ],
        },
        'A pie chart of a monthly budget with food at 90 '
            'degrees, rent at 126 degrees, transport at 72 '
            'degrees, and savings at 72 degrees.',
        ChartFigure,
      ),
      (
        {
          'kind': 'chart',
          'type': 'scatter',
          'plots': [
            'upward',
            'downward',
            'random',
          ],
        },
        'Three scatter plots side by side showing an upward '
            'trend, a downward trend, and a random cloud of '
            'points.',
        ChartFigure,
      ),
      (
        {
          'kind': 'chart',
          'type': 'pie',
          'labels': [
            'Food (90°)',
            'Other (270°)',
          ],
          'values': [90, 270],
        },
        'A pie chart of a monthly budget with the food '
            'sector marked as a 90-degree slice.',
        ChartFigure,
      ),
      (
        {
          'kind': 'chart',
          'type': 'pie',
          'labels': [
            'Walkers (35%, ?°)',
            'Other (65%)',
          ],
          'values': [35, 65],
        },
        'A pie chart with the walkers sector labeled 35 '
            'percent and its central angle marked with a '
            'question mark.',
        ChartFigure,
      ),
      (
        {
          'kind': 'chart',
          'type': 'bar',
          'labels': [
            'Mon',
            'Tue',
            'Wed',
            'Thu',
            'Fri',
          ],
          'values': [
            40,
            55,
            35,
            60,
            85,
          ],
          'yAxis': {
            'label': 'Sales (thousands of pesos)',
            'min': 0,
          },
        },
        'A bar graph of weekly sales with bars for Monday '
            'at 40, Tuesday at 55, Wednesday at 35, Thursday at '
            '60, and Friday at 85.',
        ChartFigure,
      ),
      (
        {
          'kind': 'chart',
          'type': 'scatter',
          'trend': 'downward',
          'xLabel': 'Hours of sleep',
          'yLabel': 'Mistakes',
        },
        'A scatter plot showing hours of sleep against '
            'mistakes with points trending downward from left '
            'to right.',
        ChartFigure,
      ),
      (
        {
          'kind': 'chart',
          'type': 'bar',
          'labels': [
            '2023',
            '2024',
          ],
          'values': [1500, 1800],
          'yAxis': {
            'label': 'Enrollment',
            'min': 0,
          },
        },
        'A bar graph comparing 2023 enrollment of 1,500 '
            'with 2024 enrollment of 1,800 on a zero-based '
            'axis.',
        ChartFigure,
      ),
      (
        {
          'kind': 'concept-diagram',
          'type': 'inference',
          'clues': [
            'Clue phrase 1',
            'Clue phrase 2',
            'Clue phrase 3',
          ],
          'conclusion': 'Inference / Conclusion',
        },
        'A diagram showing three clue phrases connecting '
            'with arrows to form one conclusion.',
        ConceptDiagramFigure,
      ),
      (
        {
          'kind': 'concept-diagram',
          'type': 'main-idea',
          'mainIdea': 'Topic sentence / Main idea',
          'details': [
            'Supporting detail 1',
            'Supporting detail 2',
            'Supporting detail 3',
          ],
        },
        'A diagram with a topic sentence at the top and '
            'three supporting detail sentences pointing up to '
            'support it.',
        ConceptDiagramFigure,
      ),
      (
        {
          'kind': 'chart',
          'type': 'bar',
          'labels': [
            'January',
            'February',
            'March',
            'April',
          ],
          'values': [
            50,
            70,
            60,
            90,
          ],
          'yAxis': {
            'label': 'Sales (thousands of pesos)',
            'min': 0,
          },
        },
        'A bar graph of monthly sales with bars for January '
            'at 50, February at 70, March at 60, and April at '
            '90.',
        ChartFigure,
      ),
      (
        {
          'kind': 'chart',
          'type': 'bar',
          'labels': [
            'Brand A',
            'Brand B',
          ],
          'values': [85, 81],
          'yMin': 80,
          'compareZero': true,
        },
        'A bar graph starting at 80 comparing bars of 85 '
            'and 81, alongside a comparison starting at zero.',
        ChartFigure,
      ),
      (
        {
          'kind': 'concept-diagram',
          'type': 'free-body',
          'forces': [
            {
              'label': 'Normal Force (Fn)',
              'direction': 'up',
            },
            {
              'label': 'Weight (Fg)',
              'direction': 'down',
            },
          ],
        },
        'A free body diagram of a box with an upward normal '
            'force arrow and an equal downward gravity arrow.',
        ConceptDiagramFigure,
      ),
      (
        {
          'kind': 'concept-diagram',
          'type': 'gravitational-force',
          'masses': [
            'm1',
            'm2',
          ],
          'distance': 'r',
          'comparison': '2r (F/4)',
        },
        'Two spheres separated by distance r with inward '
            'gravity arrows, and a comparison at distance 2r '
            'with one fourth the force.',
        ConceptDiagramFigure,
      ),
      (
        {
          'kind': 'concept-diagram',
          'type': 'ray-reflection',
          'labels': [
            'Incident ray',
            'Normal line',
            'Reflected ray',
          ],
          'angles': [
            'Angle of incidence',
            'Angle of reflection',
          ],
        },
        'A flat mirror with a normal line showing an '
            'incoming incident ray and an outgoing reflected '
            'ray at equal angles.',
        ConceptDiagramFigure,
      ),
      (
        {
          'kind': 'concept-diagram',
          'type': 'ray-reflection',
          'incidentAngle': 40,
          'reflectedAngle': 40,
          'labels': [
            '40°',
            '40°',
          ],
        },
        'A light ray striking a flat mirror at 40 degrees '
            'from the normal line and reflecting off at 40 '
            'degrees.',
        ConceptDiagramFigure,
      ),
      (
        {
          'kind': 'concept-diagram',
          'type': 'vector-diagram',
          'vectors': [
            {
              'label': '5 N East',
              'angle': 0,
              'magnitude': 5,
            },
            {
              'label': '8 N Northeast',
              'angle': 45,
              'magnitude': 8,
            },
          ],
        },
        'Two vector arrows comparing a 5 N force pointing '
            'east and an 8 N force pointing northeast.',
        ConceptDiagramFigure,
      ),
      (
        {
          'kind': 'concept-diagram',
          'type': 'vector-addition',
          'components': [
            {
              'label': '3 km East',
              'dx': 3,
              'dy': 0,
            },
            {
              'label': '4 km North',
              'dx': 0,
              'dy': 4,
            },
          ],
          'resultant': {
            'label': '5 km Resultant',
            'dx': 3,
            'dy': 4,
          },
        },
        'A vector addition right triangle with 3 km east, 4 '
            'km north, and a 5 km resultant hypotenuse.',
        ConceptDiagramFigure,
      ),
      (
        {
          'kind': 'concept-diagram',
          'type': 'vector-components',
          'magnitude': 10,
          'angle': 30,
          'unit': 'N',
          'components': {
            'horizontal': '10 cos 30°',
            'vertical': '10 sin 30°',
          },
        },
        'A 10 N force vector at 30 degrees above the '
            'horizontal resolved into horizontal and vertical '
            'components.',
        ConceptDiagramFigure,
      ),
      (
        {
          'kind': 'concept-diagram',
          'type': 'tug-of-war',
          'forces': [
            {
              'label': 'Team A (600 N)',
              'direction': 'left',
              'magnitude': 600,
            },
            {
              'label': 'Team B (450 N)',
              'direction': 'right',
              'magnitude': 450,
            },
          ],
          'netForce': {
            'label': 'Net Force (150 N)',
            'direction': 'left',
          },
        },
        'A tug-of-war diagram with 600 N pulling left, 450 '
            'N pulling right, and a net force of 150 N to the '
            'left.',
        ConceptDiagramFigure,
      ),
      (
        {
          'kind': 'coordinate-graph',
          'type': 'projectile-motion',
          'path': 'parabola',
          'velocityVectors': true,
        },
        'A parabolic projectile path showing constant '
            'horizontal velocity arrows and vertical velocity '
            'shrinking at the peak.',
        CoordinateGraphFigure,
      ),
      (
        {
          'kind': 'coordinate-graph',
          'type': 'horizontal-projectile',
          'initialVelocity': '3 m/s',
          'labels': {
            'height': '?',
            'distance': '?',
          },
        },
        'A ball rolling off a table at 3 m/s following a '
            'curved path to the floor with height and distance '
            'marked with question marks.',
        CoordinateGraphFigure,
      ),
      (
        {
          'kind': 'concept-diagram',
          'type': 'vector-components',
          'magnitude': 20,
          'angle': 30,
          'unit': 'm/s',
          'components': {
            'horizontal': '20 cos 30°',
            'vertical': '20 sin 30°',
          },
        },
        'A 20 m/s launch velocity vector at 30 degrees '
            'resolved into horizontal and vertical components '
            'as a right triangle.',
        ConceptDiagramFigure,
      ),
      (
        {
          'kind': 'concept-diagram',
          'type': 'circular-orbit',
          'body': 'Earth',
          'orbiting': 'Satellite',
          'vectors': {
            'velocity': 'Tangent velocity (v)',
            'acceleration': 'Centripetal acceleration (ac)',
          },
        },
        'A satellite in circular orbit around Earth with a '
            'tangent velocity arrow and an inward centripetal '
            'acceleration arrow.',
        ConceptDiagramFigure,
      ),
      (
        {
          'kind': 'concept-diagram',
          'type': 'wave',
          'labels': {
            'wavelength': 'Wavelength (λ)',
            'amplitude': 'Amplitude (A)',
            'direction': 'Wave travel direction',
          },
        },
        'A transverse wave diagram with labeled wavelength '
            'between crests, amplitude from rest line, and '
            'direction arrow.',
        ConceptDiagramFigure,
      ),
      (
        {
          'kind': 'concept-diagram',
          'type': 'wave',
          'labels': {
            'wavelength': '2 m',
            'frequency': '5 Hz',
          },
        },
        'A transverse wave diagram with a 2 m wavelength '
            'and frequency of 5 Hz.',
        ConceptDiagramFigure,
      ),
      (
        {
          'kind': 'concept-diagram',
          'type': 'wave',
          'labels': {
            'wavelength': '?',
            'speed': '340 m/s',
            'frequency': '170 Hz',
          },
        },
        'A sound wave diagram with wavelength marked as a '
            'question mark, speed 340 m/s, and frequency 170 '
            'Hz.',
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

  testWidgets('invalid and incomplete lesson figure specs show missing box', (
    tester,
  ) async {
    const invalidCases = <Map<String, Object?>>[
      {
        'kind': 'coordinate-graph',
        'type': 'circle',
        'points': [
          [0, 0],
        ],
      },
      {
        'kind': 'coordinate-graph',
        'type': 'circle',
        'radius': -5,
        'points': [
          [0, 0],
        ],
      },
      {
        'kind': 'coordinate-graph',
        'type': 'circle',
        'radius': 5,
        'points': [],
      },
      {
        'kind': 'coordinate-graph',
        'type': 'ellipse',
        'points': [
          [0, 0],
        ],
      },
      {
        'kind': 'coordinate-graph',
        'type': 'hyperbola',
        'formula': 'x^2 - y^2 = 1',
        'points': [
          [0, 0],
        ],
      },
      {
        'kind': 'coordinate-graph',
        'type': 'hyperbola',
        'formula': 'x^2 - y^2 = 1',
        'points': [
          [0, 0],
        ],
        'asymptoteSlopes': [1.0],
      },
      {
        'kind': 'coordinate-graph',
        'type': 'integral-area',
        'formula': 'y = x^2',
      },
      {
        'kind': 'coordinate-graph',
        'type': 'integral-area',
        'formula': 'y = x^2',
        'points': [
          [1, 0],
        ],
      },
      {
        'kind': 'coordinate-graph',
        'type': 'linear-inequality',
        'formula': 'y < x',
        'points': [
          [0, 0],
          [1, 1],
        ],
        'shaded': 'sideways',
      },
      {
        'kind': 'coordinate-graph',
        'type': 'linear-inequality',
        'formula': 'y < x',
        'points': [
          [0, 0],
          [1, 1],
        ],
      },
      {
        'kind': 'coordinate-graph',
        'type': 'limit-hole',
        'formula': 'y = (x^2-1)/(x-1)',
      },
      {
        'kind': 'coordinate-graph',
        'type': 'piecewise',
        'points': [
          [0, 1],
        ],
      },
      {
        'kind': 'coordinate-graph',
        'type': 'system',
        'formula': 'y = x',
        'points': [],
      },
      {
        'kind': 'coordinate-graph',
        'type': 'rational',
        'formula': 'y = 1/x',
      },
      {
        'kind': 'coordinate-graph',
        'type': 'rational',
        'formula': 'y = 1/x',
        'asymptotes': 'none',
      },
      {
        'kind': 'coordinate-graph',
        'type': 'function-gallery',
        'functions': [
          '',
        ],
      },
      {
        'kind': 'coordinate-graph',
        'type': 'conic-gallery',
        'conics': [],
      },
      {
        'kind': 'coordinate-graph',
        'type': 'limits-gallery',
        'discontinuities': [123],
      },
      {
        'kind': 'coordinate-graph',
        'type': 'projectile-motion',
        'path': 'circle',
        'velocityVectors': true,
      },
      {
        'kind': 'coordinate-graph',
        'type': 'projectile-motion',
        'path': 'parabola',
      },
      {
        'kind': 'coordinate-graph',
        'type': 'horizontal-projectile',
        'labels': {
          'height': '?',
          'distance': '?',
        },
      },
      {
        'kind': 'coordinate-graph',
        'type': 'horizontal-projectile',
        'initialVelocity': '3 m/s',
        'labels': {
          'height': '?',
        },
      },
      {
        'kind': 'chart',
        'type': 'bar',
        'labels': [
          'A',
          'B',
        ],
        'values': [10],
      },
      {
        'kind': 'chart',
        'type': 'bar',
        'labels': [
          'A',
        ],
        'values': [
          'ten',
        ],
      },
      {
        'kind': 'chart',
        'type': 'bar',
        'labels': [
          'A',
        ],
        'values': [10],
        'yAxis': {
          'min': 'zero',
        },
      },
      {
        'kind': 'chart',
        'type': 'pie',
        'labels': [
          'A',
          'B',
        ],
        'values': [10, -5],
      },
      {
        'kind': 'chart',
        'type': 'pie',
        'labels': [
          'A',
          'B',
        ],
        'values': [10, 0],
      },
      {
        'kind': 'chart',
        'type': 'pie',
        'labels': [],
        'values': [],
      },
      {
        'kind': 'chart',
        'type': 'scatter',
        'plots': [
          'sideways',
        ],
      },
      {
        'kind': 'chart',
        'type': 'scatter',
        'trend': 'invalid',
      },
      {
        'kind': 'chart',
        'type': 'scatter',
        'trend': 'upward',
        'xLabel': '',
        'yLabel': 'Y',
      },
      {
        'kind': 'concept-diagram',
        'type': 'venn',
        'sets': [
          'A',
          'B',
        ],
        'regions': {
          'left': '1',
          'overlap': '2',
        },
      },
      {
        'kind': 'concept-diagram',
        'type': 'venn',
        'sets': [
          'A',
          'B',
          'C',
        ],
        'overlaps': {
          'ab': '1',
          'bc': '2',
          'ca': '3',
        },
      },
      {
        'kind': 'concept-diagram',
        'type': 'nested-boxes',
        'boxes': [],
      },
      {
        'kind': 'concept-diagram',
        'type': 'conic-sections',
        'sections': [],
      },
      {
        'kind': 'concept-diagram',
        'type': 'tree',
        'branches': [
          {
            'name': 'B1',
            'leaves': [
              'L1',
            ],
          },
        ],
        'totalLeaves': 1,
      },
      {
        'kind': 'concept-diagram',
        'type': 'tree',
        'root': 'R',
        'branches': [
          {
            'name': 'B1',
            'leaves': [
              'L1',
            ],
          },
        ],
        'totalLeaves': 0,
      },
      {
        'kind': 'concept-diagram',
        'type': 'inference',
        'clues': [
          'C1',
        ],
      },
      {
        'kind': 'concept-diagram',
        'type': 'inference',
        'clues': [],
        'conclusion': 'C',
      },
      {
        'kind': 'concept-diagram',
        'type': 'main-idea',
        'details': [
          'D1',
        ],
      },
      {
        'kind': 'concept-diagram',
        'type': 'main-idea',
        'mainIdea': 'M',
        'details': [],
      },
      {
        'kind': 'concept-diagram',
        'type': 'free-body',
        'forces': [
          {
            'label': 'F1',
            'direction': 'diagonal',
          },
        ],
      },
      {
        'kind': 'concept-diagram',
        'type': 'free-body',
        'forces': [],
      },
      {
        'kind': 'concept-diagram',
        'type': 'gravitational-force',
        'masses': [
          'm1',
        ],
        'distance': 'r',
        'comparison': '2r',
      },
      {
        'kind': 'concept-diagram',
        'type': 'gravitational-force',
        'masses': [
          'm1',
          'm2',
        ],
        'distance': 'r',
      },
      {
        'kind': 'concept-diagram',
        'type': 'ray-reflection',
        'labels': [
          'R1',
          'N',
          'R2',
        ],
        'angles': [
          'A1',
        ],
      },
      {
        'kind': 'concept-diagram',
        'type': 'ray-reflection',
        'incidentAngle': 0,
        'reflectedAngle': 0,
        'labels': [
          '0',
          '0',
        ],
      },
      {
        'kind': 'concept-diagram',
        'type': 'vector-diagram',
        'vectors': [
          {
            'label': 'V1',
            'angle': 0,
            'magnitude': -5,
          },
        ],
      },
      {
        'kind': 'concept-diagram',
        'type': 'vector-addition',
        'components': [
          {
            'label': 'C1',
            'dx': 1,
            'dy': 0,
          },
        ],
      },
      {
        'kind': 'concept-diagram',
        'type': 'vector-components',
        'magnitude': -10,
        'angle': 30,
        'unit': 'N',
        'components': {
          'horizontal': 'H',
          'vertical': 'V',
        },
      },
      {
        'kind': 'concept-diagram',
        'type': 'vector-components',
        'magnitude': 10,
        'angle': 30,
        'components': {
          'horizontal': 'H',
          'vertical': 'V',
        },
      },
      {
        'kind': 'concept-diagram',
        'type': 'tug-of-war',
        'forces': [
          {
            'label': 'F1',
            'direction': 'left',
            'magnitude': 100,
          },
        ],
        'netForce': {
          'label': 'Net',
          'direction': 'up',
        },
      },
      {
        'kind': 'concept-diagram',
        'type': 'circular-orbit',
        'body': 'Earth',
        'orbiting': 'Satellite',
        'vectors': {
          'velocity': 'v',
        },
      },
      {
        'kind': 'concept-diagram',
        'type': 'wave',
      },
      {
        'kind': 'concept-diagram',
        'type': 'wave',
        'labels': {},
      },
    ];

    for (final spec in invalidCases) {
      await tester.pumpApp(
        LessonFigureWidget(
          spec: spec,
          semanticsLabel: 'Malformed spec test',
        ),
      );

      expect(
        find.text('This lesson needs a diagram that has not been drawn yet.'),
        findsOneWidget,
        reason: 'Spec failed to reject: $spec',
      );
      expect(find.byType(CoordinateGraphFigure), findsNothing);
      expect(find.byType(ChartFigure), findsNothing);
      expect(find.byType(ConceptDiagramFigure), findsNothing);
    }
  });

  testWidgets('a bad lesson spec uses lesson failure copy', (tester) async {
    await tester.pumpApp(
      const LessonFigureWidget(
        spec: {
          'kind': 'chart',
          'labels': ['A'],
          'type': 'bar',
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
