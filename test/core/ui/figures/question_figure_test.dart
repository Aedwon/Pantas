import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/figures/chart_figure.dart';
import 'package:pantas/core/ui/figures/concept_diagram_figure.dart';
import 'package:pantas/core/ui/figures/coordinate_graph_figure.dart';
import 'package:pantas/core/ui/figures/cube_net_figure.dart';
import 'package:pantas/core/ui/figures/figure_matrix_figure.dart';
import 'package:pantas/core/ui/figures/figure_series_figure.dart';
import 'package:pantas/core/ui/figures/fluid_vessel_figure.dart';
import 'package:pantas/core/ui/figures/gear_train_figure.dart';
import 'package:pantas/core/ui/figures/geometry_diagram_figure.dart';
import 'package:pantas/core/ui/figures/lever_balance_figure.dart';
import 'package:pantas/core/ui/figures/paper_fold_figure.dart';
import 'package:pantas/core/ui/figures/pulley_system_figure.dart';
import 'package:pantas/core/ui/figures/question_figure.dart';
import 'package:pantas/core/ui/figures/shape_row_figure.dart';
import 'package:pantas/core/ui/figures/spring_scale_figure.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('no spec draws nothing at all', (tester) async {
    await tester.pumpApp(const QuestionFigure(specJson: null));

    expect(find.byType(GearTrainFigure), findsNothing);
    expect(find.textContaining('diagram'), findsNothing);
  });

  testWidgets('a gear train spec draws the gears', (tester) async {
    await tester.pumpApp(
      const QuestionFigure(
        specJson: '{"kind":"gear-train","gears":3,"firstTurns":"clockwise"}',
      ),
    );

    expect(find.byType(GearTrainFigure), findsOneWidget);
    final figure = tester.widget<GearTrainFigure>(
      find.byType(GearTrainFigure),
    );
    expect(figure.gears, 3);
    expect(figure.firstTurnsClockwise, isTrue);
  });

  testWidgets('the question wrapper reaches all four new registry kinds', (
    tester,
  ) async {
    const cases = <(String, Type)>[
      (
        '{"kind":"coordinate-graph","type":"parabola",'
            '"formula":"y=x^2","points":[[0,0],[1,1]]}',
        CoordinateGraphFigure,
      ),
      (
        '{"kind":"geometry-diagram","type":"triangle",'
            '"labels":["A","B","C"]}',
        GeometryDiagramFigure,
      ),
      (
        '{"kind":"chart","type":"bar","labels":["A","B"],'
            '"values":[1,2]}',
        ChartFigure,
      ),
      (
        '{"kind":"concept-diagram","type":"sequence",'
            '"nodes":["A","B"],"edges":[[0,1]]}',
        ConceptDiagramFigure,
      ),
    ];

    for (final entry in cases) {
      await tester.pumpApp(QuestionFigure(specJson: entry.$1));
      expect(find.byType(entry.$2), findsOneWidget);
    }
  });

  testWidgets('tooth counts size the gears and are never printed',
      (tester) async {
    await tester.pumpApp(
      const QuestionFigure(
        specJson: '{"kind":"gear-train","gears":2,"firstTurns":"clockwise",'
            '"teeth":[10,30]}',
      ),
    );

    final figure = tester.widget<GearTrainFigure>(
      find.byType(GearTrainFigure),
    );
    expect(figure.teeth, [10, 30]);
    // The counts are sizes, not labels. A number on a drawing would be a
    // figure this project never measured.
    expect(find.text('10'), findsNothing);
    expect(find.text('30'), findsNothing);
  });

  testWidgets('two springs draw side by side with their own labels',
      (tester) async {
    await tester.pumpApp(
      const QuestionFigure(
        specJson: '{"kind":"spring-scale","springs":['
            '{"label":"A","stretch":3},{"label":"B","stretch":8}]}',
      ),
    );

    final figure = tester.widget<SpringScaleFigure>(
      find.byType(SpringScaleFigure),
    );
    expect(figure.springs, hasLength(2));
    expect(figure.springs.first.label, 'A');
    expect(figure.springs.last.stretch, 8);
  });

  testWidgets('a lever puts the fulcrum where the distances put it',
      (tester) async {
    await tester.pumpApp(
      const QuestionFigure(
        specJson: '{"kind":"lever-balance","loadDistance":2,'
            '"effortDistance":5}',
      ),
    );

    final figure = tester.widget<LeverBalanceFigure>(
      find.byType(LeverBalanceFigure),
    );
    expect(figure.loadDistance, 2);
    expect(figure.effortDistance, 5);
    // The distances are in metres in the stem. Printing them on the drawing
    // would be a figure this app never measured.
    expect(find.text('2'), findsNothing);
    expect(find.text('5'), findsNothing);
  });

  testWidgets('a pulley system tells fixed from movable', (tester) async {
    await tester.pumpApp(
      const QuestionFigure(
        specJson: '{"kind":"pulley-system","fixed":1,"movable":2}',
      ),
    );

    final figure = tester.widget<PulleySystemFigure>(
      find.byType(PulleySystemFigure),
    );
    expect(figure.fixed, 1);
    expect(figure.movable, 2);
  });

  testWidgets('a fluid vessel reads its shape and its marked points',
      (tester) async {
    await tester.pumpApp(
      const QuestionFigure(
        specJson: '{"kind":"fluid-vessel","vessel":"column",'
            '"points":["X","Y","Z"]}',
      ),
    );

    final figure = tester.widget<FluidVesselFigure>(
      find.byType(FluidVesselFigure),
    );
    expect(figure.vessel, 'column');
    expect(figure.points, ['X', 'Y', 'Z']);
  });

  testWidgets('a pipe carries the width of each section', (tester) async {
    await tester.pumpApp(
      const QuestionFigure(
        specJson: '{"kind":"fluid-vessel","vessel":"pipe","widths":[3,1,3]}',
      ),
    );

    final figure = tester.widget<FluidVesselFigure>(
      find.byType(FluidVesselFigure),
    );
    expect(figure.widths, [3, 1, 3]);
  });

  testWidgets('a shape row keeps the order and never marks the odd one',
      (tester) async {
    await tester.pumpApp(
      const QuestionFigure(
        specJson: '{"kind":"shape-row","shapes":[{"form":"square"},'
            '{"form":"rectangle"},{"form":"rhombus"},{"form":"triangle"}]}',
      ),
    );

    final figure = tester.widget<ShapeRowFigure>(find.byType(ShapeRowFigure));
    expect(
      figure.shapes.map((s) => s.form),
      ['square', 'rectangle', 'rhombus', 'triangle'],
    );
    // Nothing in the drawing says which one is the answer. Finding it is
    // the question.
    expect(find.textContaining('does not belong'), findsNothing);
  });

  testWidgets('a series ends in a blank the answer is not drawn into',
      (tester) async {
    await tester.pumpApp(
      const QuestionFigure(
        specJson: '{"kind":"figure-series","items":['
            '{"form":"square","line":0},{"form":"square","line":45},'
            '{"form":"square","line":90}],"blank":true}',
      ),
    );

    final figure = tester.widget<FigureSeriesFigure>(
      find.byType(FigureSeriesFigure),
    );
    expect(figure.items, hasLength(3));
    expect(figure.blank, isTrue);
    // Three drawn figures and one empty frame. The fourth is what the
    // student works out, so nothing may draw it.
    expect(figure.items.last.lineDegrees, 90);
  });

  testWidgets('a part-filled figure keeps its fraction', (tester) async {
    await tester.pumpApp(
      const QuestionFigure(
        specJson: '{"kind":"figure-series","items":['
            '{"form":"circle","fill":0.25},{"form":"circle","fill":0.5}]}',
      ),
    );

    final figure = tester.widget<FigureSeriesFigure>(
      find.byType(FigureSeriesFigure),
    );
    expect(figure.items.first.fill, 0.25);
  });

  testWidgets('a matrix has exactly one blank and it is empty', (tester) async {
    await tester.pumpApp(
      const QuestionFigure(
        specJson: '{"kind":"figure-matrix","rows":2,"cols":2,"cells":['
            '{"form":"triangle"},{"form":"triangle","line":90},'
            '{"form":"square"},"blank"]}',
      ),
    );

    final figure = tester.widget<FigureMatrixFigure>(
      find.byType(FigureMatrixFigure),
    );
    expect(figure.cells, hasLength(4));
    expect(figure.cells.where((c) => c == null), hasLength(1));
    expect(figure.cells.last, isNull);
  });

  testWidgets('a folded paper never draws the unfolded result', (tester) async {
    await tester.pumpApp(
      const QuestionFigure(
        specJson: '{"kind":"paper-fold","folds":["vertical","horizontal"],'
            '"cut":"hole","at":"corner"}',
      ),
    );

    final figure = tester.widget<PaperFoldFigure>(
      find.byType(PaperFoldFigure),
    );
    expect(figure.folds, ['vertical', 'horizontal']);
    expect(figure.cut, 'hole');
    expect(figure.at, 'corner');
  });

  testWidgets('a cube net draws the squares and says nothing about folding',
      (tester) async {
    await tester.pumpApp(
      const QuestionFigure(
        specJson: '{"kind":"cube-net","cells":[[0,1],[1,0],[1,1],[1,2],'
            '[2,1],[3,1]]}',
      ),
    );

    final figure = tester.widget<CubeNetFigure>(find.byType(CubeNetFigure));
    expect(figure.cells, hasLength(6));
    // Whether it folds into a cube is the question. Nothing in the drawing
    // may hint either way.
    expect(find.textContaining('cube'), findsNothing);
  });

  group('a spec it cannot read says so and draws nothing plausible', () {
    const bad = <String, String>{
      'not JSON': 'gears: 3',
      'not a map': '[1, 2, 3]',
      'no kind': '{"gears":3}',
      'unknown kind': '{"kind":"submarine"}',
      'too few gears': '{"kind":"gear-train","gears":1,'
          '"firstTurns":"clockwise"}',
      'direction is nonsense': '{"kind":"gear-train","gears":3,'
          '"firstTurns":"widdershins"}',
      'teeth do not match the count': '{"kind":"gear-train","gears":3,'
          '"firstTurns":"clockwise","teeth":[10,30]}',
      'a spring with no stretch': '{"kind":"spring-scale","springs":'
          '[{"label":"A"}]}',
      'a spring list that is empty': '{"kind":"spring-scale","springs":[]}',
      'a negative stretch': '{"kind":"spring-scale","springs":'
          '[{"stretch":-3}]}',
      'a lever with no distances': '{"kind":"lever-balance"}',
      'a lever with a zero distance': '{"kind":"lever-balance",'
          '"loadDistance":0,"effortDistance":5}',
      'a pulley system with no pulleys': '{"kind":"pulley-system",'
          '"fixed":0,"movable":0}',
      'a vessel shape nobody drew': '{"kind":"fluid-vessel",'
          '"vessel":"aquarium"}',
      'a pipe with no widths': '{"kind":"fluid-vessel","vessel":"pipe"}',
      'a pipe with one section': '{"kind":"fluid-vessel","vessel":"pipe",'
          '"widths":[3]}',
      'a shape nobody drew': '{"kind":"shape-row","shapes":'
          '[{"form":"dodecahedron"},{"form":"square"}]}',
      'a row of one shape': '{"kind":"shape-row","shapes":'
          '[{"form":"square"}]}',
      'a series with one item': '{"kind":"figure-series","items":'
          '[{"form":"square"}]}',
      'a fill outside nought to one': '{"kind":"figure-series","items":'
          '[{"form":"circle","fill":1.4},{"form":"circle"}]}',
      'a corner nobody has': '{"kind":"figure-series","items":'
          '[{"form":"square","dot":"middle"},{"form":"square"}]}',
      'a matrix with two blanks': '{"kind":"figure-matrix","rows":2,'
          '"cols":2,"cells":[{"form":"square"},"blank",'
          '{"form":"square"},"blank"]}',
      'a matrix with no blank': '{"kind":"figure-matrix","rows":2,"cols":2,'
          '"cells":[{"form":"square"},{"form":"square"},'
          '{"form":"square"},{"form":"square"}]}',
      'a matrix whose cells do not fill it': '{"kind":"figure-matrix",'
          '"rows":3,"cols":3,"cells":[{"form":"square"},"blank"]}',
      'a fold nobody makes': '{"kind":"paper-fold","folds":["diagonal"]}',
      'a paper folded no times': '{"kind":"paper-fold","folds":[]}',
      'a cut nobody makes': '{"kind":"paper-fold","folds":["vertical"],'
          '"cut":"shred"}',
      'a net with a repeated cell': '{"kind":"cube-net","cells":'
          '[[0,0],[0,0]]}',
      'a net cell that is not a pair': '{"kind":"cube-net","cells":'
          '[[0,0,1],[1,1]]}',
      'a coordinate graph with no type': '{"kind":"coordinate-graph"}',
      'a geometry diagram with no labels': '{"kind":"geometry-diagram",'
          '"type":"triangle"}',
      'a chart with mismatched values': '{"kind":"chart","type":"bar",'
          '"labels":["A"],"values":[1,2]}',
      'a concept edge outside its nodes': '{"kind":"concept-diagram",'
          '"type":"sequence","nodes":["A","B"],"edges":[[0,2]]}',
    };

    for (final entry in bad.entries) {
      testWidgets(entry.key, (tester) async {
        await tester.pumpApp(QuestionFigure(specJson: entry.value));

        expect(find.byType(GearTrainFigure), findsNothing);
        expect(find.byType(SpringScaleFigure), findsNothing);
        expect(find.byType(LeverBalanceFigure), findsNothing);
        expect(find.byType(PulleySystemFigure), findsNothing);
        expect(find.byType(FluidVesselFigure), findsNothing);
        expect(find.byType(ShapeRowFigure), findsNothing);
        expect(find.byType(FigureSeriesFigure), findsNothing);
        expect(find.byType(FigureMatrixFigure), findsNothing);
        expect(find.byType(PaperFoldFigure), findsNothing);
        expect(find.byType(CubeNetFigure), findsNothing);
        expect(find.byType(CoordinateGraphFigure), findsNothing);
        expect(find.byType(GeometryDiagramFigure), findsNothing);
        expect(find.byType(ChartFigure), findsNothing);
        expect(find.byType(ConceptDiagramFigure), findsNothing);
        expect(
          find.textContaining('has not been drawn yet'),
          findsOneWidget,
          reason: 'a bad spec must say so rather than draw something',
        );
      });
    }
  });
}
