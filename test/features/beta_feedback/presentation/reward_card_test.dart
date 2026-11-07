import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/beta_feedback/domain/beta_feedback_models.dart';
import 'package:pantas/features/beta_feedback/presentation/fb_kit.dart';
import 'package:pantas/features/beta_feedback/presentation/feedback_page.dart';

import 'beta_feedback_fakes.dart';
import 'feedback_harness.dart';

const _page = FeedbackPage(frame: testFrame);

final _now = ph(11, 16, 9);

BetaReward _eligible() => fakeReward(
      days: betaDays.take(5).toList(),
      surveySubmitted: true,
      eligible: true,
    );

BetaReward _activated() => fakeReward(
      days: betaDays.take(5).toList(),
      surveySubmitted: true,
      activatedAt: ph(11, 20),
      rewardStartsAt: ph(11, 20),
      rewardEndsAt: ph(11, 20, 12, 0, 2027),
    );

FbHarness _harness({
  BetaReward? reward,
  bool wide = false,
  bool dark = false,
  bool reduceMotion = false,
  FakeBetaFeedbackApi? api,
}) =>
    FbHarness(
      wide: wide,
      dark: dark,
      reduceMotion: reduceMotion,
      now: _now,
      api: api ?? FakeBetaFeedbackApi(reward: reward ?? _eligible()),
    );

Finder get _activate => find.text('Activate 1 Year of Pro');

double _monthScale(WidgetTester tester, int j) => tester
    .widget<Transform>(find.byKey(ValueKey('month-fill-$j')))
    .transform
    .entry(0, 0);

void main() {
  group('eligible', () {
    testWidgets('phone: the reward card sits above a shorter days card',
        (tester) async {
      final h = _harness();
      final semantics = tester.ensureSemantics();
      await h.pump(tester, _page);
      expect(find.text('You earned 1 year of Pro'), findsOneWidget);
      expect(
        find.text(
          'Thank you for testing Pantas. Turn it on whenever you are ready.',
        ),
        findsOneWidget,
      );
      expect(_activate, findsOneWidget);
      expect(
        find.text(
          'Activate by Dec 31, 2027. The year covers every exam. '
          'If you have paid Pro, the year starts when it ends.',
        ),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('12 months of Pro, not turned on yet'),
        findsOneWidget,
      );
      // The twelve months start with the current one: N D J F M A M J J A S O.
      expect(find.text('N'), findsOneWidget);
      expect(find.text('O'), findsOneWidget);
      // The days card keeps only its count and strip.
      expect(find.text('5 of 5 days'), findsOneWidget);
      expect(
        find.text('A day counts when you finish your whole Today plan.'),
        findsNothing,
      );
      expect(find.textContaining('Count 5 days from'), findsNothing);
      expect(find.text('Sent'), findsOneWidget);
      // Missed days show their date.
      expect(find.text('14'), findsOneWidget);
      // The feedback box stays below.
      expect(find.text('SEND FEEDBACK'), findsOneWidget);
      final reward =
          tester.getTopLeft(find.text('You earned 1 year of Pro')).dy;
      final days = tester.getTopLeft(find.text('5 of 5 days')).dy;
      expect(reward, lessThan(days));
      semantics.dispose();
    });

    testWidgets('wide: the board wording and three-letter months',
        (tester) async {
      final h = _harness(wide: true);
      await h.pump(tester, _page);
      expect(
        find.text(
          'Activate by Dec 31, 2027. If you have paid Pro, '
          'the year starts when it ends.',
        ),
        findsOneWidget,
      );
      expect(find.text('Nov'), findsOneWidget);
      expect(find.text('Oct'), findsOneWidget);
      expect(
        tester.getSize(find.byKey(const ValueKey('activate-button'))).width,
        greaterThanOrEqualTo(214),
      );
    });

    testWidgets('the card pieces rise in one after the other', (tester) async {
      final h = _harness();
      await h.pump(tester, _page, settle: false);
      await tester.pump();
      double opacityOf(String text) => tester
          .widgetList<Opacity>(
            find.ancestor(of: find.text(text), matching: find.byType(Opacity)),
          )
          .map((o) => o.opacity)
          .reduce((a, b) => a < b ? a : b);
      expect(opacityOf('You earned 1 year of Pro'), 0);
      await tester.pump(const Duration(milliseconds: 250));
      expect(opacityOf('You earned 1 year of Pro'), greaterThan(0));
      expect(opacityOf('Activate 1 Year of Pro'), lessThan(1));
      await tester.pumpAndSettle();
      expect(opacityOf('Activate 1 Year of Pro'), 1);
    });

    testWidgets('days under the card do not pop on the phone', (tester) async {
      final h = _harness();
      await h.pump(tester, _page);
      expect(find.byType(FbPop), findsNothing);
    });

    testWidgets('days under the card pop on wide, 60 ms apart', (tester) async {
      final h = _harness(wide: true);
      await h.pump(tester, _page, settle: false);
      await tester.pump();
      expect(find.byType(FbPop), findsNWidgets(5));
      await tester.pumpAndSettle();
    });

    testWidgets('the days card shows the count in 17 px', (tester) async {
      final h = _harness();
      await h.pump(tester, _page);
      final text = tester.widget<Text>(find.text('5 of 5 days'));
      expect(text.style!.fontSize, 17);
      expect(text.style!.fontWeight, FontWeight.w600);
    });
  });

  group('activating', () {
    testWidgets('a spinner, then the on state, rolled in', (tester) async {
      final gate = Completer<BetaRewardActivation>();
      final api = FakeBetaFeedbackApi(reward: _eligible())..activateGate = gate;
      final h = _harness(api: api);
      await h.pump(tester, _page);
      await tester.tap(_activate);
      await tester.pump();
      expect(find.byType(FbSpinner), findsOneWidget);
      expect(api.activations, 1);
      // A second tap while it works does nothing.
      await tester.tap(
        find.byKey(const ValueKey('activate-button')),
        warnIfMissed: false,
      );
      expect(api.activations, 1);

      gate.complete(
        BetaRewardActivation(
          startsAt: ph(11, 20),
          endsAt: ph(11, 20, 12, 0, 2027),
        ),
      );
      await tester.pump();
      await tester.pump();
      // Part way: the months fill from the left, one after the other.
      await tester.pump(const Duration(milliseconds: 400));
      expect(_monthScale(tester, 0), greaterThan(0));
      expect(_monthScale(tester, 11), 0);
      await tester.pumpAndSettle();

      expect(find.text('Pro is on until Nov 20, 2027'), findsOneWidget);
      expect(
        find.text('Turned on Nov 20, 2026. Every exam is included.'),
        findsOneWidget,
      );
      expect(find.text('Thank you for testing Pantas.'), findsOneWidget);
      expect(
        find.text('After Nov 20, 2027, your account goes back to Free.'),
        findsOneWidget,
      );
      expect(_activate, findsNothing);
      for (var j = 0; j < 12; j++) {
        expect(_monthScale(tester, j), 1);
      }
      final old = tester.widget<Opacity>(
        find.byKey(const ValueKey('title-earned')),
      );
      expect(old.opacity, 0);
    });

    testWidgets('the crown swings once', (tester) async {
      final h = _harness();
      await h.pump(tester, _page);
      double angle() => tester
          .widget<Transform>(find.byKey(const ValueKey('crown')))
          .transform
          .entry(0, 1);
      expect(angle(), 0);
      await tester.tap(_activate);
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      // 150 ms into the swing: part way to its first lean.
      expect(angle(), isNot(0));
      await tester.pumpAndSettle();
      expect(angle(), closeTo(0, 1e-9));
    });

    testWidgets('a failure names the problem and brings the button back',
        (tester) async {
      final api = FakeBetaFeedbackApi(reward: _eligible())
        ..activateError =
            const BetaFeedbackException(BetaFeedbackFailure.other);
      final h = _harness(api: api);
      await h.pump(tester, _page);
      await tester.tap(_activate);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Could not turn it on. Try again.'), findsOneWidget);
      expect(_activate, findsOneWidget);
      expect(find.byType(FbSpinner), findsNothing);
      expect(find.text('You earned 1 year of Pro'), findsOneWidget);
    });

    testWidgets('reduced motion: the on state is there at once',
        (tester) async {
      final h = _harness(reduceMotion: true);
      await h.pump(tester, _page);
      await tester.tap(_activate);
      await tester.pump();
      await tester.pump();
      expect(find.text('Pro is on until Nov 20, 2027'), findsOneWidget);
      expect(_activate, findsNothing);
      for (var j = 0; j < 12; j++) {
        expect(_monthScale(tester, j), 1);
      }
      expect(
        tester
            .widget<Transform>(find.byKey(const ValueKey('crown')))
            .transform
            .entry(0, 1),
        0,
      );
    });
  });

  group('activated', () {
    testWidgets('a revisit shows the on state still, with no motion',
        (tester) async {
      final h = _harness(reward: _activated());
      await h.pump(tester, _page, settle: false);
      await tester.pump();
      expect(find.text('Pro is on until Nov 20, 2027'), findsOneWidget);
      expect(
        find.text('Turned on Nov 20, 2026. Every exam is included.'),
        findsOneWidget,
      );
      expect(_activate, findsNothing);
      for (var j = 0; j < 12; j++) {
        expect(_monthScale(tester, j), 1);
      }
      expect(
        find.text('After Nov 20, 2027, your account goes back to Free.'),
        findsOneWidget,
      );
    });

    testWidgets('the months start at the reward start month', (tester) async {
      final reward = fakeReward(
        days: betaDays.take(5).toList(),
        surveySubmitted: true,
        activatedAt: ph(12, 2),
        rewardStartsAt: ph(12, 2),
        rewardEndsAt: ph(12, 2, 12, 0, 2027),
      );
      final h = _harness(reward: reward, wide: true);
      await h.pump(tester, _page);
      final labels = tester
          .widgetList<Text>(find.byKey(const ValueKey('month-label-0')))
          .map((t) => t.data);
      expect(labels, ['Dec']);
    });
  });

  group('not eligible', () {
    testWidgets('five days but the deadline passed: the ordinary card',
        (tester) async {
      final h = _harness(
        reward: fakeReward(days: betaDays.take(5).toList()),
      );
      await h.pump(tester, _page);
      expect(find.text('You earned 1 year of Pro'), findsNothing);
      expect(find.text('5 of 5 days'), findsOneWidget);
      expect(
        find.text('A day counts when you finish your whole Today plan.'),
        findsOneWidget,
      );
    });
  });

  for (final dark in [false, true]) {
    for (final wide in [false, true]) {
      testWidgets('builds without errors (dark: $dark, wide: $wide)',
          (tester) async {
        final h = _harness(dark: dark, wide: wide);
        await h.pump(tester, _page);
        await tester.tap(_activate);
        await tester.pumpAndSettle();
        expect(find.text('Pro is on until Nov 20, 2027'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
