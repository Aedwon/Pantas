import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/figures/gear_train_figure.dart';
import 'package:pantas/core/ui/figures/question_figure.dart';

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
    };

    for (final entry in bad.entries) {
      testWidgets(entry.key, (tester) async {
        await tester.pumpApp(QuestionFigure(specJson: entry.value));

        expect(find.byType(GearTrainFigure), findsNothing);
        expect(
          find.textContaining('has not been drawn yet'),
          findsOneWidget,
          reason: 'a bad spec must say so rather than draw something',
        );
      });
    }
  });
}
