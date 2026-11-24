import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/beta_feedback/presentation/reward_page.dart';

import 'beta_feedback_fakes.dart';
import 'feedback_harness.dart';

const _page = RewardPage(frame: testFrame);

final _now = ph(11, 26, 9);

Map<String, WidgetBuilder> get _routes => {
      '/home': (_) => const Scaffold(body: Text('home page')),
    };

void main() {
  testWidgets('a tester with an earned reward reaches the card and activates',
      (tester) async {
    final api = FakeBetaFeedbackApi(
      reward: fakeReward(
        days: betaDays.take(5).toList(),
        surveySubmitted: true,
        eligible: true,
      ),
    );
    await FbHarness(api: api, now: _now).pump(tester, _page);
    expect(find.text('You earned 1 year of Pro'), findsOneWidget);
    await tester.tap(find.text('Activate 1 Year of Pro'));
    await tester.pumpAndSettle();
    expect(api.activations, 1);
    expect(find.text('Pro is on until Nov 20, 2027'), findsOneWidget);
  });

  testWidgets('a tester with nothing to turn on goes back to Home',
      (tester) async {
    final api = FakeBetaFeedbackApi(
      reward: fakeReward(days: betaDays.take(5).toList()),
    );
    await FbHarness(api: api, now: _now).pump(
      tester,
      _page,
      routes: _routes,
    );
    expect(find.text('You earned 1 year of Pro'), findsNothing);
    expect(find.textContaining('of 5 days'), findsNothing);
    expect(find.text('SEND FEEDBACK'), findsNothing);
    expect(find.text('home page'), findsOneWidget);
  });

  testWidgets('the card is a skeleton while the status loads', (tester) async {
    final gate = Completer<void>();
    final api = FakeBetaFeedbackApi(rewardGate: gate);
    await FbHarness(api: api, now: _now).pump(tester, _page, settle: false);
    await tester.pump();
    expect(find.text('You earned 1 year of Pro'), findsNothing);
    expect(find.text('home page'), findsNothing);
    gate.complete();
    await tester.pumpAndSettle();
  });
}
