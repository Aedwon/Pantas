import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/beta_feedback/domain/beta_feedback_models.dart';
import 'package:pantas/features/beta_feedback/presentation/exit_survey_page.dart';
import 'package:pantas/features/beta_feedback/presentation/fb_kit.dart';
import 'package:pantas/features/beta_feedback/presentation/survey_controls.dart';
import 'package:pantas/features/beta_feedback/presentation/survey_sent.dart';

import 'beta_feedback_fakes.dart';
import 'feedback_harness.dart';

const _page = ExitSurveyPage(frame: testFrame);

final _open = ph(11, 16, 9);

Map<String, WidgetBuilder> get _routes => {
      '/settings/beta-feedback': (_) =>
          const Scaffold(body: Text('feedback page')),
    };

FbHarness _harness({
  bool wide = false,
  bool dark = false,
  bool reduceMotion = false,
  DateTime? now,
  FakeBetaFeedbackApi? api,
}) =>
    FbHarness(
      wide: wide,
      dark: dark,
      reduceMotion: reduceMotion,
      now: now ?? _open,
      api: api ??
          FakeBetaFeedbackApi(
            reward: fakeReward(
              days: betaDays.take(5).toList(),
            ),
            sent: [
              fakeSent(
                'a',
                'The explanation is wrong.',
                ph(11, 11, 21, 41),
                images: 1,
              ),
              fakeSent('b', 'Sign-in code arrived fast.', ph(11, 9, 20, 12)),
              fakeSent('c', 'Today plan is good.', ph(11, 10, 7, 5)),
            ],
          ),
    );

Finder _key(String k) => find.byKey(ValueKey(k));

Future<void> _answerAll(WidgetTester tester) async {
  await tester.tap(_key('q1-1'));
  await tester.tap(_key('q2-4'));
  await tester.tap(_key('q3-5'));
  await tester.tap(_key('q4-0'));
  await tester.tap(_key('q5-9'));
  await tester.enterText(
    find.byKey(const ValueKey('q6-field')),
    'More Numerical Ability practice.',
  );
  await tester.pump();
}

bool _sendEnabled(WidgetTester tester) =>
    tester
        .widget<FbButton>(
          find.ancestor(
            of: find.text('Send Survey'),
            matching: find.byType(FbButton),
          ),
        )
        .onPressed !=
    null;

void main() {
  group('the form', () {
    testWidgets('phone: heading text, questions and the appeal line',
        (tester) async {
      final h = _harness();
      await h.pump(tester, _page, routes: _routes);
      expect(find.text('Exit Survey'), findsOneWidget);
      expect(
        find.text('7 questions. You can send it once, until Nov 22.'),
        findsOneWidget,
      );
      for (final q in [
        '1. How often did you use Pantas this week?',
        '2. How easy was Pantas to use?',
        '3. How useful was Pantas for your exam prep?',
        '4. Will you keep using Pantas after the beta?',
        '5. How likely are you to recommend Pantas to a friend?',
        '6. What should we improve most?',
      ]) {
        expect(find.text(q), findsOneWidget, reason: q);
      }
      expect(find.textContaining('7. Anything else'), findsOneWidget);
      for (final t in [
        'Every day',
        'Most days',
        'A few days',
        'Once',
        'Hard',
        'Easy',
        'Not useful',
        'Very useful',
        'Yes',
        'Maybe',
        'No',
        'Not likely',
        'Very likely',
      ]) {
        expect(find.text(t), findsWidgets, reason: t);
      }
      expect(
        find.text(
          'Think a day was missed? Email support@pantas.study by Nov 30.',
        ),
        findsOneWidget,
      );
      // Eleven pills, 0 to 10.
      for (var i = 0; i <= 10; i++) {
        expect(_key('q5-$i'), findsOneWidget);
      }
      expect(
        find.text('Look back at what you sent while you answer.'),
        findsOneWidget,
      );
      expect(find.text('Answer questions 1 to 6 to send.'), findsNothing);
      expect(find.textContaining('of 7'), findsNothing);
    });

    testWidgets('wide: the board wording for question 3, a progress bar',
        (tester) async {
      final h = _harness(wide: true);
      await h.pump(tester, _page, routes: _routes);
      expect(
        find.text('3. How useful was it for your exam?'),
        findsOneWidget,
      );
      expect(find.text('0 of 7'), findsOneWidget);
      expect(find.text('Answer questions 1 to 6 to send.'), findsOneWidget);
      expect(
        find.text('Look back at what you sent while you answer.'),
        findsNothing,
      );
    });

    testWidgets('Send Survey waits for questions 1 to 6', (tester) async {
      final h = _harness();
      await h.pump(tester, _page, routes: _routes);
      expect(_sendEnabled(tester), isFalse);
      await tester.tap(_key('q1-1'));
      await tester.tap(_key('q2-4'));
      await tester.tap(_key('q3-5'));
      await tester.tap(_key('q4-0'));
      await tester.tap(_key('q5-9'));
      await tester.pump();
      expect(_sendEnabled(tester), isFalse);
      await tester.enterText(find.byKey(const ValueKey('q6-field')), '   ');
      await tester.pump();
      expect(_sendEnabled(tester), isFalse);
      await tester.enterText(find.byKey(const ValueKey('q6-field')), 'Time');
      await tester.pump();
      expect(_sendEnabled(tester), isTrue);
    });

    testWidgets('wide: progress counts answers, and question 7 when filled',
        (tester) async {
      final h = _harness(wide: true);
      await h.pump(tester, _page, routes: _routes);
      await tester.tap(_key('q1-0'));
      await tester.pump();
      expect(find.text('1 of 7'), findsOneWidget);
      await tester.tap(_key('q2-3'));
      await tester.tap(_key('q3-3'));
      await tester.tap(_key('q4-1'));
      await tester.tap(_key('q5-0'));
      await tester.enterText(find.byKey(const ValueKey('q6-field')), 'x');
      await tester.pump();
      expect(find.text('6 of 7'), findsOneWidget);
      expect(find.text('You can send it once.'), findsOneWidget);
      await tester.enterText(find.byKey(const ValueKey('q7-field')), 'y');
      await tester.pump();
      expect(find.text('7 of 7'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('picking a lettered option pops its letter', (tester) async {
      final h = _harness();
      await h.pump(tester, _page, routes: _routes);
      expect(
        find.descendant(of: _key('q1-1'), matching: find.byType(FbPop)),
        findsNothing,
      );
      await tester.tap(_key('q1-1'));
      await tester.pump();
      expect(
        find.descendant(of: _key('q1-1'), matching: find.byType(FbPop)),
        findsOneWidget,
      );
      // Choosing another moves the mark.
      await tester.tap(_key('q1-3'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: _key('q1-1'), matching: find.byType(FbPop)),
        findsNothing,
      );
      expect(
        find.descendant(of: _key('q1-3'), matching: find.byType(FbPop)),
        findsOneWidget,
      );
    });

    testWidgets('the segmented thumb fades in on the first pick, then slides',
        (tester) async {
      final h = _harness();
      await h.pump(tester, _page, routes: _routes);
      Finder thumb() => _key('q2-thumb');
      expect(tester.widget<AnimatedOpacity>(thumb()).opacity, 0);
      await tester.tap(_key('q2-4'));
      await tester.pump();
      expect(tester.widget<AnimatedOpacity>(thumb()).opacity, 1);
      await tester.pumpAndSettle();
      final first = tester.getTopLeft(thumb()).dx;
      await tester.tap(_key('q2-2'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      final mid = tester.getTopLeft(thumb()).dx;
      await tester.pumpAndSettle();
      final end = tester.getTopLeft(thumb()).dx;
      expect(end, lessThan(first));
      expect(mid, greaterThan(end));
      expect(mid, lessThan(first));
    });

    testWidgets('Your Sent Feedback opens inline and lists what was sent',
        (tester) async {
      final h = _harness(wide: true);
      await h.pump(tester, _page, routes: _routes);
      expect(find.text('Your Sent Feedback'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SentFeedbackExpander),
          matching: find.text('3'),
        ),
        findsOneWidget,
      );
      expect(find.text('Nov 11'), findsNothing);
      await tester.tap(find.text('Your Sent Feedback'));
      await tester.pumpAndSettle();
      expect(find.text('Nov 11'), findsOneWidget);
      expect(
        find.textContaining('The explanation is wrong.'),
        findsOneWidget,
      );
      expect(find.textContaining('1 image'), findsOneWidget);
      expect(find.text('Nov 9'), findsOneWidget);
      await tester.tap(find.text('Your Sent Feedback'));
      await tester.pumpAndSettle();
      expect(find.text('Nov 11'), findsNothing);
    });

    testWidgets('the chevron turns a quarter while the list opens',
        (tester) async {
      final h = _harness();
      await h.pump(tester, _page, routes: _routes);
      double turns() =>
          tester.widget<AnimatedRotation>(_key('sent-chevron')).turns;
      expect(turns(), 0);
      await tester.tap(find.text('Your Sent Feedback'));
      await tester.pump();
      expect(turns(), .25);
      await tester.pumpAndSettle();
    });

    testWidgets('a text answer shows an accent border once it has text',
        (tester) async {
      final h = _harness();
      await h.pump(tester, _page, routes: _routes);
      BoxDecoration deco() =>
          tester.widget<AnimatedContainer>(_key('q6-box')).decoration!
              as BoxDecoration;
      expect(deco().border, isNull);
      await tester.enterText(find.byKey(const ValueKey('q6-field')), 'x');
      await tester.pumpAndSettle();
      expect((deco().border! as Border).top.width, 1.5);
    });
  });

  group('sending', () {
    testWidgets('sends the seven answers, then shows the sent state',
        (tester) async {
      final gate = Completer<void>();
      final api = FakeBetaFeedbackApi(
        reward: fakeReward(days: betaDays.take(5).toList()),
      )..surveyGate = gate;
      final h = _harness(api: api);
      await h.pump(tester, _page, routes: _routes);
      await _answerAll(tester);
      await tester.enterText(
        find.byKey(const ValueKey('q7-field')),
        '  Thanks  ',
      );
      await tester.pump();
      await tester.ensureVisible(find.text('Send Survey'));
      await tester.tap(find.text('Send Survey'));
      await tester.pump();
      expect(find.byType(FbSpinner), findsOneWidget);
      expect(api.surveys, hasLength(1));
      final a = api.surveys.single;
      expect(a.usage, SurveyUsage.mostDays);
      expect(a.ease, 4);
      expect(a.usefulness, 5);
      expect(a.keepUsing, SurveyContinue.yes);
      expect(a.recommend, 9);
      expect(a.improve, 'More Numerical Ability practice.');
      expect(a.other, 'Thanks');

      gate.complete();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Survey sent'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Thank you for helping shape Pantas. '
          'Your answers go straight to the team.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Back to Feedback'));
      await tester.pumpAndSettle();
      expect(find.text('feedback page'), findsOneWidget);
    });

    testWidgets('already sent shows the sent state too', (tester) async {
      final api = FakeBetaFeedbackApi(
        reward: fakeReward(days: betaDays.take(5).toList()),
      )..surveyError = const BetaFeedbackException(
          BetaFeedbackFailure.alreadyDone,
        );
      final h = _harness(api: api);
      await h.pump(tester, _page, routes: _routes);
      await _answerAll(tester);
      await tester.ensureVisible(find.text('Send Survey'));
      await tester.tap(find.text('Send Survey'));
      await tester.pumpAndSettle();
      expect(find.text('Survey sent'), findsOneWidget);
    });

    testWidgets('a closed survey says so and keeps the answers',
        (tester) async {
      final api = FakeBetaFeedbackApi(
        reward: fakeReward(days: betaDays.take(5).toList()),
      )..surveyError = const BetaFeedbackException(
          BetaFeedbackFailure.notAllowed,
        );
      final h = _harness(api: api);
      await h.pump(tester, _page, routes: _routes);
      await _answerAll(tester);
      await tester.ensureVisible(find.text('Send Survey'));
      await tester.tap(find.text('Send Survey'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('The survey is closed.'), findsOneWidget);
      expect(find.text('Survey sent'), findsNothing);
      expect(_sendEnabled(tester), isTrue);
    });

    testWidgets('another error keeps the answers and asks to try again',
        (tester) async {
      final api = FakeBetaFeedbackApi(
        reward: fakeReward(days: betaDays.take(5).toList()),
      )..surveyError = const BetaFeedbackException(BetaFeedbackFailure.other);
      final h = _harness(api: api);
      await h.pump(tester, _page, routes: _routes);
      await _answerAll(tester);
      await tester.ensureVisible(find.text('Send Survey'));
      await tester.tap(find.text('Send Survey'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Could not send. Try again.'), findsOneWidget);
      expect(_sendEnabled(tester), isTrue);
      expect(find.text('More Numerical Ability practice.'), findsOneWidget);
    });

    testWidgets('reduced motion: the sent state is complete at once',
        (tester) async {
      final api = FakeBetaFeedbackApi(
        reward: fakeReward(days: betaDays.take(5).toList()),
      );
      final h = _harness(api: api, reduceMotion: true);
      await h.pump(tester, _page, routes: _routes);
      await _answerAll(tester);
      await tester.ensureVisible(find.text('Send Survey'));
      await tester.tap(find.text('Send Survey'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Survey sent'), findsOneWidget);
      final mark = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byKey(const ValueKey('sent-mark')),
          matching: find.byType(CustomPaint),
        ),
      );
      final painter = mark.painter! as SentMarkPainter;
      expect(painter.ring, 1);
      expect(painter.check, 1);
      for (final o in tester.widgetList<Opacity>(find.byType(Opacity))) {
        expect(o.opacity, 1);
      }
    });
  });

  group('who can see it', () {
    testWidgets('already sent opens straight on the sent state',
        (tester) async {
      final h = _harness(
        api: FakeBetaFeedbackApi(
          reward: fakeReward(
            days: betaDays.take(5).toList(),
            surveySubmitted: true,
          ),
        ),
      );
      await h.pump(tester, _page, routes: _routes);
      expect(find.text('Survey sent'), findsOneWidget);
    });

    testWidgets('closed goes back to Feedback', (tester) async {
      final h = _harness(now: ph(11, 24, 9));
      await h.pump(tester, _page, routes: _routes);
      expect(find.text('feedback page'), findsOneWidget);
    });

    testWidgets('not open yet goes back to Feedback', (tester) async {
      final h = _harness(now: ph(11, 12, 9));
      await h.pump(tester, _page, routes: _routes);
      expect(find.text('feedback page'), findsOneWidget);
    });
  });

  for (final dark in [false, true]) {
    for (final wide in [false, true]) {
      testWidgets('builds without errors (dark: $dark, wide: $wide)',
          (tester) async {
        final h = _harness(dark: dark, wide: wide);
        await h.pump(tester, _page, routes: _routes);
        await _answerAll(tester);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
}
