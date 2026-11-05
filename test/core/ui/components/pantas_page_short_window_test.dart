import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';

import '../../../helpers/pump_app.dart';

// 3M-15: on a short window (200% zoom, a phone on its side) an onboarding
// step's actions move to the end of the content so the content keeps the
// height.
Future<void> _pump(
  WidgetTester tester, {
  required double height,
  bool pinBottom = false,
}) async {
  tester.view
    ..physicalSize = Size(720, height)
    ..devicePixelRatio = 1;
  addTearDown(() {
    tester.view
      ..resetPhysicalSize()
      ..resetDevicePixelRatio();
  });
  await tester.pumpApp(
    PantasPage.onboarding(
      title: 'Which exam?',
      progress: 3,
      onBack: () {},
      pinBottom: pinBottom,
      bottom: PantasButton(label: 'Continue', onPressed: () {}),
      children: [
        for (var i = 0; i < 4; i++)
          SizedBox(height: 120, child: Text('row $i')),
      ],
    ),
  );
  await tester.pump();
}

void main() {
  final inScroll = find.descendant(
    of: find.byType(SingleChildScrollView),
    matching: find.text('Continue'),
  );

  testWidgets('a tall window pins the actions under the content',
      (tester) async {
    await _pump(tester, height: 844);
    expect(inScroll, findsNothing);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('a short window puts the actions at the end of the content',
      (tester) async {
    await _pump(tester, height: 450);
    expect(inScroll, findsOneWidget);
    final last = tester.getBottomLeft(find.text('row 3', skipOffstage: false));
    final button =
        tester.getTopLeft(find.text('Continue', skipOffstage: false));
    expect(button.dy, greaterThan(last.dy));
  });

  testWidgets('a long list keeps its button pinned even on a short window',
      (tester) async {
    await _pump(tester, height: 450, pinBottom: true);
    expect(inScroll, findsNothing);
    expect(find.text('Continue'), findsOneWidget);
  });
}
