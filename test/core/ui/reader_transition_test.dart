import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/reader_transition.dart';

void main() {
  // The platform default slid the next lesson in from the right, against the
  // upward gesture that asked for it. Aedwon: "at least if we're gonna stick
  // with that have it come from the bottom so the pull up makes sense".
  Widget harness(
    Animation<double> arriving,
    Animation<double> departing, {
    ReaderEntry entry = ReaderEntry.advance,
    bool disableAnimations = false,
  }) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: ReaderAdvanceTransition(
          animation: arriving,
          secondaryAnimation: departing,
          entry: entry,
          child: const Text('lesson'),
        ),
      ),
    );
  }

  testWidgets('the arriving lesson comes from below, never from the side',
      (tester) async {
    await tester.pumpWidget(
      harness(const AlwaysStoppedAnimation(0), const AlwaysStoppedAnimation(0)),
    );

    final start = tester.getRect(find.text('lesson'));

    await tester.pumpWidget(
      harness(const AlwaysStoppedAnimation(1), const AlwaysStoppedAnimation(0)),
    );
    final end = tester.getRect(find.text('lesson'));

    expect(start.top, greaterThan(end.top));
    expect(start.left, end.left);
  });

  testWidgets('the lesson being left keeps going up, not sideways',
      (tester) async {
    await tester.pumpWidget(
      harness(const AlwaysStoppedAnimation(1), const AlwaysStoppedAnimation(0)),
    );
    final start = tester.getRect(find.text('lesson'));

    await tester.pumpWidget(
      harness(const AlwaysStoppedAnimation(1), const AlwaysStoppedAnimation(1)),
    );
    final end = tester.getRect(find.text('lesson'));

    expect(end.top, lessThan(start.top));
    expect(start.left, end.left);
  });

  testWidgets('the lesson being left travels less than the one arriving',
      (tester) async {
    await tester.pumpWidget(
      harness(const AlwaysStoppedAnimation(0), const AlwaysStoppedAnimation(0)),
    );
    final arrivingFrom = tester.getRect(find.text('lesson')).top;

    await tester.pumpWidget(
      harness(const AlwaysStoppedAnimation(1), const AlwaysStoppedAnimation(0)),
    );
    final resting = tester.getRect(find.text('lesson')).top;

    await tester.pumpWidget(
      harness(const AlwaysStoppedAnimation(1), const AlwaysStoppedAnimation(1)),
    );
    final departedTo = tester.getRect(find.text('lesson')).top;

    expect(
      (resting - departedTo).abs(),
      lessThan((arrivingFrom - resting).abs()),
    );
  });

  testWidgets('a lesson opened by tapping comes from the right',
      (tester) async {
    // The row's chevron points that way, so going into it should too.
    // Aedwon: "since the chevrons are pointing to the right > maybe that's
    // the part where we use the 'from right to left' insertion".
    await tester.pumpWidget(
      harness(
        const AlwaysStoppedAnimation(0),
        const AlwaysStoppedAnimation(0),
        entry: ReaderEntry.forward,
      ),
    );
    final start = tester.getRect(find.text('lesson'));

    await tester.pumpWidget(
      harness(
        const AlwaysStoppedAnimation(1),
        const AlwaysStoppedAnimation(0),
        entry: ReaderEntry.forward,
      ),
    );
    final end = tester.getRect(find.text('lesson'));

    expect(start.left, greaterThan(end.left));
    expect(start.top, end.top);
  });

  testWidgets('and the one it covers leaves to the left', (tester) async {
    await tester.pumpWidget(
      harness(
        const AlwaysStoppedAnimation(1),
        const AlwaysStoppedAnimation(0),
        entry: ReaderEntry.forward,
      ),
    );
    final start = tester.getRect(find.text('lesson'));

    await tester.pumpWidget(
      harness(
        const AlwaysStoppedAnimation(1),
        const AlwaysStoppedAnimation(1),
        entry: ReaderEntry.forward,
      ),
    );
    final end = tester.getRect(find.text('lesson'));

    expect(end.left, lessThan(start.left));
    expect(start.top, end.top);
  });

  testWidgets('reduced motion renders the lesson without transitions', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(
        const AlwaysStoppedAnimation(0),
        const AlwaysStoppedAnimation(1),
        disableAnimations: true,
      ),
    );

    final transition = find.byType(ReaderAdvanceTransition);
    expect(
      find.descendant(of: transition, matching: find.byType(SlideTransition)),
      findsNothing,
    );
    expect(
      find.descendant(of: transition, matching: find.byType(FadeTransition)),
      findsNothing,
    );
    expect(find.text('lesson'), findsOneWidget);
  });

  // Item 5 of the Nov 3 motion board, option A "Rise and settle": the lesson
  // fades in while rising 24 px over 320 ms on the shared ease, and nothing
  // else moves.
  group('a lesson opened from outside the reader rises and settles', () {
    const travel = 24.0;
    const curve = Cubic(0.32, 0.72, 0, 1);

    Widget rise(
      double progress, {
      double covered = 0,
      bool disableAnimations = false,
    }) =>
        harness(
          AlwaysStoppedAnimation(progress),
          AlwaysStoppedAnimation(covered),
          entry: ReaderEntry.rise,
          disableAnimations: disableAnimations,
        );

    double opacity(WidgetTester tester) => tester
        .widgetList<FadeTransition>(
          find.descendant(
            of: find.byType(ReaderAdvanceTransition),
            matching: find.byType(FadeTransition),
          ),
        )
        .fold<double>(1, (product, fade) => product * fade.opacity.value);

    test('uses the board duration, distance and curve', () {
      expect(readerRiseDuration, const Duration(milliseconds: 320));
      expect(readerRiseTravel, travel);
      expect(readerRiseCurve, curve);
    });

    testWidgets('moves and fades together at 0, 25, 50, 75 and 100 percent',
        (tester) async {
      await tester.pumpWidget(rise(1));
      final rest = tester.getRect(find.text('lesson'));
      expect(opacity(tester), 1);

      var previousTop = double.infinity;
      for (final progress in [0.0, 0.25, 0.5, 0.75, 1.0]) {
        await tester.pumpWidget(rise(progress));
        final eased = curve.transform(progress);
        final frame = tester.getRect(find.text('lesson'));
        final label = '${progress * 100} percent';

        expect(
          frame.top - rest.top,
          closeTo((1 - eased) * travel, 1e-6),
          reason: label,
        );
        expect(frame.left, rest.left, reason: label);
        expect(frame.size, rest.size, reason: label);
        expect(opacity(tester), closeTo(eased, 1e-6), reason: label);
        expect(frame.top, lessThanOrEqualTo(previousTop), reason: label);
        previousTop = frame.top;
      }
    });

    testWidgets('starts invisible, 24 px low, and ends at rest',
        (tester) async {
      await tester.pumpWidget(rise(1));
      final rest = tester.getRect(find.text('lesson'));

      await tester.pumpWidget(rise(0));
      expect(opacity(tester), 0);
      expect(tester.getRect(find.text('lesson')).top - rest.top, travel);

      await tester.pumpWidget(rise(1));
      expect(opacity(tester), 1);
      expect(tester.getRect(find.text('lesson')), rest);
    });

    testWidgets('has no sideways movement and no blur', (tester) async {
      await tester.pumpWidget(rise(1));
      final rest = tester.getRect(find.text('lesson'));

      await tester.pumpWidget(rise(0.4));
      expect(tester.getRect(find.text('lesson')).left, rest.left);
      expect(
        find.descendant(
          of: find.byType(ReaderAdvanceTransition),
          matching: find.byWidgetPredicate(
            (widget) => widget is ImageFiltered || widget is BackdropFilter,
          ),
        ),
        findsNothing,
      );
    });

    testWidgets('reduced motion shows the finished lesson at once',
        (tester) async {
      await tester.pumpWidget(rise(1));
      final rest = tester.getRect(find.text('lesson'));

      await tester.pumpWidget(rise(0, disableAnimations: true));
      final transition = find.byType(ReaderAdvanceTransition);
      expect(
        find.descendant(of: transition, matching: find.byType(FadeTransition)),
        findsNothing,
      );
      expect(
        find.descendant(of: transition, matching: find.byType(Transform)),
        findsNothing,
      );
      expect(tester.getRect(find.text('lesson')), rest);
      expect(find.text('lesson'), findsOneWidget);
    });

    testWidgets('covered by another lesson it moves aside as forward does',
        (tester) async {
      await tester.pumpWidget(rise(1));
      final rest = tester.getRect(find.text('lesson'));

      await tester.pumpWidget(rise(1, covered: 1));
      final moved = tester.getRect(find.text('lesson'));
      expect(moved.left, lessThan(rest.left));
      expect(moved.top, rest.top);
      expect(opacity(tester), closeTo(0.25, 1e-6));
    });
  });
}
