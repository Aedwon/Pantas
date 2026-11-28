import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/features/settings/presentation/carry_over_prompt.dart';
import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('transfer follows the board transform and fade after saving',
      (tester) async {
    await tester.pumpAppWithProviders(
      CarryOverScreen(exam: 'CSE', previous: 'UPCAT', onCounted: () {}),
    );
    await tester.ensureVisible(find.text('Count Them'));
    await tester.tap(find.text('Count Them'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    final transform = tester
        .widget<Transform>(find.byKey(const ValueKey('transfer-vessels')));
    expect(transform.transform.storage[13], closeTo(118, .01));
    final fade =
        tester.widget<Opacity>(find.byKey(const ValueKey('transfer-prompt')));
    expect(fade.opacity, 0);
    await tester.pump(const Duration(milliseconds: 2800));
    expect(find.text('You pick up where you are'), findsOneWidget);
  });
  testWidgets('the phone vessels are 34 radius with a 1.5 px ring and a wave',
      (tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpAppWithProviders(
      CarryOverScreen(exam: 'CSE', previous: 'UPCAT', onCounted: () {}),
    );
    await tester.ensureVisible(find.text('Count Them'));
    await tester.tap(find.text('Count Them'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    // Board ST_ExamSwitchCount: 104 by 168, radius 34, inset ring 1.5 px,
    // a wave on the rising fill.
    for (final name in ['old', 'new']) {
      expect(
        find.byKey(ValueKey('transfer-wave-$name')),
        findsOneWidget,
        reason: name,
      );
    }
    final vessels = find.byKey(const ValueKey('transfer-vessel'));
    expect(vessels, findsNWidgets(2));
    for (final vessel in tester.widgetList<Container>(vessels)) {
      final box = vessel.decoration! as BoxDecoration;
      expect(box.borderRadius, BorderRadius.circular(34));
      final ring = (vessel.foregroundDecoration! as BoxDecoration).border!;
      expect(ring.top.width, 1.5);
    }
  });
  testWidgets(
      'issue 26: carry over opens once as a screen and stays '
      'closed after returning', (tester) async {
    bool? result;
    await tester.pumpAppWithProviders(
      Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            result = await showCarryOverPrompt(
              context: context,
              examShortName: 'CSE Professional',
              carryableCount: 3,
            );
          },
          child: const Text('Switch'),
        ),
      ),
    );
    await tester.tap(find.text('Switch'));
    await tester.pumpAndSettle();
    expect(find.text('Count Them'), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(PantasButton), findsWidgets);
    await tester.ensureVisible(find.text('Start My Numbers Fresh'));
    await tester.tap(find.text('Start My Numbers Fresh'));
    await tester.pumpAndSettle();
    expect(result, isFalse);
    expect(find.text("You're not starting from zero"), findsNothing);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text("You're not starting from zero"), findsNothing);
  });
  testWidgets('the two stacked buttons sit 8 px apart (ST_ExamSwitch, U11)',
      (tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpAppWithProviders(
      CarryOverScreen(exam: 'CSE', previous: 'UPCAT', onCounted: () {}),
    );
    await tester.pumpAndSettle();
    Rect buttonOf(String label) => tester.getRect(
          find.ancestor(
            of: find.text(label),
            matching: find.byType(PantasButton),
          ),
        );
    expect(
      buttonOf('Start My Numbers Fresh').top - buttonOf('Count Them').bottom,
      8,
    );
  });
  test('the route finds the prompt when the web router has dropped its extra',
      () async {
    // The web router stores a pushed route's extra as JSON. An object holding
    // callbacks comes back as null when the exam change makes it rebuild.
    expect(carryOverRequestFor(null), isNull);
    final request = CarryOverRequest(exam: 'CSE Sub', onCounted: () {});
    expect(carryOverRequestFor(request), same(request));
    pendingCarryOverRequest = request;
    addTearDown(() => pendingCarryOverRequest = null);
    expect(carryOverRequestFor(null), same(request));
  });
  testWidgets('the prompt keeps the board copy, with no figure',
      (tester) async {
    await tester.pumpAppWithProviders(
      CarryOverScreen(
        exam: 'CSE Sub',
        previous: 'CSE Pro',
        count: 245,
        onCounted: () {},
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Some content on CSE Pro is on CSE Sub too.'),
      findsOneWidget,
    );
    expect(find.textContaining('245'), findsNothing);
  });
}
