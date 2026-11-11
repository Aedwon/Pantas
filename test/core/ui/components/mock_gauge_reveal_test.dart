import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/half_ring_gauge.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('the mock reveal does not announce hidden score or caption',
      (tester) async {
    final semantics = tester.ensureSemantics();
    Widget gauge(double reveal) => MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: HalfRingGauge.mock(
            fraction: .684,
            label: '106 of 155 correct answers',
            numberOpacity: reveal,
            labelOpacity: reveal,
          ),
        );
    await tester.pumpApp(gauge(0));
    expect(
      find.bySemanticsLabel('106 of 155 correct answers 68.4 percent'),
      findsNothing,
    );
    await tester.pumpApp(gauge(1));
    expect(
      find.bySemanticsLabel('106 of 155 correct answers 68.4 percent'),
      findsOneWidget,
    );
    semantics.dispose();
  });
}
