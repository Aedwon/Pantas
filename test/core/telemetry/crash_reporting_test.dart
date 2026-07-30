import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/auth/auth.dart';
import 'package:pantas/core/telemetry/crash_reporting.dart';
import 'package:pantas/core/telemetry/telemetry.dart';

void main() {
  test('CrashReporter clears user id for signedOut', () async {
    final sink = RecordingTelemetrySink();
    final reporter = CrashReporter(sink);

    await reporter.applyAuthState(const AuthState.signedOut());

    expect(sink.userIds, ['']);
  });

  test('CrashReporter sets anonymous uid and named uid without email',
      () async {
    final sink = RecordingTelemetrySink();
    final reporter = CrashReporter(sink);

    await reporter.applyAuthState(const AuthState.anonymous(uid: 'anon-1'));
    await reporter.applyAuthState(
      const AuthState.signedIn(
        user: AuthUser(
          uid: 'user-1',
          email: 'reader@example.com',
          displayName: 'Reader',
        ),
      ),
    );

    expect(sink.userIds, ['anon-1', 'user-1']);
  });

  test('DisabledTelemetry handles setUserIdentifier without error', () async {
    const telemetry = DisabledTelemetry();
    await telemetry.setUserIdentifier('user-1');
  });

  test('crashReporterProvider is created and listens to telemetry', () {
    final container = ProviderContainer(
      overrides: [
        telemetrySinkProvider.overrideWithValue(RecordingTelemetrySink()),
      ],
    );
    addTearDown(container.dispose);

    final reporter = container.read(crashReporterProvider);
    expect(reporter, isA<CrashReporter>());
  });
}

class RecordingTelemetrySink implements Telemetry {
  final userIds = <String>[];
  final loggedEvents = <TelemetryEvent>[];
  final loggedProperties = <Map<String, Object>?>[];

  @override
  Future<void> setUserIdentifier(String identifier) async {
    userIds.add(identifier);
  }

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
}
