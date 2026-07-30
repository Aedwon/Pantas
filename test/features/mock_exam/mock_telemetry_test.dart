import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/features/mock_exam/application/mock_session_controller.dart';

void main() {
  test(
    'MockSessionController emits mockStarted on creation and '
    'mockAbandoned on strict background exceeded',
    () {
      final sink = RecordingTelemetrySink();

      final controller = MockSessionController.initial(
        attemptId: 'att-1',
        durationSeconds: 3600,
        questionIds: ['q1', 'q2'],
        strictMode: true,
        telemetry: sink,
      );

      expect(sink.loggedEvents, [TelemetryEvent.mockStarted]);

      controller.strictBackgroundExceeded();

      expect(sink.loggedEvents, [
        TelemetryEvent.mockStarted,
        TelemetryEvent.mockAbandoned,
      ]);
    },
  );

  test('MockSessionController emits mockCompleted on submission', () {
    final sink = RecordingTelemetrySink();

    MockSessionController.initial(
      attemptId: 'att-2',
      durationSeconds: 1,
      questionIds: ['q1'],
      telemetry: sink,
    ).tickTo(1);

    expect(sink.loggedEvents, [
      TelemetryEvent.mockStarted,
      TelemetryEvent.mockCompleted,
    ]);
  });
}

class RecordingTelemetrySink implements Telemetry {
  final loggedEvents = <TelemetryEvent>[];
  final loggedProperties = <Map<String, Object>?>[];

  @override
  Future<void> log(
    TelemetryEvent event, {
    Map<String, Object>? properties,
  }) async {
    loggedEvents.add(event);
    loggedProperties.add(properties);
  }

  @override
  Future<void> recordError(Object error, StackTrace stack) async {}

  @override
  Future<void> setEnabled({required bool enabled}) async {}

  @override
  Future<void> setUserIdentifier(String identifier) async {}
}
