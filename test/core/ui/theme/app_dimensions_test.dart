import 'package:pantas/core/ui/theme/app_dimensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppDimensions radii', () {
    test('radiusButton is 5', () => expect(AppDimensions.radiusButton, 5.0));
    test('radiusSurface is 8', () => expect(AppDimensions.radiusSurface, 8.0));
  });

  group('AppDimensions rules', () {
    test('hairline is 1', () => expect(AppDimensions.hairline, 1.0));
    test(
      'progressHeight is 3',
      () => expect(AppDimensions.progressHeight, 3.0),
    );
  });

  group('AppDimensions tap targets', () {
    test('minTapTarget is 48', () => expect(AppDimensions.minTapTarget, 48.0));
  });
}
