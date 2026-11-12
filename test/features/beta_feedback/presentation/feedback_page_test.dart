import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/storage/data/repos/app_preferences_repository.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/features/beta_feedback/domain/beta_feedback_models.dart';
import 'package:pantas/features/beta_feedback/presentation/fb_kit.dart';
import 'package:pantas/features/beta_feedback/presentation/feedback_page.dart';

import 'beta_feedback_fakes.dart';
import 'feedback_harness.dart';

class _RecordingTelemetry extends DisabledTelemetry {
  final errors = <Object>[];
  @override
  Future<void> recordError(Object error, StackTrace stack) async {
    errors.add(error);
  }
}

Finder get _sendButton => find.ancestor(
      of: find.text('Send Feedback'),
      matching: find.byType(FbButton),
    );

bool _sendEnabled(WidgetTester tester) =>
    tester.widget<FbButton>(_sendButton).onPressed != null;

const _long =
    'The explanation for question 12 says B but the answer key marks C.';

String _fieldText(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField)).controller!.text;

Widget get _page => const FeedbackPage(frame: testFrame);

Map<String, WidgetBuilder> get _routes => {
      '/settings/beta-feedback/survey': (_) =>
          const Scaffold(body: Text('survey page')),
      '/settings/beta-feedback/sent/:id': (_) =>
          const Scaffold(body: Text('sent page')),
    };

void main() {
  group('days card', () {
    testWidgets('phone: count, strip, survey row and footnote', (tester) async {
      final h = FbHarness();
      final semantics = tester.ensureSemantics();
      await h.pump(tester, _page);

      expect(find.text('3 of 5 days'), findsOneWidget);
      expect(
        find.text('A day counts when you finish your whole Today plan.'),
        findsOneWidget,
      );
      for (final label in ['Mon', 'Tue', 'Wed', 'Today', 'Fri', 'Sat', 'Sun']) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      // Counted days carry a check, the others their date.
      expect(find.bySemanticsLabel('Nov 9, counted'), findsOneWidget);
      expect(find.bySemanticsLabel('Nov 10, counted'), findsOneWidget);
      expect(find.bySemanticsLabel('Nov 11, counted'), findsOneWidget);
      for (final n in ['12', '13', '14', '15']) {
        expect(find.text(n), findsOneWidget, reason: n);
      }
      expect(find.text('Exit Survey'), findsOneWidget);
      expect(find.text('Opens Nov 15'), findsOneWidget);
      expect(
        find.text(
          'Count 5 days from Nov 9 to 15 and send the exit survey to '
          'earn 1 year of Pro.',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('Your device and browser'), findsNothing);
      expect(tester.takeException(), isNull);
      semantics.dispose();
    });

    testWidgets('today counted keeps the Today label with a check',
        (tester) async {
      final h = FbHarness(
        api: FakeBetaFeedbackApi(
          reward: fakeReward(
            days: ['2026-11-09', '2026-11-10', '2026-11-11', '2026-11-12'],
          ),
        ),
      );
      final semantics = tester.ensureSemantics();
      await h.pump(tester, _page);
      expect(find.text('4 of 5 days'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.bySemanticsLabel('Nov 12, counted'), findsOneWidget);
      expect(find.text('12'), findsNothing);
      semantics.dispose();
    });

    testWidgets('wide: labels carry the date and the circles are 40 px',
        (tester) async {
      final h = FbHarness(wide: true);
      await h.pump(tester, _page);
      for (final label in [
        'Mon 9',
        'Tue 10',
        'Wed 11',
        'Today',
        'Fri 13',
        'Sat 14',
        'Sun 15',
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      final today = find.byKey(const ValueKey('day-2026-11-12'));
      expect(tester.getSize(today), const Size(40, 40));
    });

    testWidgets('the strip pops counted days in, one after the other',
        (tester) async {
      final h = FbHarness();
      await h.pump(tester, _page, settle: false);
      await tester.pump();
      final pops = find.byType(FbPop);
      expect(pops, findsNWidgets(3));
      double opacity(int i) => tester
          .widgetList<Opacity>(
            find.descendant(of: pops.at(i), matching: find.byType(Opacity)),
          )
          .first
          .opacity;
      // Delays are 100, 180 and 260 ms.
      expect(opacity(0), 0);
      await tester.pump(const Duration(milliseconds: 150));
      expect(opacity(0), greaterThan(0));
      expect(opacity(2), 0);
      await tester.pumpAndSettle();
      expect(opacity(2), 1);
    });

    testWidgets('reduced motion shows every day at once', (tester) async {
      final h = FbHarness(reduceMotion: true);
      await h.pump(tester, _page, settle: false);
      await tester.pump();
      final pops = find.byType(FbPop);
      expect(pops, findsNWidgets(3));
      for (var i = 0; i < 3; i++) {
        final o = tester
            .widgetList<Opacity>(
              find.descendant(of: pops.at(i), matching: find.byType(Opacity)),
            )
            .first
            .opacity;
        expect(o, 1);
      }
    });

    Future<void> seedShown(FbHarness h, String? value) async {
      if (value == null) return;
      await AppPreferencesRepository(h.db)
          .setDeviceValue('beta_feedback_shown_days', value);
    }

    testWidgets('the count rolls up when it is higher than last shown',
        (tester) async {
      final h = FbHarness();
      await seedShown(h, '2');
      await h.pump(tester, _page, settle: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      // Both digits are on screen part way through the roll.
      expect(find.byKey(const ValueKey('count-old')), findsOneWidget);
      expect(find.byKey(const ValueKey('count-new')), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('count-old')), findsNothing);
      expect(find.text('3 of 5 days'), findsOneWidget);
      expect(
        await AppPreferencesRepository(h.db)
            .deviceValue('beta_feedback_shown_days'),
        '3',
      );
    });

    testWidgets('the count stays still when it is not higher', (tester) async {
      final h = FbHarness();
      await seedShown(h, '3');
      await h.pump(tester, _page, settle: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byKey(const ValueKey('count-old')), findsNothing);
      expect(find.text('3 of 5 days'), findsOneWidget);
    });

    testWidgets('the first time there is nothing to roll from', (tester) async {
      final h = FbHarness();
      await h.pump(tester, _page, settle: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byKey(const ValueKey('count-old')), findsNothing);
      await tester.pumpAndSettle();
      expect(
        await AppPreferencesRepository(h.db)
            .deviceValue('beta_feedback_shown_days'),
        '3',
      );
    });

    testWidgets('reduced motion: the count is in place at once',
        (tester) async {
      final h = FbHarness(reduceMotion: true);
      await seedShown(h, '1');
      await h.pump(tester, _page, settle: false);
      await tester.pump();
      await tester.pump();
      expect(find.byKey(const ValueKey('count-old')), findsNothing);
      expect(find.text('3 of 5 days'), findsOneWidget);
    });
  });

  group('compose', () {
    testWidgets('Send Feedback is disabled until there is text or an image',
        (tester) async {
      final h = FbHarness();
      await h.pump(tester, _page);
      expect(find.text('0 of 3'), findsOneWidget);
      expect(
        find.text('What worked, what broke, what you would change'),
        findsOneWidget,
      );
      expect(_sendEnabled(tester), isFalse);
      await tester.enterText(find.byType(TextField), '   ');
      await tester.pump();
      expect(_sendEnabled(tester), isFalse);
      await tester.enterText(find.byType(TextField), 'The timer froze.');
      await tester.pump();
      expect(_sendEnabled(tester), isTrue);
      await tester.enterText(find.byType(TextField), '');
      h.images.next = [fakeImage()];
      await tester.tap(find.byKey(addImageKey));
      await tester.pumpAndSettle();
      expect(_sendEnabled(tester), isTrue);
    });

    testWidgets('images add up to 3, then the tile goes', (tester) async {
      final h = FbHarness();
      final semantics = tester.ensureSemantics();
      await h.pump(tester, _page);
      h.images.next = [fakeImage(), fakeImage()];
      await tester.tap(find.byKey(addImageKey));
      await tester.pumpAndSettle();
      expect(h.images.picks, [3]);
      expect(find.byKey(removeKey(1)), findsOneWidget);
      expect(find.byKey(removeKey(2)), findsOneWidget);
      expect(find.text('2 of 3'), findsOneWidget);
      expect(find.bySemanticsLabel('Remove image 1'), findsOneWidget);
      expect(find.bySemanticsLabel('Add image'), findsOneWidget);

      h.images.next = [fakeImage(), fakeImage()];
      await tester.tap(find.byKey(addImageKey));
      await tester.pumpAndSettle();
      expect(h.images.picks, [3, 1]);
      expect(find.byKey(removeKey(3)), findsOneWidget);
      expect(find.byKey(addImageKey), findsNothing);
      semantics.dispose();
    });

    testWidgets('remove fades the thumbnail out and shows the tile again',
        (tester) async {
      final h = FbHarness();
      await h.pump(tester, _page);
      h.images.next = [fakeImage(), fakeImage()];
      await tester.tap(find.byKey(addImageKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(removeKey(1)));
      await tester.pump(const Duration(milliseconds: 80));
      // Part way: still there, partly faded.
      expect(find.byKey(removeKey(2)), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byKey(removeKey(2)), findsNothing);
      expect(find.byKey(removeKey(1)), findsOneWidget);
      expect(find.text('1 of 3'), findsOneWidget);
    });

    testWidgets('refused files name the problem', (tester) async {
      final h = FbHarness();
      await h.pump(tester, _page);
      h.images.next = [fakeImage(type: 'image/gif')];
      await tester.tap(find.byKey(addImageKey));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Use a PNG, JPEG or WebP image.'), findsOneWidget);
      expect(find.byKey(removeKey(1)), findsNothing);

      ScaffoldMessenger.of(tester.element(find.byType(TextField)))
          .clearSnackBars();
      await tester.pumpAndSettle();
      h.images.next = [fakeImage(size: PickedImage.maxBytes + 1)];
      await tester.tap(find.byKey(addImageKey));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Each image must be 5 MB or smaller.'), findsOneWidget);
      expect(find.byKey(removeKey(1)), findsNothing);
    });

    testWidgets('a good file next to a bad one is still added', (tester) async {
      final h = FbHarness();
      await h.pump(tester, _page);
      h.images.next = [fakeImage(type: 'image/bmp'), fakeImage()];
      await tester.tap(find.byKey(addImageKey));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byKey(removeKey(1)), findsOneWidget);
      expect(find.text('Use a PNG, JPEG or WebP image.'), findsOneWidget);
    });

    testWidgets('send shows a spinner, then a check, then clears and inserts',
        (tester) async {
      final gate = Completer<SentFeedback>();
      final h = FbHarness(api: FakeBetaFeedbackApi()..sendGate = gate);
      await h.pump(tester, _page);
      h.images.next = [fakeImage()];
      await tester.tap(find.byKey(addImageKey));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '  The timer froze.  ');
      await tester.pump();
      await tester.tap(find.text('Send Feedback'));
      await tester.pump();

      expect(h.api.sends, hasLength(1));
      expect(h.api.sends.single.text, 'The timer froze.');
      expect(h.api.sends.single.images, hasLength(1));
      expect(h.api.sends.single.id, matches(RegExp(r'^[A-Za-z0-9]{20}$')));
      expect(find.text('Send Feedback'), findsNothing);
      expect(find.byType(FbSpinner), findsOneWidget);
      // A second tap while sending does nothing.
      await tester.tap(find.byType(FbSpinner), warnIfMissed: false);
      expect(h.api.sends, hasLength(1));

      gate.complete(
        SentFeedback(
          id: h.api.sends.single.id,
          text: 'The timer froze.',
          createdAt: ph(11, 12, 21, 41),
          attachments: const [
            SentAttachment(path: 'p/0', contentType: 'image/png'),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      // The check draws and holds; the draft is still on the card.
      expect(find.byType(FbSpinner), findsNothing);
      expect(find.byKey(const ValueKey('send-done')), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      expect(find.text('Send Feedback'), findsOneWidget);
      expect(_fieldText(tester), isEmpty);
      expect(find.byKey(removeKey(1)), findsNothing);
      expect(find.text('0 of 3'), findsOneWidget);
      expect(_sendEnabled(tester), isFalse);
      // The new item sits at the top of Sent.
      expect(find.text('SENT'), findsOneWidget);
      expect(find.text('The timer froze.'), findsOneWidget);
      expect(find.text('Nov 12, 9:41 PM · 1 image'), findsOneWidget);
    });

    testWidgets('a failed send reaches telemetry tagged', (tester) async {
      final telemetry = _RecordingTelemetry();
      final h = FbHarness(
        api: FakeBetaFeedbackApi()
          ..sendError = const BetaFeedbackException(BetaFeedbackFailure.other),
      );
      await h.pump(
        tester,
        _page,
        overrides: [telemetryProvider.overrideWithValue(telemetry)],
      );
      h.images.next = [fakeImage()];
      await tester.tap(find.byKey(addImageKey));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Keep me');
      await tester.pump();
      await tester.tap(find.text('Send Feedback'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Could not send. Try again.'), findsOneWidget);
      expect(telemetry.errors, hasLength(1));
      expect(telemetry.errors.single.toString(), startsWith('feedback.send: '));
    });

    testWidgets('a failed send keeps the draft and says so', (tester) async {
      final h = FbHarness(
        api: FakeBetaFeedbackApi()
          ..sendError = const BetaFeedbackException(BetaFeedbackFailure.other),
      );
      await h.pump(tester, _page);
      h.images.next = [fakeImage()];
      await tester.tap(find.byKey(addImageKey));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Keep me');
      await tester.pump();
      await tester.tap(find.text('Send Feedback'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Could not send. Try again.'), findsOneWidget);
      expect(find.text('Keep me'), findsOneWidget);
      expect(find.byKey(removeKey(1)), findsOneWidget);
      expect(find.text('Send Feedback'), findsOneWidget);
      expect(_sendEnabled(tester), isTrue);
      expect(find.text('SENT'), findsNothing);
    });

    testWidgets('a retry sends the same id until the draft changes',
        (tester) async {
      final h = FbHarness(
        api: FakeBetaFeedbackApi()
          ..sendError = const BetaFeedbackException(BetaFeedbackFailure.other),
      );
      await h.pump(tester, _page);
      await tester.enterText(find.byType(TextField), 'One');
      await tester.pump();
      await tester.tap(find.text('Send Feedback'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send Feedback'));
      await tester.pumpAndSettle();
      expect(h.api.sends, hasLength(2));
      expect(h.api.sends[0].id, h.api.sends[1].id);
      await tester.enterText(find.byType(TextField), 'Two');
      await tester.pump();
      await tester.tap(find.text('Send Feedback'));
      await tester.pumpAndSettle();
      expect(h.api.sends[2].id, isNot(h.api.sends[0].id));
    });
  });

  group('sent list', () {
    final sent = [
      fakeSent(
        'a',
        'The explanation for question 12 says B but the answer key marks C.',
        ph(11, 11, 21, 41),
        images: 1,
      ),
      fakeSent('b', 'Sign-in code arrived fast. Easy.', ph(11, 9, 20, 12)),
      fakeSent('c', '', ph(11, 10, 7, 5), images: 2),
    ];

    testWidgets('phone rows: text, date and time, image count', (tester) async {
      final h = FbHarness(api: FakeBetaFeedbackApi(sent: sent));
      await h.pump(tester, _page, routes: _routes);
      expect(find.text('SENT'), findsOneWidget);
      expect(
        find.text(
          _long,
        ),
        findsOneWidget,
      );
      expect(find.text('Nov 11, 9:41 PM · 1 image'), findsOneWidget);
      expect(find.text('Nov 9, 8:12 PM'), findsOneWidget);
      // Image-only: the count is the text line and the date stands alone.
      expect(find.text('2 images'), findsOneWidget);
      expect(find.text('Nov 10, 7:05 AM'), findsOneWidget);
    });

    testWidgets('nothing sent hides the Sent section', (tester) async {
      final h = FbHarness();
      await h.pump(tester, _page);
      expect(find.text('SENT'), findsNothing);
    });

    testWidgets('a row opens the sent item', (tester) async {
      final h = FbHarness(api: FakeBetaFeedbackApi(sent: sent));
      await h.pump(tester, _page, routes: _routes);
      await tester.ensureVisible(find.text('Sign-in code arrived fast. Easy.'));
      await tester.tap(find.text('Sign-in code arrived fast. Easy.'));
      await tester.pumpAndSettle();
      expect(find.text('sent page'), findsOneWidget);
    });

    testWidgets('wide rows: one line, image count and date on the right',
        (tester) async {
      final h = FbHarness(wide: true, api: FakeBetaFeedbackApi(sent: sent));
      await h.pump(tester, _page, routes: _routes);
      expect(find.text('1 image · Nov 11'), findsOneWidget);
      expect(find.text('Nov 9'), findsOneWidget);
      expect(find.text('Nov 10'), findsOneWidget);
      // Image-only: the count stands in for the text.
      expect(find.text('2 images'), findsOneWidget);
    });

    testWidgets('a row that arrives later slides in at the top',
        (tester) async {
      final api = FakeBetaFeedbackApi(sent: sent.take(1).toList());
      final h = FbHarness(api: api);
      await h.pump(tester, _page);
      expect(find.byKey(const ValueKey('sent-new-b')), findsNothing);
      api.emitSent([sent[1], sent[0]]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byKey(const ValueKey('sent-new-b')), findsOneWidget);
      await tester.pumpAndSettle();
      final top =
          tester.getTopLeft(find.text('Sign-in code arrived fast. Easy.')).dy;
      final next = tester
          .getTopLeft(
            find.text(
              _long,
            ),
          )
          .dy;
      expect(top, lessThan(next));
    });
  });

  group('exit survey row', () {
    testWidgets('open and not sent: opens the survey', (tester) async {
      final h = FbHarness(now: ph(11, 16, 9));
      await h.pump(tester, _page, routes: _routes);
      expect(find.text('Until Nov 22'), findsOneWidget);
      await tester.tap(find.text('Exit Survey'));
      await tester.pumpAndSettle();
      expect(find.text('survey page'), findsOneWidget);
    });

    testWidgets('sent: says Sent and does not open', (tester) async {
      final h = FbHarness(
        now: ph(11, 16, 9),
        api: FakeBetaFeedbackApi(reward: fakeReward(surveySubmitted: true)),
      );
      await h.pump(tester, _page, routes: _routes);
      expect(find.text('Sent'), findsOneWidget);
      await tester.tap(find.text('Exit Survey'));
      await tester.pumpAndSettle();
      expect(find.text('survey page'), findsNothing);
    });

    testWidgets('closed and not sent: says Closed and does not open',
        (tester) async {
      final h = FbHarness(now: ph(11, 24, 9));
      await h.pump(tester, _page, routes: _routes);
      expect(find.text('Closed'), findsOneWidget);
      await tester.tap(find.text('Exit Survey'));
      await tester.pumpAndSettle();
      expect(find.text('survey page'), findsNothing);
    });

    testWidgets('before it opens it is not a button', (tester) async {
      final h = FbHarness();
      await h.pump(tester, _page, routes: _routes);
      await tester.tap(find.text('Exit Survey'));
      await tester.pumpAndSettle();
      expect(find.text('survey page'), findsNothing);
    });
  });

  group('wide web', () {
    testWidgets('the button shows the key and Cmd+Enter sends', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      final h = FbHarness(wide: true);
      await h.pump(tester, _page);
      expect(find.text('⌘ Enter'), findsOneWidget);
      expect(find.text('or drop or paste screenshots here'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'From the keyboard');
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
      await tester.pumpAndSettle();
      expect(h.api.sends.single.text, 'From the keyboard');
      debugDefaultTargetPlatformOverride = null;
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('Ctrl+Enter sends off Apple platforms and says Ctrl Enter',
        (tester) async {
      final h = FbHarness(wide: true);
      await h.pump(tester, _page);
      expect(find.text('Ctrl Enter'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Ctrl send');
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();
      expect(h.api.sends.single.text, 'Ctrl send');
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('Enter alone does not send', (tester) async {
      final h = FbHarness(wide: true);
      await h.pump(tester, _page);
      await tester.enterText(find.byType(TextField), 'Line one');
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(h.api.sends, isEmpty);
    });

    testWidgets('dropped and pasted images are added while the page shows',
        (tester) async {
      final h = FbHarness(wide: true);
      await h.pump(tester, _page);
      h.images.drop([fakeImage(), fakeImage(type: 'image/gif')]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byKey(removeKey(1)), findsOneWidget);
      expect(find.byKey(removeKey(2)), findsNothing);
      expect(find.text('Use a PNG, JPEG or WebP image.'), findsOneWidget);
    });

    testWidgets('the drop listener ends with the page', (tester) async {
      final h = FbHarness(wide: true);
      await h.pump(tester, _page);
      await tester.pumpWidget(const SizedBox());
      // No listener is left to throw into a disposed page.
      h.images.drop([fakeImage()]);
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  for (final dark in [false, true]) {
    for (final wide in [false, true]) {
      testWidgets('builds without errors (dark: $dark, wide: $wide)',
          (tester) async {
        final h = FbHarness(
          dark: dark,
          wide: wide,
          api: FakeBetaFeedbackApi(
            sent: [fakeSent('a', 'Hello', ph(11, 10, 9), images: 1)],
          ),
        );
        await h.pump(tester, _page);
        expect(find.text('3 of 5 days'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('reduced motion: send ends on the final state at once',
      (tester) async {
    final h = FbHarness(reduceMotion: true);
    await h.pump(tester, _page);
    await tester.enterText(find.byType(TextField), 'Quick');
    await tester.pump();
    await tester.tap(find.text('Send Feedback'));
    await tester.pump();
    await tester.pump();
    expect(find.byType(FbSpinner), findsNothing);
    expect(find.byKey(const ValueKey('send-done')), findsNothing);
    expect(find.text('Send Feedback'), findsOneWidget);
    expect(_fieldText(tester), isEmpty);
    expect(find.text('Quick'), findsOneWidget);
    expect(find.text('SENT'), findsOneWidget);
  });
}
