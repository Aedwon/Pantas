import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/floating_bar.dart';

import '../../../helpers/accessibility.dart';

void main() {
  testWidgets('QN_Report form surface uses a 24 radius and keeps child metrics',
      (tester) async {
    await pumpAccessibilitySurface(
      tester,
      const FloatingBar.content(
        radius: 24,
        inset: 0,
        child: SizedBox(height: 250, child: Text('Report form')),
      ),
      viewportSize: const Size(390, 844),
    );
    final surface =
        tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
    expect(
      (surface.decoration! as BoxDecoration).borderRadius,
      BorderRadius.circular(24),
    );
    expect(tester.getSize(find.byType(FloatingBar)).height, 250);
  });
}
