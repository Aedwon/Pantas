import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/figures/cube_net_figure.dart';
import 'package:pantas/core/ui/figures/figure_matrix_figure.dart';
import 'package:pantas/core/ui/figures/figure_series_figure.dart';
import 'package:pantas/core/ui/figures/gear_train_figure.dart';
import 'package:pantas/core/ui/figures/geometry_diagram_figure.dart';
import 'package:pantas/core/ui/figures/lesson_figure_widget.dart';
import 'package:pantas/core/ui/figures/paper_fold_figure.dart';
import 'package:pantas/core/ui/figures/pulley_system_figure.dart';
import 'package:pantas/core/ui/figures/shape_row_figure.dart';
import 'package:pantas/core/ui/figures/stability_shape_figure.dart';

import '../../../helpers/pump_app.dart';

void main() {
  test('new lesson-only fields reject malformed values', () {
    expect(
      GearTrainFigure.fromSpec({
        'firstTurns': 'clockwise',
        'gears': 3,
        'layout': 'ring',
      }),
      isNull,
    );
    expect(
      PulleySystemFigure.fromSpec({
        'comparison': true,
        'fixed': 2,
        'movable': 1,
      }),
      isNull,
    );
    expect(
      StabilityShapeFigure.fromSpec({
        'shapes': [
          {'baseWidth': 2, 'form': 'car', 'height': 1},
        ],
      }),
      isNull,
    );
    expect(
      FigureSeriesFigure.parseItem({
        'form': 'square',
        'line': 0,
        'lines': [0, 90],
      }),
      isNull,
    );
    expect(
      CubeNetFigure.fromSpec({
        'cells': [
          [0, 1],
          [1, 0],
          [1, 1],
          [1, 2],
          [2, 1],
          [3, 1],
        ],
        'labels': ['top'],
      }),
      isNull,
    );
    expect(
      PaperFoldFigure.fromSpec({
        'folds': ['vertical'],
        'sheet': 'triangle',
      }),
      isNull,
    );
  });

  testWidgets('lesson gear specs support spokes and an unmarked first gear', (
    tester,
  ) async {
    await tester.pumpApp(
      const LessonFigureWidget(
        spec: {
          'firstTurns': 'clockwise',
          'gears': 4,
          'kind': 'gear-train',
          'layout': 'spokes',
        },
        semanticsLabel: 'A center gear with three gears around it.',
      ),
    );

    var figure = tester.widget<GearTrainFigure>(find.byType(GearTrainFigure));
    expect(figure.layout, 'spokes');
    expect(figure.firstTurnsClockwise, isTrue);

    await tester.pumpApp(
      const LessonFigureWidget(
        spec: {
          'gears': 2,
          'kind': 'gear-train',
          'showFirstTurn': false,
          'teeth': [10, 30],
        },
        semanticsLabel: 'A small gear meshing with a large gear.',
      ),
    );

    figure = tester.widget<GearTrainFigure>(find.byType(GearTrainFigure));
    expect(figure.firstTurnsClockwise, isNull);
  });

  testWidgets('a lesson pulley comparison stays two separate setups', (
    tester,
  ) async {
    await tester.pumpApp(
      const LessonFigureWidget(
        spec: {
          'comparison': true,
          'fixed': 1,
          'kind': 'pulley-system',
          'movable': 1,
        },
        semanticsLabel: 'A fixed pulley beside a movable pulley.',
      ),
    );

    final figure = tester.widget<PulleySystemFigure>(
      find.byType(PulleySystemFigure),
    );
    expect(figure.comparison, isTrue);
  });

  testWidgets('stability lesson specs carry per-shape form and tilt', (
    tester,
  ) async {
    await tester.pumpApp(
      const LessonFigureWidget(
        spec: {
          'kind': 'stability-shape',
          'shapes': [
            {'baseWidth': 3, 'form': 'truck', 'height': 1},
            {'baseWidth': 1, 'form': 'person', 'height': 3, 'tilt': 18},
          ],
        },
        semanticsLabel: 'Two stability examples.',
      ),
    );

    final figure = tester.widget<StabilityShapeFigure>(
      find.byType(StabilityShapeFigure),
    );
    expect(figure.shapes.first.form, 'truck');
    expect(figure.shapes.last.form, 'person');
    expect(figure.shapes.last.tiltDegrees, 18);
  });

  testWidgets('shape rows include the required parallelogram', (tester) async {
    await tester.pumpApp(
      const LessonFigureWidget(
        spec: {
          'kind': 'shape-row',
          'shapes': [
            {'form': 'square'},
            {'form': 'rectangle'},
            {'form': 'rhombus'},
            {'form': 'parallelogram'},
            {'form': 'pentagon'},
          ],
        },
        semanticsLabel: 'Five shapes.',
      ),
    );

    final figure = tester.widget<ShapeRowFigure>(find.byType(ShapeRowFigure));
    expect(figure.shapes.map((shape) => shape.form), contains('parallelogram'));
  });

  testWidgets('matrix cells support whole rotation and combined lines', (
    tester,
  ) async {
    await tester.pumpApp(
      const LessonFigureWidget(
        spec: {
          'cells': [
            {'dots': 1, 'form': 'triangle', 'rotation': 0},
            {'dots': 2, 'form': 'triangle', 'rotation': 0},
            {'dots': 3, 'form': 'triangle', 'rotation': 0},
            {'dots': 1, 'form': 'triangle', 'rotation': 90},
            {'dots': 2, 'form': 'triangle', 'rotation': 90},
            {'dots': 3, 'form': 'triangle', 'rotation': 90},
            {'dots': 1, 'form': 'triangle', 'rotation': 180},
            {'dots': 2, 'form': 'triangle', 'rotation': 180},
            'blank',
          ],
          'cols': 3,
          'kind': 'figure-matrix',
          'rows': 3,
        },
        semanticsLabel: 'A matrix with one blank.',
      ),
    );

    var figure = tester.widget<FigureMatrixFigure>(
      find.byType(FigureMatrixFigure),
    );
    expect(figure.cells[3]!.rotationDegrees, 90);
    expect(figure.cells[6]!.rotationDegrees, 180);

    await tester.pumpApp(
      const LessonFigureWidget(
        spec: {
          'cells': [
            {'form': 'circle', 'line': 90},
            {'form': 'circle', 'line': 0},
            {
              'form': 'circle',
              'lines': [90, 0],
            },
            {'form': 'square', 'line': 45},
            {'form': 'square', 'line': 135},
            'blank',
          ],
          'cols': 3,
          'kind': 'figure-matrix',
          'rows': 2,
        },
        semanticsLabel: 'Two rows showing a combination rule.',
      ),
    );

    figure = tester.widget<FigureMatrixFigure>(
      find.byType(FigureMatrixFigure),
    );
    expect(figure.cells[2]!.allLineDegrees, [90, 0]);
  });

  testWidgets('a teaching cube net can label faces and show the folded cube', (
    tester,
  ) async {
    await tester.pumpApp(
      const LessonFigureWidget(
        spec: {
          'cells': [
            [0, 1],
            [1, 0],
            [1, 1],
            [1, 2],
            [2, 1],
            [3, 1],
          ],
          'kind': 'cube-net',
          'labels': ['side', 'side', 'bottom', 'side', 'side', 'top'],
          'showFolded': true,
        },
        semanticsLabel: 'A labeled cube net beside a folded cube.',
      ),
    );

    final figure = tester.widget<CubeNetFigure>(find.byType(CubeNetFigure));
    expect(figure.labels[2], 'bottom');
    expect(figure.labels.last, 'top');
    expect(figure.showFolded, isTrue);
  });

  testWidgets('cylinder projection variants are real registered diagrams', (
    tester,
  ) async {
    for (final type in ['cylinder-shadow-above', 'cylinder-shadow-side']) {
      await tester.pumpApp(
        LessonFigureWidget(
          spec: {
            'kind': 'geometry-diagram',
            'labels': const ['Light', 'Shadow'],
            'type': type,
          },
          semanticsLabel: 'A cylinder casting a shadow.',
        ),
      );

      final figure = tester.widget<GeometryDiagramFigure>(
        find.byType(GeometryDiagramFigure),
      );
      expect(figure.type, type);
    }
  });

  testWidgets('paper lessons can show a rectangular unfolded result', (
    tester,
  ) async {
    await tester.pumpApp(
      const LessonFigureWidget(
        spec: {
          'at': 'interior',
          'cut': 'hole',
          'folds': ['vertical', 'horizontal', 'vertical'],
          'kind': 'paper-fold',
          'sheet': 'rectangle',
          'showUnfolded': true,
        },
        semanticsLabel: 'A rectangle folded three times and unfolded.',
      ),
    );

    final figure = tester.widget<PaperFoldFigure>(
      find.byType(PaperFoldFigure),
    );
    expect(figure.sheet, 'rectangle');
    expect(figure.showUnfolded, isTrue);
  });
}
