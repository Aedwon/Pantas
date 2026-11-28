// The new mark of a solution figure draws in after the figure arrives:
// spec "Motion values", 240 ms after the 240 ms arrival, on the shared ease.
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/figure_highlight.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';

void main() {
  test('nothing draws while the solution figure is still arriving', () {
    expect(markDrawProgress(Duration.zero), 0);
    expect(markDrawProgress(const Duration(milliseconds: 239)), 0);
    expect(markDrawProgress(const Duration(milliseconds: 240)), 0);
  });

  test('then it draws over 240 ms on the shared ease', () {
    expect(
      markDrawProgress(const Duration(milliseconds: 360)),
      closeTo(PantasCurves.move.transform(.5), 1e-9),
    );
    expect(markDrawProgress(const Duration(milliseconds: 480)), 1);
    expect(markDrawProgress(const Duration(seconds: 2)), 1);
  });

  test('with reduced motion there is no draw-in', () {
    expect(markDrawProgress(Duration.zero, reduced: true), 1);
  });
}
