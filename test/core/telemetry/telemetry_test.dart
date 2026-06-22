import 'package:cse_cet_reviewer/core/telemetry/telemetry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DisabledTelemetry collects nothing', () {
    test('every method is a no-op and none of them throws', () async {
      const telemetry = DisabledTelemetry();

      await telemetry.log(TelemetryEvent.sessionStarted);
      await telemetry.recordError(StateError('x'), StackTrace.current);
      await telemetry.setEnabled(enabled: true);
    });
  });

  group('event names', () {
    test('every event has a distinct snake_case name', () {
      final names = TelemetryEvent.values.map((e) => e.name).toSet();

      expect(names, hasLength(TelemetryEvent.values.length));
      for (final name in names) {
        expect(
          RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name),
          isTrue,
          reason: '"$name" is not snake_case',
        );
      }
    });

    test('no name exceeds the analytics limit of 40 characters', () {
      for (final event in TelemetryEvent.values) {
        expect(event.name.length, lessThanOrEqualTo(40));
      }
    });

    test('no name collides with a reserved analytics event', () {
      // Firebase rejects these silently, which is the worst failure mode:
      // the call succeeds and the event never appears.
      const reserved = {
        'app_remove',
        'app_update',
        'first_open',
        'in_app_purchase',
        'session_start',
        'user_engagement',
      };

      for (final event in TelemetryEvent.values) {
        expect(reserved.contains(event.name), isFalse);
      }
    });

    test("every event traces to one of the spec's six questions", () {
      // Section 3 of the platform foundations spec. An event answering no
      // question on that list does not get added.
      expect(TelemetryEvent.values, hasLength(11));
    });
  });

  group('properties are whitelisted, in code and not by convention', () {
    test('an int, a bool and an identifier string are accepted', () {
      expect(
        () => assertPropertiesAllowed({
          'count': 3,
          'is_first': true,
          'origin': 'today_session',
        }),
        returnsNormally,
      );
    });

    test('free text is rejected', () {
      // A question stem, an answer or anything a student typed.
      expect(
        () => assertPropertiesAllowed({
          'stem': 'What is the capital of the Philippines?',
        }),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('a value that is neither int, bool nor identifier is rejected', () {
      expect(
        () => assertPropertiesAllowed({'score': 12.5}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('an email is rejected', () {
      expect(
        () => assertPropertiesAllowed({'who': 'aerol@example.com'}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('a key that is not snake_case is rejected', () {
      expect(
        () => assertPropertiesAllowed({'Origin': 1}),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
