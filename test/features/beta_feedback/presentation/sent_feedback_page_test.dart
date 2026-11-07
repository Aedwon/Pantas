import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/beta_feedback/presentation/sent_feedback_page.dart';

import 'beta_feedback_fakes.dart';
import 'feedback_harness.dart';

const _text = 'The explanation for question 12 says B but the answer key '
    'marks C.';

FakeBetaFeedbackApi _api() => FakeBetaFeedbackApi(
      sent: [
        fakeSent('a', _text, ph(11, 11, 21, 41), images: 2),
        fakeSent('b', '', ph(11, 10, 7, 5), images: 1),
        fakeSent('c', 'Sign-in code arrived fast.', ph(11, 9, 20, 12)),
      ],
    );

Map<String, WidgetBuilder> get _routes => {
      '/settings/beta-feedback': (_) =>
          const Scaffold(body: Text('feedback page')),
    };

void main() {
  for (final wide in [false, true]) {
    testWidgets('shows the date, the text and each image (wide: $wide)',
        (tester) async {
      final h = FbHarness(wide: wide, api: _api());
      await h.pump(
        tester,
        const SentFeedbackPage(frame: testFrame, id: 'a'),
        routes: _routes,
      );
      expect(find.text('Nov 11, 9:41 PM'), findsOneWidget);
      expect(find.text(_text), findsOneWidget);
      expect(find.byKey(const ValueKey('sent-image-0')), findsOneWidget);
      expect(find.byKey(const ValueKey('sent-image-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('sent-image-2')), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('image-only feedback has no text card', (tester) async {
    final h = FbHarness(api: _api());
    await h.pump(
      tester,
      const SentFeedbackPage(frame: testFrame, id: 'b'),
      routes: _routes,
    );
    expect(find.text('Nov 10, 7:05 AM'), findsOneWidget);
    expect(find.byKey(const ValueKey('sent-text-card')), findsNothing);
    expect(find.byKey(const ValueKey('sent-image-0')), findsOneWidget);
  });

  testWidgets('text only has no images', (tester) async {
    final h = FbHarness(api: _api());
    await h.pump(
      tester,
      const SentFeedbackPage(frame: testFrame, id: 'c'),
      routes: _routes,
    );
    expect(find.text('Sign-in code arrived fast.'), findsOneWidget);
    expect(find.byKey(const ValueKey('sent-image-0')), findsNothing);
  });

  testWidgets('an item that is not there says so', (tester) async {
    final h = FbHarness(api: _api());
    await h.pump(
      tester,
      const SentFeedbackPage(frame: testFrame, id: 'zzz'),
      routes: _routes,
    );
    expect(find.text('This feedback is not available.'), findsOneWidget);
  });

  testWidgets('light and dark build without errors', (tester) async {
    for (final dark in [false, true]) {
      final h = FbHarness(dark: dark, api: _api());
      await h.pump(
        tester,
        const SentFeedbackPage(frame: testFrame, id: 'a'),
        routes: _routes,
      );
      expect(tester.takeException(), isNull);
    }
  });
}
