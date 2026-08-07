import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/figures/fluid_vessel_figure.dart';
import 'package:pantas/core/ui/figures/gear_train_figure.dart';
import 'package:pantas/core/ui/figures/lever_balance_figure.dart';
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
        expect(
          find.textContaining('has not been drawn yet'),
          findsOneWidget,
          reason: 'a bad spec must say so rather than draw something',
        );
      });
    }
  });
}
