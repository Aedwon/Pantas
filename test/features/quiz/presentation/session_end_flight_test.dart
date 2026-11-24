// The end of a session (core loops B2): the marks of the answer track fly
// from the bar into the results row and grow into the circles, then the ring
// and the count-up run, then "in 9 minutes" and Done come in. Phone and wide
// play the same timeline.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/quiz/presentation/quiz_end_flight.dart';
import 'package:pantas/features/quiz/presentation/session_end_screen.dart';

import '../../../helpers/ds_matrix.dart';
import 'session_end_screen_test.dart' show completedAttempt, completedSession;

int _done = 0;

Future<void> _pump(
  WidgetTester tester, {
  required double width,
  int total = 10,
  int correct = 7,
  bool still = false,
  bool ghost = false,
}) async {
  await tester.runAsync(loadDsFonts);
  final web = width >= 1024;
  debugWebPlatformOverride = web;
  addTearDown(() => debugWebPlatformOverride = null);
  tester.view
    ..physicalSize = Size(width, 900)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  _done = 0;
  final session = completedSession(total: total, correct: correct);
  final attempt = completedAttempt(session);
  final flight = QuizEndFlight(
    from: total > 20
        ? const []
        : [
            for (var i = 0; i < total; i++)
              Rect.fromLTWH(600.0 + i * 13, 838, 10, 4),
          ],
    correct: [for (var i = 0; i < total; i++) i < correct],
  );
  await tester.pumpWidget(
    MaterialApp(
      theme: web ? buildLightTheme(web: true) : buildLightTheme(web: false),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: still),
        child: child!,
      ),
      home: Scaffold(
        body: QuizEndFlightHost(
          flight: flight,
          builder: (context, run) => SessionEndBody(
            session: session,
            attempt: attempt,
            subjectNames: const {'t': 'Earth Science'},
            proIsActive: false,
            onDone: () => _done++,
            onQuestion: (_) {},
            onAll: () {},
            onMistakes: () {},
            onNotes: () {},
            flightRun: run,
          ),
        ),
      ),
    ),
  );
}

Finder _mark(int i) => find.byKey(ValueKey('end-flight-mark-$i'));
Finder _circle(int i) => find.byKey(ValueKey('end-circle-$i'));

double _circleOpacity(WidgetTester tester, int i) => tester
    .widget<Opacity>(
      find.ancestor(of: _circle(i), matching: find.byType(Opacity)).first,
    )
    .opacity;

/// How far the count has rolled: 0 before the count-up starts.
double _rolled(WidgetTester tester) => -tester
    .widget<Transform>(find.byKey(const ValueKey('quiz-count-strip')))
    .transform
    .getTranslation()
    .y;

Future<void> _at(WidgetTester tester, int ms) =>
    tester.pump(Duration(milliseconds: ms));

void main() {
  for (final width in [390.0, 1440.0]) {
    final name = width < 1024 ? 'phone' : 'wide';

    testWidgets('$name, 10 questions: the marks wait for the fade, then fly',
        (tester) async {
      await _pump(tester, width: width);
      // t = 0: the marks sit where the bar's track was; no circle is in the
      // row yet.
      expect(_mark(0), findsOneWidget);
      expect(_mark(9), findsOneWidget);
      expect(tester.getRect(_mark(0)), const Rect.fromLTWH(600, 838, 10, 4));
      expect(_circleOpacity(tester, 0), 0);
      // The fade takes 180 ms. The first mark has not moved at 100 ms.
      await _at(tester, 100);
      expect(tester.getRect(_mark(0)), const Rect.fromLTWH(600, 838, 10, 4));
      // Mid-flight it is between the bar and the row.
      await _at(tester, 260);
      final mid = tester.getRect(_mark(0));
      expect(mid.top, lessThan(838));
      expect(mid.height, greaterThan(4));
      expect(_circleOpacity(tester, 0), 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('$name, 10 questions: all landed by 0.75 s, marks give way',
        (tester) async {
      await _pump(tester, width: width);
      await _at(tester, 541);
      // The first has landed and is a circle in the row.
      expect(_mark(0), findsNothing);
      expect(_circleOpacity(tester, 0), 1);
      expect(_mark(9), findsOneWidget);
      await _at(tester, 200);
      for (var i = 0; i < 10; i++) {
        expect(_mark(i), findsNothing, reason: 'mark $i');
        expect(_circleOpacity(tester, i), 1, reason: 'circle $i');
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('$name, 10 questions: the count-up starts as the last two land',
        (tester) async {
      await _pump(tester, width: width);
      await _at(tester, 690);
      expect(_rolled(tester), 0);
      // The ring and the count start at 700 ms and run 1.4 s.
      await _at(tester, 400);
      expect(_rolled(tester), greaterThan(0));
      await _at(tester, 1400);
      expect(find.text('7'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('$name, 10 questions: Done is pressable as it appears',
        (tester) async {
      await _pump(tester, width: width);
      await _at(tester, 600);
      await tester.tap(find.text('Done'), warnIfMissed: false);
      expect(_done, 0);
      // "in 9 minutes" and Done appear as the last mark lands (720 ms).
      await _at(tester, 140);
      await tester.tap(find.text('Done'));
      expect(_done, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('$name, 20 questions: still landed by 0.75 s', (tester) async {
      await _pump(tester, width: width, total: 20, correct: 15);
      await _at(tester, 751);
      for (var i = 0; i < 20; i++) {
        expect(_mark(i), findsNothing, reason: 'mark $i');
        expect(_circleOpacity(tester, i), 1, reason: 'circle $i');
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        '$name, 25 questions: nothing flies, the row fades in with '
        'the ring', (tester) async {
      await _pump(tester, width: width, total: 25, correct: 20);
      expect(find.byKey(const ValueKey('end-flight-mark-0')), findsNothing);
      expect(_circleOpacity(tester, 0), 0);
      await _at(tester, 100);
      expect(_circleOpacity(tester, 0), 0);
      expect(_rolled(tester), 0);
      // The fade-out takes 180 ms; then the row and the ring come in.
      await _at(tester, 200);
      expect(_circleOpacity(tester, 0), greaterThan(0));
      expect(_rolled(tester), greaterThan(0));
      await _at(tester, 1600);
      expect(_circleOpacity(tester, 24), 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('$name, reduced motion: no travel, everything is there',
        (tester) async {
      await _pump(tester, width: width, still: true);
      await tester.pump();
      for (var i = 0; i < 10; i++) {
        expect(_mark(i), findsNothing);
        expect(_circleOpacity(tester, i), 1);
      }
      await tester.tap(find.text('Done'));
      expect(_done, 1);
      expect(tester.takeException(), isNull);
    });
  }
}
