import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppDimensions radii', () {
    test('radiusMD is 10', () => expect(AppDimensions.radiusMD, 10.0));
    test('radiusLG is 14', () => expect(AppDimensions.radiusLG, 14.0));
    test('radiusFull is 999', () => expect(AppDimensions.radiusFull, 999.0));
  });

  group('AppDimensions tap targets', () {
    test('minTapTarget is 48', () => expect(AppDimensions.minTapTarget, 48.0));
  });
}
