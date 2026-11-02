import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/web/web_components.dart';

import '../../../helpers/onboarding_steps_harness.dart';

// ignore_for_file: cascade_invocations

/// Aedwon, Nov 2, 2026: on a long step the action row stays in the window.
void main() {
  setUpAll(loadGeist);

  Finder continueButton() => find.widgetWithText(WebButton, 'Continue');
  ScrollPosition position(WidgetTester tester) =>
      tester.state<ScrollableState>(find.byType(Scrollable).first).position;
  Rect lastExamRow(WidgetTester tester) {
    final rows = find
        .byWidgetPredicate((w) => w.key.toString().contains("'exam-exam_"))
        .evaluate()
        .map((e) => tester.getRect(find.byWidget(e.widget)))
        .toList()
      ..sort((a, b) => a.bottom.compareTo(b.bottom));
    return rows.last;
  }

  testWidgets('a long picker keeps Continue inside the window', (tester) async {
    await pumpFramedStep(tester, 'picker', wide: true);
    const window = Rect.fromLTWH(0, 0, 1440, 900);
    expect(position(tester).maxScrollExtent, greaterThan(0));
    final before = tester.getRect(continueButton());
    expect(window.contains(before.topLeft), isTrue);
    expect(window.contains(before.bottomRight), isTrue);
    position(tester).jumpTo(position(tester).maxScrollExtent);
    await tester.pump();
    final after = tester.getRect(continueButton());
    expect(window.contains(after.topLeft), isTrue);
    expect(window.contains(after.bottomRight), isTrue);
    expect(lastExamRow(tester).bottom, lessThanOrEqualTo(after.top));
    // The row holds the same place at the end of the list as it did before.
    expect(after.right, before.right);
  });

  testWidgets('the pinned Continue still takes taps and Enter', (tester) async {
    final picked = <String>[];
    await pumpFramedStep(tester, 'picker', wide: true, onPicked: picked.add);
    await tester.tap(find.byKey(const ValueKey('exam-exam_cse_pro')));
    await tester.pump();
    await tester.tap(continueButton());
    await tester.pump();
    expect(picked, ['exam_cse_pro']);
  });

  testWidgets('the wheel over the pinned row scrolls the list', (tester) async {
    await pumpFramedStep(tester, 'picker', wide: true);
    final at = tester.getCenter(continueButton()) + const Offset(-200, 0);
    final before = position(tester).pixels;
    final pointer = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(pointer.hover(at));
    await tester.sendEventToBinding(pointer.scroll(const Offset(0, 120)));
    await tester.pump();
    expect(position(tester).pixels, greaterThan(before));
  });

  testWidgets('a taller window leaves the content where it was',
      (tester) async {
    await pumpFramedStep(tester, 'picker', wide: true);
    final row = find.byKey(const ValueKey('exam-exam_cse_pro'));
    final short = tester.getRect(row);
    tester.view.physicalSize = const Size(1440, 3000);
    await tester.pump();
    expect(tester.getRect(row), short);
    expect(position(tester).maxScrollExtent, 0);
  });

  testWidgets('a short step keeps the action right after the content',
      (tester) async {
    await pumpFramedStep(tester, 'age', wide: true);
    final short = tester.getRect(continueButton());
    tester.view.physicalSize = const Size(1440, 1400);
    await tester.pump();
    expect(tester.getRect(continueButton()), short);
    expect(short.bottom, lessThan(900 - 60));
  });
}
