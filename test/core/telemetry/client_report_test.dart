import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/telemetry/client_report.dart';
import 'package:pantas/core/telemetry/perf_timeline.dart';

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

void main() {
  late _Sender sender;
  late DateTime clock;
  late List<PerfEntry> timings;
  late ClientReporter reporter;

  ClientReportContext context() => const ClientReportContext(
        build: '1293236267-5bbf79dc07b4',
        visit: 'return',
        browser: 'chrome',
        mobile: true,
        viewportWidth: 390,
      );

  setUp(() {
    sender = _Sender();
    clock = DateTime.utc(2026, 11, 8, 9);
    timings = [const PerfEntry('boot.firebase', 412)];
    reporter = ClientReporter(
      sender: sender,
      context: context,
      now: () => clock,
      timings: () => timings,
    );
  });

  tearDown(() => reporter.dispose());

  Future<void> open() async {
    reporter
      ..splashGone()
      ..firstScreenSettled();
    await pumpEventQueue();
  }

  group('the payload', () {
    test('always carries all eight contract keys, even when empty', () async {
      timings = [];
      await open();
      reporter.pageHidden();
      await pumpEventQueue();
      expect(sender.sent, isEmpty, reason: 'nothing to report, no call');

      timings = [const PerfEntry('boot.auth', 5)];
      reporter.pageHidden();
      await pumpEventQueue();

      final payload = sender.sent.single;
      expect(payload.keys.toSet(), _contractKeys);
      expect(payload['errors'], <Object?>[]);
      expect(payload['v'], 1);
      expect(payload['build'], '1293236267-5bbf79dc07b4');
      expect(payload['visit'], 'return');
      expect(payload['browser'], 'chrome');
      expect(payload['mobile'], isTrue);
      expect(payload['viewport'], 'phone');
      expect(payload['timings'], [
        {'n': 'boot.auth', 'ms': 5},
      ]);
    });

    test('an error-only report still has an empty timings list', () async {
      timings = [];
      reporter.addError(
        const ClientError(type: 'StateError', msg: 'Bad state', stack: []),
      );
      await open();

      final payload = sender.sent.single;
      expect(payload.keys.toSet(), _contractKeys);
      expect(payload['timings'], <Object?>[]);
      expect(payload['errors'], hasLength(1));
    });

    test('names no account, token or address anywhere', () async {
      await open();
      reporter
        ..addError(
          const ClientError(type: 'StateError', msg: 'Bad state', stack: ['a']),
        )
        ..pageHidden();
      await pumpEventQueue();

      for (final payload in sender.sent) {
        final text = jsonEncode(payload).toLowerCase();
        for (final word in ['uid', 'email', 'token', 'user', 'ip']) {
          expect(text.contains('"$word"'), isFalse, reason: word);
        }
        expect(payload.keys.toSet(), _contractKeys);
      }
    });

    test('keeps every value inside the contract limits', () async {
      reporter.addError(
        ClientError(
          type: 'T' * 100,
          msg: 'm' * 900,
          stack: [for (var i = 0; i < 20; i++) 's' * 500],
        ),
      );
      await open();

      final errors = sender.sent.single['errors']! as List;
      final error = errors.single as Map<String, Object?>;
      expect((error['type']! as String).length, 60);
      expect((error['msg']! as String).length, 300);
      final stack = error['stack']! as List;
      expect(stack, hasLength(8));
      expect(stack.every((s) => (s as String).length <= 200), isTrue);
      expect(error['count'], 1);
    });

    test('the build is cut to the contract alphabet and length', () async {
      reporter = ClientReporter(
        sender: sender,
        context: () => ClientReportContext(
          build: 'a b/c?d=${'x' * 60}',
          visit: 'first',
          browser: 'other',
          mobile: false,
          viewportWidth: 1400,
        ),
        now: () => clock,
        timings: () => timings,
      );
      await open();

      final build = sender.sent.single['build']! as String;
      expect(build.length, lessThanOrEqualTo(40));
      expect(RegExp(r'^[A-Za-z0-9._-]+$').hasMatch(build), isTrue);
      expect(sender.sent.single['viewport'], 'wide');
    });
  });

  group('when it sends', () {
    test('nothing goes before the splash is gone and the screen is ready',
        () async {
      reporter.splashGone();
      await pumpEventQueue();
      expect(sender.sent, isEmpty);

      reporter.firstScreenSettled();
      await pumpEventQueue();
      expect(sender.sent, hasLength(1));
    });

    test('the first report is sent once, however often the signals repeat',
        () async {
      await open();
      reporter
        ..splashGone()
        ..firstScreenSettled();
      await pumpEventQueue();

      expect(sender.sent, hasLength(1));
    });

    test('later reports wait 60 seconds and need new data', () async {
      await open();

      timings = [...timings, const PerfEntry('home.data', 900)];
      clock = clock.add(const Duration(seconds: 59));
      reporter.tick();
      await pumpEventQueue();
      expect(sender.sent, hasLength(1), reason: 'too soon');

      clock = clock.add(const Duration(seconds: 1));
      reporter.tick();
      await pumpEventQueue();
      expect(sender.sent, hasLength(2));
      expect(
        sender.sent.last['timings'],
        [
          {'n': 'home.data', 'ms': 900},
        ],
        reason: 'only what was not sent before',
      );

      clock = clock.add(const Duration(minutes: 5));
      reporter.tick();
      await pumpEventQueue();
      expect(sender.sent, hasLength(2), reason: 'no new data, no call');
    });

    test('hiding the page sends new data at once, but never an empty report',
        () async {
      await open();
      reporter.pageHidden();
      await pumpEventQueue();
      expect(sender.sent, hasLength(1), reason: 'nothing new');

      timings = [...timings, const PerfEntry('screen.lesson', 700)];
      reporter.pageHidden();
      await pumpEventQueue();
      expect(sender.sent, hasLength(2));
    });

    test('a page hidden before the first screen still reports what it has',
        () async {
      reporter.pageHidden();
      await pumpEventQueue();

      expect(sender.sent, hasLength(1));
    });

    test('a slow send is never doubled', () async {
      sender.hold = Completer<void>();
      await open();
      timings = [...timings, const PerfEntry('home.data', 900)];
      reporter.pageHidden();
      await pumpEventQueue();
      sender.hold!.complete();
      await pumpEventQueue();

      expect(sender.sent, hasLength(1));
    });

    test('more than 40 new timings go out 40 at a time', () async {
      timings = [
        for (var i = 0; i < 55; i++) PerfEntry('screen.home', i + 1),
      ];
      await open();
      expect(
        sender.sent.single['timings']! as List,
        hasLength(40),
      );

      reporter.pageHidden();
      await pumpEventQueue();
      expect(sender.sent.last['timings']! as List, hasLength(15));
    });

    test('a repeated identical timing is still counted once per occurrence',
        () async {
      timings = [const PerfEntry('screen.home', 300)];
      await open();
      timings = [...timings, const PerfEntry('screen.home', 300)];
      reporter.pageHidden();
      await pumpEventQueue();

      expect(sender.sent, hasLength(2));
    });
  });

  group('errors', () {
    ClientError error(String type, {List<String> stack = const ['f:1']}) =>
        ClientError(type: type, msg: 'x', stack: stack);

    test('the same type and first frame count up instead of repeating',
        () async {
      reporter
        ..addError(error('StateError'))
        ..addError(error('StateError'))
        ..addError(error('StateError', stack: ['g:2']));
      await open();

      final errors = sender.sent.single['errors']! as List;
      expect(errors, hasLength(2));
      expect(
        errors.map((e) => (e as Map)['count']).toList()..sort(),
        [1, 2],
      );
    });

    test('a later repeat sends only the new count', () async {
      reporter.addError(error('StateError'));
      await open();

      reporter
        ..addError(error('StateError'))
        ..addError(error('StateError'))
        ..pageHidden();
      await pumpEventQueue();

      final errors = sender.sent.last['errors']! as List;
      expect((errors.single as Map)['count'], 2);
    });

    test('keeps at most 20 distinct errors a session', () async {
      for (var i = 0; i < 30; i++) {
        reporter.addError(error('Error$i'));
      }
      await open();
      expect(sender.sent.single['errors']! as List, hasLength(10));

      reporter.pageHidden();
      await pumpEventQueue();
      expect(sender.sent.last['errors']! as List, hasLength(10));

      reporter.pageHidden();
      await pumpEventQueue();
      expect(sender.sent, hasLength(2), reason: 'the other ten were dropped');
    });

    test('a count never passes the contract limit', () async {
      for (var i = 0; i < 1500; i++) {
        reporter.addError(error('Loop'));
      }
      await open();

      final errors = sender.sent.single['errors']! as List;
      expect((errors.single as Map)['count'], 1000);
    });
  });

  group('the speed and error report switch', () {
    test('off: nothing is sent and the queue is dropped', () async {
      reporter
        ..addError(
          const ClientError(type: 'StateError', msg: 'old', stack: ['a']),
        )
        ..enabled = false;
      await open();
      reporter
        ..addError(
          const ClientError(type: 'StateError', msg: 'new', stack: ['b']),
        )
        ..recordError(StateError('later'), StackTrace.current)
        ..pageHidden()
        ..tick();
      await pumpEventQueue();
      expect(sender.sent, isEmpty);

      // Turning it back on does not release what was queued while it was off.
      reporter
        ..enabled = true
        ..pageHidden();
      await pumpEventQueue();
      expect(sender.sent, isEmpty);

      reporter
        ..addError(
          const ClientError(type: 'TypeError', msg: 'fresh', stack: ['c']),
        )
        ..pageHidden();
      await pumpEventQueue();
      final errors = sender.sent.single['errors']! as List;
      expect(errors, hasLength(1));
      expect((errors.single as Map)['type'], 'TypeError');
      expect(sender.sent.single['timings'], <Object?>[]);
    });

    test('on by default', () {
      expect(reporter.enabled, isTrue);
    });
  });

  group('failure', () {
    test('a failing send is swallowed and tried once more later', () async {
      sender.failWith = 'offline';
      await open();
      expect(sender.sent, isEmpty);

      sender.failWith = null;
      clock = clock.add(const Duration(seconds: 61));
      reporter.tick();
      await pumpEventQueue();
      expect(sender.sent, hasLength(1), reason: 'the one retry');
      expect(sender.sent.single['timings'], [
        {'n': 'boot.firebase', 'ms': 412},
      ]);
    });

    test('after the retry also fails the data is dropped, not retried again',
        () async {
      sender.failWith = 'offline';
      await open();
      clock = clock.add(const Duration(seconds: 61));
      reporter.tick();
      await pumpEventQueue();

      sender.failWith = null;
      clock = clock.add(const Duration(seconds: 61));
      reporter.tick();
      await pumpEventQueue();
      expect(sender.sent, isEmpty);
    });

    test('a sender that throws at once cannot throw out of the reporter',
        () async {
      final broken = ClientReporter(
        sender: _ThrowsAtOnce(),
        context: () => throw StateError('no browser'),
        now: () => clock,
        timings: () => throw StateError('no timeline'),
      );
      addTearDown(broken.dispose);

      broken
        ..addError(
          const ClientError(type: 'E', msg: 'm', stack: []),
        )
        ..splashGone()
        ..firstScreenSettled()
        ..tick()
        ..pageHidden();
      await pumpEventQueue();
    });
  });

  group('cleaning an error before it leaves the device', () {
    ClientError clean(Object error, [StackTrace? stack]) =>
        sanitizeError(error, stack ?? StackTrace.empty);

    test('keeps the type and a plain message', () {
      final cleaned = clean(StateError('no plan'));

      expect(cleaned.type, 'StateError');
      expect(cleaned.msg, 'Bad state: no plan');
    });

    test('cuts the message to 300 characters', () {
      expect(clean(Exception('word ' * 200)).msg.length, 300);
    });

    test('removes an email address', () {
      final cleaned = clean(
        Exception('No account for maria.santos@example.com found'),
      );

      expect(cleaned.msg, 'Exception: No account for <x> found');
    });

    test('removes a run of six or more digits, but keeps short numbers', () {
      final cleaned = clean(
        Exception('phone 09171234567 code 123456 line 42 id 12345'),
      );

      expect(cleaned.msg, 'Exception: phone <x> code <x> line 42 id 12345');
    });

    test('removes the query string and fragment of a URL', () {
      final cleaned = clean(
        Exception(
          'Failed https://app.pantas.study/x?code=abc&state=def after, '
          'then https://app.pantas.study/y#access_token=zzz end',
        ),
      );

      expect(cleaned.msg, contains('https://app.pantas.study/x?<x>'));
      expect(cleaned.msg, contains('https://app.pantas.study/y#<x>'));
      expect(cleaned.msg, isNot(contains('abc')));
      expect(cleaned.msg, isNot(contains('access_token')));
    });

    test('removes anything that looks like a token', () {
      final cleaned = clean(
        Exception(
          'bad bearer eyJhbGciOiJIUzI1NiJ9abcdefghijklmnop and '
          'AIzaSyA_-1234567890abcdefghij and short_token',
        ),
      );

      expect(cleaned.msg, 'Exception: bad bearer <x> and <x> and short_token');
    });

    test('keeps only package frames with their line numbers', () {
      final cleaned = clean(
        StateError('x'),
        StackTrace.fromString(
          '#0      Foo.bar (package:pantas/features/home/x.dart:12:5)\n'
          '#1      _rootRun (dart:async/zone.dart:1399:13)\n'
          '#2      Baz.qux (file:///Users/maria/secret/app.dart:3:4)\n'
          '#3      main (package:pantas/main.dart:7:3)',
        ),
      );

      expect(cleaned.stack, [
        'package:pantas/features/home/x.dart:12:5',
        'package:pantas/main.dart:7:3',
      ]);
    });

    test('keeps a minified web frame as file and position, with no host', () {
      final cleaned = clean(
        StateError('x'),
        StackTrace.fromString(
          'at Object.bar (https://app.pantas.study/main.dart.js:12345:67)\n'
          'at https://app.pantas.study/main.dart.js?v=secret:9:8',
        ),
      );

      expect(cleaned.stack, ['main.dart.js:12345:67', 'main.dart.js:9:8']);
    });

    test('keeps at most eight frames of at most 200 characters', () {
      final frames = [
        for (var i = 0; i < 20; i++) '#$i  f (package:pantas/a.dart:$i:1)',
      ].join('\n');

      final cleaned = clean(StateError('x'), StackTrace.fromString(frames));

      expect(cleaned.stack, hasLength(8));
      expect(cleaned.stack.every((f) => f.length <= 200), isTrue);
    });

    test('an error whose text cannot be read still reports its type', () {
      final cleaned = clean(_Unprintable());

      expect(cleaned.type, '_Unprintable');
      expect(cleaned.msg, '');
    });

    test('the reporter turns a thrown error into one cleaned entry', () async {
      timings = [];
      reporter
        ..recordError(
          StateError('mail a@b.co now'),
          StackTrace.fromString('#0 f (package:pantas/a.dart:1:2)'),
        )
        ..recordError(
          StateError('mail c@d.co now'),
          StackTrace.fromString('#0 f (package:pantas/a.dart:1:2)'),
        );
      await open();

      final errors = sender.sent.single['errors']! as List;
      final error = errors.single as Map;
      expect(error['type'], 'StateError');
      expect(error['msg'], 'Bad state: mail <x> now');
      expect(error['count'], 2, reason: 'same type and first frame');
    });
  });

  group('the browser summary', () {
    test('names the browser family', () {
      const agents = {
        'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 Chrome/126.0 '
            'Mobile Safari/537.36': 'chrome',
        'Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) '
                'AppleWebKit/605.1.15 Version/17.5 Mobile/15E148 Safari/604.1':
            'safari',
        'Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) '
                'AppleWebKit/605.1.15 CriOS/126.0 Mobile/15E148 Safari/604.1':
            'chrome',
        'Mozilla/5.0 (Windows NT 10.0; rv:127.0) Gecko/20100101 Firefox/127.0':
            'firefox',
        'Mozilla/5.0 (Windows NT 10.0) AppleWebKit/537.36 Chrome/126.0 '
            'Safari/537.36 Edg/126.0': 'edge',
        'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 '
            'SamsungBrowser/25.0 Chrome/121.0 Mobile Safari/537.36': 'samsung',
        'curl/8.0': 'other',
        '': 'other',
      };
      for (final MapEntry(key: agent, value: family) in agents.entries) {
        expect(browserFamily(agent), family, reason: agent);
      }
    });

    test('sorts the viewport into phone, tablet and wide', () {
      expect(viewportClass(320), 'phone');
      expect(viewportClass(599), 'phone');
      expect(viewportClass(600), 'tablet');
      expect(viewportClass(1023), 'tablet');
      expect(viewportClass(1024), 'wide');
    });

    test('knows a phone browser from the agent string', () {
      const phone = 'Mozilla/5.0 (Linux; Android 14) Mobile Safari';
      const desktop = 'Mozilla/5.0 (Windows NT 10.0) Chrome/126';
      expect(isMobileAgent(phone), isTrue);
      expect(isMobileAgent(desktop), isFalse);
    });
  });
}

class _ThrowsAtOnce implements ClientReportSender {
  @override
  Future<void> send(Map<String, Object?> payload) =>
      throw StateError('sync failure');
}

class _Unprintable {
  @override
  String toString() => throw StateError('no text');
}
