import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_dimensions.dart';

void main() {
  group('AppDimensions radii', () {
    test('radiusButton is 14', () => expect(AppDimensions.radiusButton, 14.0));
    test(
      'radiusSurface is 18',
      () => expect(AppDimensions.radiusSurface, 18.0),
    );
  });

  group('AppDimensions rules', () {
    test('hairline is 0.5', () => expect(AppDimensions.hairline, 0.5));
    test(
      'progressHeight is 3',
      () => expect(AppDimensions.progressHeight, 3.0),
    );
  });

  group('AppDimensions tap targets', () {
    test('minTapTarget is 44', () => expect(AppDimensions.minTapTarget, 44.0));
  });
}
