import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/telemetry/gated_telemetry.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/core/telemetry/usage_visit.dart';

class _Inner implements Telemetry {
  final logged = <(TelemetryEvent, Map<String, Object>?)>[];
  final enabledCalls = <bool>[];

  @override
  Future<void> log(
    TelemetryEvent event, {
    Map<String, Object>? properties,
  }) async {
    logged.add((event, properties));
  }

  @override
  Future<void> recordError(Object error, StackTrace stack) async {}

  @override
  Future<void> setEnabled({required bool enabled}) async {
    enabledCalls.add(enabled);
  }

  @override
  Future<void> setUserIdentifier(String identifier) async {}
}

class _Sender implements UsageVisitSender {
  final sent = <Map<String, Object?>>[];
  bool fail = false;
  Completer<void>? hold;

  @override
  Future<void> send(Map<String, Object?> payload) async {
    sent.add(payload);
    await hold?.future;
    if (fail) throw StateError('network');
  }
}

class _Rig {
  _Rig({String build = '12345-abcdef'}) {
    recorder = UsageVisitTelemetry(
      inner: inner,
      sender: sender,
      build: () => build,
      now: () => clock,
      visitId: '0123456789abcdef',
      listenPageHidden: hidden.add,
    );
  }

  final inner = _Inner();
  final sender = _Sender();
  final hidden = <void Function()>[];
  DateTime clock = DateTime.utc(2026, 11, 14, 10);
  late final UsageVisitTelemetry recorder;

  Future<void> view(String screen, {int afterMs = 0}) async {
    clock = clock.add(Duration(milliseconds: afterMs));
    await recorder.log(
      TelemetryEvent.screenViewed,
      properties: {'screen': screen},
    );
  }

  void pageHidden() {
    for (final callback in hidden) {
      callback();
    }
  }
}

Future<_Rig> _enabled() async {
  final rig = _Rig();
  await rig.recorder.setEnabled(enabled: true);
  return rig;
}

void main() {
  test('every event is forwarded to the inner sink, screen views too',
      () async {
    final rig = await _enabled();
    await rig.view('home');
    await rig.recorder.log(TelemetryEvent.sessionStarted);

    expect(rig.inner.logged.map((e) => e.$1), [
      TelemetryEvent.screenViewed,
      TelemetryEvent.sessionStarted,
    ]);
    expect(rig.inner.logged.first.$2, {'screen': 'home'});
  });

  test('a page hidden sends the visit so far with milliseconds since start',
      () async {
    final rig = _Rig();
    await rig.recorder.setEnabled(enabled: true);
    await rig.view('home', afterMs: 1500);
    await rig.view('study', afterMs: 2500);
    rig.pageHidden();
    await pumpEventQueue();

    expect(rig.sender.sent, hasLength(1));
    expect(rig.sender.sent.single, {
      'v': 1,
      'build': '12345-abcdef',
      'visit_id': '0123456789abcdef',
      'screens': [
        {'s': 'home', 't': 1500},
        {'s': 'study', 't': 4000},
      ],
    });
  });

  test('nothing is sent when nothing is new', () async {
    final rig = await _enabled();
    rig.pageHidden();
    await pumpEventQueue();
    expect(rig.sender.sent, isEmpty);

    await rig.view('home');
    rig.pageHidden();
    await pumpEventQueue();
    rig.pageHidden();
    await pumpEventQueue();
    expect(rig.sender.sent, hasLength(1));
  });

  test('the record goes out as soon as 20 screens are waiting', () async {
    final rig = await _enabled();
    for (var i = 0; i < 19; i++) {
      await rig.view(i.isEven ? 'home' : 'study', afterMs: 10);
    }
    await pumpEventQueue();
    expect(rig.sender.sent, isEmpty);

    await rig.view('plan', afterMs: 10);
    await pumpEventQueue();
    expect(rig.sender.sent, hasLength(1));
    expect(rig.sender.sent.single['screens']! as List<Object?>, hasLength(20));

    await rig.view('home', afterMs: 10);
    rig.pageHidden();
    await pumpEventQueue();
    expect(rig.sender.sent, hasLength(2));
    final second = rig.sender.sent.last;
    expect(second['visit_id'], '0123456789abcdef');
    expect(second['screens'], [
      {'s': 'home', 't': 210},
    ]);
  });

  test('a record never holds more than 100 screens', () async {
    final rig = await _enabled();
    rig.sender.hold = Completer<void>();
    for (var i = 0; i < 150; i++) {
      await rig.view('home', afterMs: 1);
    }
    rig.sender.hold!.complete();
    await pumpEventQueue();
    rig.pageHidden();
    await pumpEventQueue();
    for (final payload in rig.sender.sent) {
      expect(
        (payload['screens']! as List<Object?>).length,
        lessThanOrEqualTo(100),
      );
    }
  });

  test('a name outside the closed set is ignored', () async {
    final rig = await _enabled();
    await rig.view('/lesson/secret');
    await rig.view('Lesson 42');
    await rig.view('startup');
    rig.pageHidden();
    await pumpEventQueue();
    expect(rig.sender.sent, isEmpty);
  });

  test('nothing is recorded until collection is switched on', () async {
    final rig = _Rig();
    await rig.view('home');
    rig.pageHidden();
    await pumpEventQueue();
    expect(rig.sender.sent, isEmpty);
  });

  test('switching collection off drops what was waiting and stops recording',
      () async {
    final rig = await _enabled();
    await rig.view('home');
    await rig.recorder.setEnabled(enabled: false);
    await rig.view('study');
    await rig.recorder.setEnabled(enabled: true);
    rig.pageHidden();
    await pumpEventQueue();
    expect(rig.sender.sent, isEmpty);
    expect(rig.inner.enabledCalls, [true, false, true]);
  });

  test('a choice change while a send is out does not lose newer screens',
      () async {
    final rig = await _enabled();
    rig.sender.hold = Completer<void>();
    await rig.view('home');
    rig.pageHidden();
    await pumpEventQueue();
    await rig.recorder.setEnabled(enabled: false);
    await rig.recorder.setEnabled(enabled: true);
    await rig.view('study', afterMs: 5);
    rig.sender.hold!.complete();
    await pumpEventQueue();
    rig.sender.hold = null;
    rig.pageHidden();
    await pumpEventQueue();
    expect(rig.sender.sent.last['screens'], [
      {'s': 'study', 't': 5},
    ]);
  });

  test('a closed consent gate keeps the record empty', () async {
    final rig = _Rig();
    final gated = GatedTelemetry(rig.recorder, consent: false);
    await rig.recorder.setEnabled(enabled: true);
    await gated.log(
      TelemetryEvent.screenViewed,
      properties: {'screen': 'home'},
    );
    rig.pageHidden();
    await pumpEventQueue();
    expect(rig.sender.sent, isEmpty);
    expect(rig.inner.logged, isEmpty);
  });

  test('a failed send is kept once more, then dropped, and never throws',
      () async {
    final rig = await _enabled();
    rig.sender.fail = true;
    await rig.view('home');
    rig.pageHidden();
    await pumpEventQueue();
    expect(rig.sender.sent, hasLength(1));

    rig.pageHidden();
    await pumpEventQueue();
    expect(rig.sender.sent, hasLength(2));
    expect(rig.sender.sent.last['screens'], rig.sender.sent.first['screens']);

    rig.pageHidden();
    await pumpEventQueue();
    expect(rig.sender.sent, hasLength(2), reason: 'dropped after the retry');
  });

  test('the record carries no key beyond the contract', () async {
    final rig = await _enabled();
    await rig.view('home');
    rig.pageHidden();
    await pumpEventQueue();
    final payload = rig.sender.sent.single;
    expect(payload.keys.toSet(), {'v', 'build', 'visit_id', 'screens'});
    for (final screen in payload['screens']! as List<Object?>) {
      expect((screen! as Map<String, Object?>).keys.toSet(), {'s', 't'});
    }
  });

  test('outside a web page the sink is returned unchanged', () {
    final inner = _Inner();
    expect(UsageVisitTelemetry.wrapForWeb(inner), same(inner));
  });

  test('the visit id is 16 random hex characters, new for each start', () {
    final a = generateVisitId();
    final b = generateVisitId();
    expect(RegExp(r'^[0-9a-f]{16}$').hasMatch(a), isTrue);
    expect(a, isNot(b));
  });

  test('a build string is cleaned to the characters the server accepts',
      () async {
    final rig = _Rig(build: 'bad build;1');
    await rig.recorder.setEnabled(enabled: true);
    await rig.view('home');
    rig.pageHidden();
    await pumpEventQueue();
    expect(rig.sender.sent.single['build'], 'bad_build_1');
  });
}
