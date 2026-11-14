import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/telemetry/client_report.dart';
import 'package:pantas/core/telemetry/perf_timeline.dart';
import 'package:pantas/core/telemetry/screen_counts.dart';

class _Sender implements ClientReportSender {
  final sent = <Map<String, Object?>>[];
  String? failWith;
  Completer<void>? hold;

  @override
  Future<void> send(Map<String, Object?> payload) async {
    final gate = hold;
    if (gate != null) await gate.future;
    final failure = failWith;
    if (failure != null) throw StateError(failure);
    sent.add(payload);
  }
}

const _contractKeys = {
  'v',
  'build',
  'visit',
  'browser',
  'mobile',
  'viewport',
  'timings',
  'errors',
};

void main() {
  late _Sender sender;
  late DateTime clock;
  late List<PerfEntry> timings;
  final reporters = <ClientReporter>[];

  ClientReporter make({required bool screenCounts}) {
    final reporter = ClientReporter(
      sender: sender,
      context: () => const ClientReportContext(
        build: 'b1',
        visit: 'return',
        browser: 'chrome',
        mobile: true,
        viewportWidth: 390,
      ),
      now: () => clock,
      timings: () => timings,
      screenCounts: screenCounts,
    );
    reporters.add(reporter);
    return reporter;
  }

  setUp(() {
    sender = _Sender();
    clock = DateTime.utc(2026, 11, 14, 9);
    timings = [];
  });

  tearDown(() {
    for (final reporter in reporters) {
      reporter.dispose();
    }
    reporters.clear();
  });

  List<Map<String, Object?>> screensOf(Map<String, Object?> payload) =>
      (payload['screens']! as List).cast<Map<String, Object?>>();

  group('the flag', () {
    test('is off in the code as shipped', () {
      expect(screenCountsInClientReports, isFalse);
    });

    test('off: no collection and no new key', () async {
      final reporter = make(screenCounts: false)
        ..recordScreen('home')
        ..recordScreen('study')
        ..pageHidden();
      await pumpEventQueue();
      expect(sender.sent, isEmpty, reason: 'screens alone are not data');

      timings = [const PerfEntry('boot.auth', 5)];
      reporter.pageHidden();
      await pumpEventQueue();
      final payload = sender.sent.single;
      expect(payload.keys.toSet(), _contractKeys);
      expect(payload.containsKey('screens'), isFalse);
    });

    test('a reporter made without the argument follows the flag', () async {
      final reporter = ClientReporter(
        sender: sender,
        context: () => const ClientReportContext(
          build: 'b1',
          visit: 'return',
          browser: 'chrome',
          mobile: true,
          viewportWidth: 390,
        ),
        now: () => clock,
        timings: () => timings,
      );
      reporters.add(reporter);
      timings = [const PerfEntry('boot.auth', 5)];
      reporter
        ..recordScreen('home')
        ..pageHidden();
      await pumpEventQueue();
      expect(sender.sent.single.containsKey('screens'), isFalse);
    });
  });

  group('counts', () {
    test('count each screen, sorted by screen id, with only s first last n',
        () async {
      make(screenCounts: true)
        ..recordScreen('study')
        ..recordScreen('home')
        ..recordScreen('study')
        ..recordScreen('lesson')
        ..recordScreen('study')
        ..pageHidden();
      await pumpEventQueue();

      final payload = sender.sent.single;
      expect(payload.keys.toSet(), {..._contractKeys, 'screens'});
      final screens = screensOf(payload);
      expect(screens.map((e) => e['s']), ['home', 'lesson', 'study']);
      expect(screens.map((e) => e['n']), [1, 1, 3]);
      for (final entry in screens) {
        expect(entry.keys.toSet(), {'s', 'first', 'last', 'n'});
      }
    });

    test('the same screen twice in a row is one view', () async {
      make(screenCounts: true)
        ..recordScreen('home')
        ..recordScreen('home')
        ..recordScreen('study')
        ..recordScreen('home')
        ..pageHidden();
      await pumpEventQueue();
      final counts = {
        for (final e in screensOf(sender.sent.single)) e['s']: e['n'],
      };
      expect(counts, {'home': 2, 'study': 1});
    });

    test('first marks only the first screen of the visit', () async {
      make(screenCounts: true)
        ..recordScreen('study')
        ..recordScreen('home')
        ..recordScreen('study')
        ..pageHidden();
      await pumpEventQueue();
      final firsts = [
        for (final e in screensOf(sender.sent.single))
          if (e['first']! as bool) e['s'],
      ];
      expect(firsts, ['study']);
    });

    test('names no account, visit, time or order', () async {
      make(screenCounts: true)
        ..recordScreen('home')
        ..recordScreen('study')
        ..pageHidden();
      await pumpEventQueue();
      final text = jsonEncode(sender.sent.single['screens']);
      for (final word in ['uid', 'visit', 'visit_id', 't', 'at', 'time']) {
        expect(text.contains('"$word"'), isFalse, reason: word);
      }
    });

    test('a count above 1000 is capped and the rest goes in the next report',
        () async {
      final reporter = make(screenCounts: true);
      for (var i = 0; i < 1500; i++) {
        reporter
          ..recordScreen('home')
          ..recordScreen('study');
      }
      reporter.pageHidden();
      await pumpEventQueue();
      expect(
        screensOf(sender.sent.single).map((e) => e['n']),
        everyElement(1000),
      );
      reporter.pageHidden();
      await pumpEventQueue();
      expect(sender.sent, hasLength(2));
      expect(
        screensOf(sender.sent.last).map((e) => e['n']),
        everyElement(500),
      );
    });
  });

  group('after a send', () {
    test('counts reset, so a view is never counted twice', () async {
      final reporter = make(screenCounts: true)
        ..recordScreen('home')
        ..recordScreen('study')
        ..pageHidden();
      await pumpEventQueue();
      reporter.pageHidden();
      await pumpEventQueue();
      expect(sender.sent, hasLength(1), reason: 'nothing new, no call');

      reporter
        ..recordScreen('lesson')
        ..pageHidden();
      await pumpEventQueue();
      final second = screensOf(sender.sent.last);
      expect(second.map((e) => e['s']), ['lesson']);
      expect(second.single['n'], 1);
    });

    test('first is sent once, in the report that carries it', () async {
      final reporter = make(screenCounts: true)
        ..recordScreen('home')
        ..recordScreen('study')
        ..pageHidden();
      await pumpEventQueue();
      reporter
        ..recordScreen('home')
        ..pageHidden();
      await pumpEventQueue();
      expect(
        screensOf(sender.sent.last).map((e) => e['first']),
        [false],
      );
    });

    test('a failed send keeps the counts for the retry', () async {
      final reporter = make(screenCounts: true)..recordScreen('home');
      sender.failWith = 'offline';
      reporter.pageHidden();
      await pumpEventQueue();
      expect(sender.sent, isEmpty);

      sender.failWith = null;
      reporter.pageHidden();
      await pumpEventQueue();
      final screens = screensOf(sender.sent.single);
      expect(screens.single['n'], 1);
      expect(screens.single['first'], isTrue);
    });

    test('a view that arrives during a send goes in the next report', () async {
      final reporter = make(screenCounts: true)..recordScreen('home');
      sender.hold = Completer<void>();
      reporter
        ..pageHidden()
        ..recordScreen('study');
      sender.hold!.complete();
      sender.hold = null;
      await pumpEventQueue();
      expect(screensOf(sender.sent.single).map((e) => e['s']), ['home']);

      reporter.pageHidden();
      await pumpEventQueue();
      expect(screensOf(sender.sent.last).map((e) => e['s']), ['study']);
    });
  });

  group('last', () {
    test('page hide marks the current screen as last', () async {
      make(screenCounts: true)
        ..recordScreen('home')
        ..recordScreen('study')
        ..pageHidden();
      await pumpEventQueue();
      final lasts = {
        for (final e in screensOf(sender.sent.single)) e['s']: e['last'],
      };
      expect(lasts, {'home': false, 'study': true});
    });

    test('a report sent on the timer never marks last', () async {
      timings = [const PerfEntry('boot.auth', 5)];
      final reporter = make(screenCounts: true)
        ..splashGone()
        ..firstScreenSettled();
      await pumpEventQueue();
      expect(sender.sent, hasLength(1), reason: 'the opening report');
      reporter
        ..recordScreen('home')
        ..recordScreen('study');
      clock = clock.add(const Duration(minutes: 2));
      reporter.tick();
      await pumpEventQueue();
      expect(sender.sent, hasLength(2));
      final screens = screensOf(sender.sent.last);
      expect(screens.map((e) => e['s']), ['home'], reason: 'study is held');
      expect(screens.map((e) => e['last']), everyElement(isFalse));
    });

    test('a timer report never carries the current screen', () async {
      timings = [const PerfEntry('boot.auth', 5)];
      final reporter = make(screenCounts: true)
        ..splashGone()
        ..firstScreenSettled();
      await pumpEventQueue();
      reporter.recordScreen('home');
      clock = clock.add(const Duration(minutes: 2));
      reporter.tick();
      await pumpEventQueue();
      expect(sender.sent, hasLength(1), reason: 'only the held screen is new');
    });

    test('the held screen goes out once on page hide, marked last', () async {
      timings = [const PerfEntry('boot.auth', 5)];
      final reporter = make(screenCounts: true)
        ..splashGone()
        ..firstScreenSettled();
      await pumpEventQueue();
      reporter
        ..recordScreen('home')
        ..recordScreen('study');
      clock = clock.add(const Duration(minutes: 2));
      reporter.tick();
      await pumpEventQueue();
      reporter.pageHidden();
      await pumpEventQueue();
      reporter.pageHidden();
      await pumpEventQueue();

      expect(sender.sent, hasLength(3));
      final byReport = [
        for (final p in sender.sent.skip(1))
          {for (final e in screensOf(p)) e['s']: '${e['n']}${e['last']}'},
      ];
      expect(byReport, [
        {'home': '1false'},
        {'study': '1true'},
      ]);
    });

    test('a held screen that is left goes in the next timer report', () async {
      timings = [const PerfEntry('boot.auth', 5)];
      final reporter = make(screenCounts: true)
        ..splashGone()
        ..firstScreenSettled();
      await pumpEventQueue();
      reporter.recordScreen('home');
      clock = clock.add(const Duration(minutes: 2));
      reporter
        ..recordScreen('study')
        ..tick();
      await pumpEventQueue();
      expect(screensOf(sender.sent.last).single['s'], 'home');
      expect(screensOf(sender.sent.last).single['first'], isTrue);
    });

    test('nothing new on a second page hide, so no last', () async {
      final reporter = make(screenCounts: true)
        ..recordScreen('home')
        ..recordScreen('study')
        ..pageHidden();
      await pumpEventQueue();
      timings = [const PerfEntry('boot.auth', 5)];
      reporter.pageHidden();
      await pumpEventQueue();
      expect(sender.sent.last.containsKey('screens'), isFalse);
    });
  });

  group('the speed and error switch', () {
    test('off drops pending counts at once and nothing is sent', () async {
      final reporter = make(screenCounts: true)
        ..recordScreen('home')
        ..recordScreen('study')
        ..enabled = false
        ..enabled = true;
      timings = [const PerfEntry('boot.auth', 5)];
      reporter.pageHidden();
      await pumpEventQueue();
      expect(sender.sent.single.containsKey('screens'), isFalse);
    });

    test('off stops collection', () async {
      make(screenCounts: true)
        ..enabled = false
        ..recordScreen('home')
        ..recordScreen('study')
        ..enabled = true
        ..pageHidden();
      await pumpEventQueue();
      expect(sender.sent, isEmpty);
    });

    test('a screen opened while off is not the visit first after turning on',
        () async {
      make(screenCounts: true)
        ..enabled = false
        ..recordScreen('home')
        ..enabled = true
        ..recordScreen('study')
        ..pageHidden();
      await pumpEventQueue();
      expect(
        screensOf(sender.sent.single).map((e) => e['first']),
        [false],
      );
    });

    test('with the counts on, the flag does not need usage sharing', () async {
      // The reporter has no link to the usage-sharing choice at all.
      make(screenCounts: true)
        ..recordScreen('home')
        ..pageHidden();
      await pumpEventQueue();
      expect(sender.sent, hasLength(1));
    });
  });
}
