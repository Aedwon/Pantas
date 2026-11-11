import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/telemetry/client_report.dart';
import 'package:pantas/core/telemetry/gated_telemetry.dart';
import 'package:pantas/core/telemetry/telemetry.dart';

/// Records what reached the SDK seam, so the gate can be proven rather than
/// inspected.
class _RecordingTelemetry implements Telemetry {
  final logged = <TelemetryEvent>[];
  final errors = <Object>[];
  final enabledCalls = <bool>[];

  @override
  Future<void> log(
    TelemetryEvent event, {
    Map<String, Object>? properties,
  }) async {
    logged.add(event);
  }

  @override
  Future<void> recordError(Object error, StackTrace stack) async {
    errors.add(error);
  }

  @override
  Future<void> setEnabled({required bool enabled}) async {
    enabledCalls.add(enabled);
  }

  @override
  Future<void> setUserIdentifier(String identifier) async {}
}

void main() {
  group('the gate', () {
    test('collects nothing before the student has answered', () {
      final gated = GatedTelemetry(_RecordingTelemetry(), consent: null);

      expect(gated.isCollecting, isFalse);
    });

    test('collects nothing when consent is off', () {
      final gated = GatedTelemetry(_RecordingTelemetry(), consent: false);

      expect(gated.isCollecting, isFalse);
    });

    test('collects when consent is on', () {
      final gated = GatedTelemetry(_RecordingTelemetry(), consent: true);

      expect(gated.isCollecting, isTrue);
    });
  });

  group('nothing reaches the SDK unless consent is on', () {
    test('an event is dropped when unanswered', () async {
      final sink = _RecordingTelemetry();
      final gated = GatedTelemetry(sink, consent: null);

      await gated.log(TelemetryEvent.sessionStarted);

      expect(sink.logged, isEmpty);
    });

    test('an error is dropped when consent is off', () async {
      final sink = _RecordingTelemetry();
      final gated = GatedTelemetry(sink, consent: false);

      await gated.recordError(StateError('x'), StackTrace.current);

      expect(sink.errors, isEmpty);
    });

    test('both pass through when consent is on', () async {
      final sink = _RecordingTelemetry();
      final gated = GatedTelemetry(sink, consent: true);

      await gated.log(TelemetryEvent.sessionStarted);
      await gated.recordError(StateError('x'), StackTrace.current);

      expect(sink.logged, hasLength(1));
      expect(sink.errors, hasLength(1));
    });
  });

  group('turning consent off stops collection at the SDK', () {
    test('setEnabled(false) is forwarded even though the gate is closed',
        () async {
      final sink = _RecordingTelemetry();
      final gated = GatedTelemetry(sink, consent: false);

      await gated.setEnabled(enabled: false);

      // The gate must not swallow this one: stopping collection has to reach
      // the SDK, or data keeps leaving the device while the gate filters
      // locally. That is the difference between a promise and a pretense.
      expect(sink.enabledCalls, [false]);
    });

    test('setEnabled(true) is forwarded when consent is on', () async {
      final sink = _RecordingTelemetry();
      final gated = GatedTelemetry(sink, consent: true);

      await gated.setEnabled(enabled: true);

      expect(sink.enabledCalls, [true]);
    });
  });

  group('web speed and error reports are not usage sharing', () {
    late _ReportSender sender;
    late ClientReporter reporter;

    setUp(() {
      sender = _ReportSender();
      reporter = ClientReporter(
        sender: sender,
        context: () => const ClientReportContext(
          build: 'b',
          visit: 'return',
          browser: 'chrome',
          mobile: false,
          viewportWidth: 1200,
        ),
        timings: () => const [],
      );
      ClientReporter.active = reporter;
    });

    tearDown(() => reporter.dispose());

    for (final consent in <bool?>[null, false, true]) {
      test('an error reaches the web reporter when consent is $consent',
          () async {
        final sink = _RecordingTelemetry();
        final gated = GatedTelemetry(sink, consent: consent);

        await gated.recordError(StateError('boom'), StackTrace.current);
        reporter
          ..splashGone()
          ..firstScreenSettled();
        await pumpEventQueue();

        final errors = sender.sent.single['errors']! as List;
        expect((errors.single as Map)['type'], 'StateError');
        expect(sink.errors, consent ?? false ? hasLength(1) : isEmpty);
      });
    }

    test('events still need consent, and carry nothing to the reporter',
        () async {
      final gated = GatedTelemetry(_RecordingTelemetry(), consent: false);

      await gated.log(TelemetryEvent.sessionStarted);
      reporter
        ..splashGone()
        ..firstScreenSettled();
      await pumpEventQueue();

      expect(sender.sent, isEmpty);
    });
  });
}

class _ReportSender implements ClientReportSender {
  final sent = <Map<String, Object?>>[];

  @override
  Future<void> send(Map<String, Object?> payload) async => sent.add(payload);
}
