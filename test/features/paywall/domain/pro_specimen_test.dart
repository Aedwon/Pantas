import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/domain/pro_specimen.dart';

void main() {
  test('the specimen is authored and constant, never derived', () {
    expect(proSpecimen.panelName, 'Under pressure');
    expect(proSpecimen.leftLabel, 'practicing');
    expect(proSpecimen.rightLabel, 'under time');
    expect(proSpecimen.leftFigure, 68);
    expect(proSpecimen.rightFigure, 54);
    expect(proSpecimen.gapFigure, 14);
  });

  test('the gap is the difference between the two figures', () {
    expect(
      proSpecimen.gapFigure,
      proSpecimen.leftFigure - proSpecimen.rightFigure,
    );
  });

  test('the sentence uses natural American spelling', () {
    expect(
        proSpecimen.sentence,
        'You score 14 lower under time than when practicing. '
        'That is the biggest gap in your work.');
  });

  test('the sentence contains no em dash', () {
    expect(proSpecimen.sentence.contains('—'), isFalse);
  });
}
