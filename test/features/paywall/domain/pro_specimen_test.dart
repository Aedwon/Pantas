import 'package:pantas/features/paywall/domain/pro_specimen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the specimen is authored and constant, never derived', () {
    expect(proSpecimen.panelName, 'Under pressure');
    expect(proSpecimen.leftLabel, 'practising');
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

  test('the sentence contains no em dash', () {
    expect(proSpecimen.sentence.contains('—'), isFalse);
  });
}
