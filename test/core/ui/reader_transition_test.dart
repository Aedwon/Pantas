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
}
