import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_card.dart';

import '../../../helpers/accessibility.dart';

void main() {
  MockCard card(
    MockCardState state, {
    bool pro = false,
    bool paused = false,
    VoidCallback? action,
  }) =>
      MockCard(
        model: MockCardModel(
          state: state,
          name: 'UPCAT simulation',
          durationMinutes: 165,
          pro: pro,
          proPaused: paused,
          lastPercent: 69,
          lastAttemptAt: DateTime(2026, 9, 26),
          nextOpensAt: DateTime(2026, 10, 10),
          customQuestions: 120,
        ),
        onTake: action ?? () {},
        onResume: action ?? () {},
        onViewResults: action ?? () {},
        onSetUp: action ?? () {},
        onChangeSetup: action ?? () {},
      );

  for (final brightness in Brightness.values) {
    for (final state in MockCardState.values) {
      testWidgets('$brightness $state matches copy and survives 200%',
          (tester) async {
        final widget = SingleChildScrollView(
          child: Padding(padding: const EdgeInsets.all(16), child: card(state)),
        );
        await expectSurvivesTextScale(
          tester,
          widget,
          viewportSize: const Size(390, 844),
          brightness: brightness,
          disableAnimations: true,
        );
        expect(find.text('MOCK EXAM'), findsOneWidget);
        final expected = switch (state) {
          MockCardState.neverTaken => 'Take the Exam',
          MockCardState.ready => 'Take the Exam',
          MockCardState.waiting => 'View Last Results',
          MockCardState.inProgress => 'Resume',
          MockCardState.quizPaused => 'Finish your quiz session first.',
          MockCardState.customUnset => 'Set one up',
          MockCardState.customReady => 'Change the setup',
          MockCardState.unavailable => 'This exam has no mock paper ready yet.',
        };
        expect(find.text(expected), findsOneWidget);
        if (state == MockCardState.quizPaused ||
            state == MockCardState.unavailable) {
          expect(find.byType(PantasButton), findsNothing);
        }
      });
    }
    testWidgets('$brightness drawn metrics and real contrast', (tester) async {
      await pumpAccessibilitySurface(
        tester,
        SizedBox(width: 358, child: card(MockCardState.waiting)),
        brightness: brightness,
        viewportSize: const Size(390, 844),
        disableAnimations: true,
      );
      final title = tester.widget<Text>(find.text('UPCAT simulation'));
      expect(title.style!.fontSize, 20);
      expect(title.style!.fontWeight, FontWeight.w700);
      expect(title.style!.height, 1.35);
      expect(title.style!.letterSpacing, -.24);
      final score = tester.widget<Text>(find.text('69'));
      expect(score.style!.fontSize, 28);
      expect(score.style!.fontWeight, FontWeight.w700);
      expect(score.style!.height, 1.12);
      expect(score.style!.letterSpacing, -.56);
      final button = find.byType(TextButton);
      expect(tester.getSize(button).height, 48);
      expect(tester.getSize(button).width, 326);
      final top = tester.getTopLeft(find.text('UPCAT simulation'));
      final surface = find.byKey(const ValueKey('grouped-section-surface'));
      expect(top.dx - tester.getTopLeft(surface).dx, 16);
      expect(top.dy - tester.getTopLeft(surface).dy, 16);
      final rule = tester.widget<Text>(find.textContaining('Free includes'));
      expect(rule.style!.fontSize, 13);
      expect(rule.style!.height, 1.4);
      expect(
        find.text('Free includes one mock every 14 days. '
            'Your next one opens Sat, Oct 10.'),
        findsOneWidget,
      );
      await expectMeetsAccessibilityGuidelines(tester);
    });
  }

  testWidgets('Pro and paused coverage announce the actual state',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpAccessibilitySurface(
      tester,
      card(MockCardState.ready, pro: true),
      disableAnimations: true,
    );
    expect(
      find.text("You're on Pro. Take as many mocks as you like."),
      findsOneWidget,
    );
    await pumpAccessibilitySurface(
      tester,
      card(MockCardState.ready, paused: true),
      disableAnimations: true,
    );
    expect(find.text('Connect once to keep using Pro.'), findsOneWidget);
    expect(find.textContaining("You're on Pro"), findsNothing);
    expect(
      tester
          .getSemantics(find.byKey(const ValueKey('mock-card-state')))
          .getSemanticsData()
          .flagsCollection
          .isLiveRegion,
      isTrue,
    );
    semantics.dispose();
  });

  testWidgets('each action activates from the keyboard', (tester) async {
    for (final state in [
      MockCardState.neverTaken,
      MockCardState.waiting,
      MockCardState.inProgress,
      MockCardState.customUnset,
      MockCardState.customReady,
    ]) {
      var calls = 0;
      await pumpAccessibilitySurface(
        tester,
        card(state, action: () => calls++),
        disableAnimations: true,
      );
      final buttons =
          tester.widgetList<TextButton>(find.byType(TextButton)).toList();
      for (var i = 0; i < buttons.length; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
      }
      expect(calls, buttons.length);
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('entry matches board stops and intermediate curve',
      (tester) async {
    await pumpAccessibilitySurface(tester, card(MockCardState.ready));
    double opacity() => tester
        .widget<Opacity>(find.byKey(const ValueKey('mock-card-opacity')))
        .opacity;
    expect(opacity(), 0);
    await tester.pump(const Duration(milliseconds: 190));
    expect(opacity(), 0);
    await tester.pump(const Duration(milliseconds: 225));
    final progress = PantasCurves.houseOut.transform(.5);
    expect(opacity(), closeTo(progress, .001));
    final transform =
        tester.widget<Transform>(find.byKey(const ValueKey('mock-card-rise')));
    expect(transform.transform.storage[13], closeTo(12 * (1 - progress), .001));
    await tester.pump(const Duration(milliseconds: 225));
    expect(opacity(), 1);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });
}
