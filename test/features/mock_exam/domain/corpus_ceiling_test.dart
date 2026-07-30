import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/mock_exam/domain/corpus_ceiling.dart';

void main() {
  test('a paper the corpus can carry fits', () {
    expect(CheckCorpusFit.call(requested: 60, available: 60).fits, isTrue);
  });

  test('a paper larger than the corpus does not', () {
    final fit = CheckCorpusFit.call(requested: 150, available: 60);

    expect(fit.fits, isFalse);
    expect(fit.shortfall, 90);
  });

  test('a paper well inside the corpus leaves no shortfall', () {
    expect(CheckCorpusFit.call(requested: 20, available: 60).shortfall, 0);
  });

  test('the wheel reaches 240 whatever the corpus holds', () {
    expect(questionWheelCeiling, 240);
  });
}
