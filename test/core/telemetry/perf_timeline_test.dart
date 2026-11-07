import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/telemetry/perf_timeline.dart';

void main() {
  late int now;

  setUp(() {
    now = 0;
    PerfTimeline.reset();
    PerfTimeline.nowMs = () => now;
  });

  tearDown(PerfTimeline.reset);

  test('every contract name fits the wire pattern', () {
    final pattern = RegExp(r'^[a-z0-9_.]{1,40}$');
    for (final name in PerfTimeline.knownNames) {
      expect(pattern.hasMatch(name), isTrue, reason: name);
    }
  });

  test('marks are recorded in order with their time since navigation', () {
    now = 120;
    PerfTimeline.mark('boot.firebase');
    now = 400;
    PerfTimeline.mark('boot.appcheck');
    now = 900;
    PerfTimeline.mark('boot.runapp');

    expect(
      PerfTimeline.entries().map((e) => (e.name, e.ms)).toList(),
      [('boot.firebase', 120), ('boot.appcheck', 400), ('boot.runapp', 900)],
    );
  });

  test('a mark records only the first time it is reached', () {
    now = 100;
    PerfTimeline.mark('home.data');
    now = 5000;
    PerfTimeline.mark('home.data');

    expect(PerfTimeline.entries().single.ms, 100);
  });

  test('a measure records a duration in milliseconds', () {
    PerfTimeline.measure('screen.lesson', const Duration(milliseconds: 840));
    PerfTimeline.measure('screen.lesson', const Duration(milliseconds: 310));

    expect(
      PerfTimeline.entries().map((e) => (e.name, e.ms)).toList(),
      [('screen.lesson', 840), ('screen.lesson', 310)],
    );
  });

  test('times stay inside the wire limit', () {
    PerfTimeline.measure('screen.home', const Duration(hours: 3));
    PerfTimeline.measure('screen.quizend', const Duration(milliseconds: -5));

    expect(PerfTimeline.entries().map((e) => e.ms), [600000, 0]);
  });

  test('a name outside the contract asserts in debug', () {
    expect(() => PerfTimeline.mark('boot.unknown'), throwsAssertionError);
    expect(
      () => PerfTimeline.measure('screen.unknown', Duration.zero),
      throwsAssertionError,
    );
    expect(PerfTimeline.entries(), isEmpty);
  });

  test('entries cannot be changed from outside', () {
    PerfTimeline.mark('boot.firebase');

    expect(
      () => PerfTimeline.entries().add(const PerfEntry('boot.auth', 1)),
      throwsUnsupportedError,
    );
  });

  test('the timeline stops growing at its cap', () {
    for (var i = 0; i < PerfTimeline.maxEntries + 20; i++) {
      PerfTimeline.measure('screen.home', const Duration(milliseconds: 5));
    }

    expect(PerfTimeline.entries(), hasLength(PerfTimeline.maxEntries));
  });

  group('ScreenTimer', () {
    testWidgets('records the time to the first settled frame once', (
      tester,
    ) async {
      now = 1000;
      final timer = ScreenTimer('screen.lesson');
      var ready = false;
      late StateSetter update;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            timer.settled(ready: ready);
            return const SizedBox();
          },
        ),
      );
      expect(PerfTimeline.entries(), isEmpty, reason: 'still loading');

      now = 1700;
      update(() => ready = true);
      await tester.pump();
      now = 9000;
      update(() {});
      await tester.pump();

      final entries = PerfTimeline.entries();
      expect(entries, hasLength(1));
      expect(entries.single.name, 'screen.lesson');
      expect(entries.single.ms, 700);
    });

    testWidgets('a screen that never settles records nothing', (tester) async {
      final timer = ScreenTimer('screen.quizstart');

      await tester.pumpWidget(
        Builder(
          builder: (context) {
            timer.settled(ready: false);
            return const SizedBox();
          },
        ),
      );
      await tester.pump(const Duration(seconds: 2));

      expect(PerfTimeline.entries(), isEmpty);
    });
  });
}
