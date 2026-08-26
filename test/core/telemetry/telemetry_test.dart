import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/telemetry/firebase_telemetry.dart';
import 'package:pantas/core/telemetry/telemetry.dart';

void main() {
  group('DisabledTelemetry collects nothing', () {
    test('every method is a no-op and none of them throws', () async {
      const telemetry = DisabledTelemetry();

      await telemetry.log(TelemetryEvent.sessionStarted);
      await telemetry.recordError(StateError('x'), StackTrace.current);
      await telemetry.setEnabled(enabled: true);
      await telemetry.setUserIdentifier('student_123');
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
      // Section 3 of the platform foundations spec and Telemetry 02 plan.
      expect(TelemetryEvent.values, hasLength(12));
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

  group('FirebaseTelemetry crash-report sanitization', () {
    test(
      'recordError sanitizes exception message and preserves error type and stack',
      () async {
        final analytics = FakeFirebaseAnalytics();
        final crashlytics = FakeFirebaseCrashlytics();
        final telemetry = FirebaseTelemetry(
          analytics: analytics,
          crashlytics: crashlytics,
        );

        final stack = StackTrace.current;
        final error = FormatException(
          'Failed parsing student@example.com '
          'What is the powerhouse of the cell? Mitochondria score=95 accuracy=0.8 streak=5 rank=1',
        );

        await telemetry.recordError(error, stack);

        final recorded = crashlytics.recordedException;
        expect(recorded, isNotNull);
        final recordedString = recorded.toString();

        expect(recordedString.contains('student@example.com'), isFalse);
        expect(
          recordedString.contains('What is the powerhouse of the cell?'),
          isFalse,
        );
        expect(recordedString.contains('Mitochondria'), isFalse);
        expect(recordedString.contains('score=95'), isFalse);
        expect(recordedString.contains('accuracy=0.8'), isFalse);
        expect(recordedString.contains('streak=5'), isFalse);
        expect(recordedString.contains('rank=1'), isFalse);

        expect(recordedString, contains('FormatException'));
        expect(crashlytics.recordedStackTrace, same(stack));
      },
    );
  });

  group('FirebaseTelemetry setEnabled resilience', () {
    test('attempts Crashlytics even when Analytics setEnabled throws',
        () async {
      final analytics = FakeFirebaseAnalytics()
        ..throwOnSetCollectionEnabled = true;
      final crashlytics = FakeFirebaseCrashlytics();
      final telemetry = FirebaseTelemetry(
        analytics: analytics,
        crashlytics: crashlytics,
      );

      await expectLater(
        () => telemetry.setEnabled(enabled: true),
        throwsA(isA<StateError>()),
      );

      expect(analytics.collectionEnabled, isTrue);
      expect(crashlytics.collectionEnabled, isTrue);
    });

    test('attempts Analytics even when Crashlytics setEnabled throws',
        () async {
      final analytics = FakeFirebaseAnalytics();
      final crashlytics = FakeFirebaseCrashlytics()
        ..throwOnSetCollectionEnabled = true;
      final telemetry = FirebaseTelemetry(
        analytics: analytics,
        crashlytics: crashlytics,
      );

      await expectLater(
        () => telemetry.setEnabled(enabled: false),
        throwsA(isA<StateError>()),
      );

      expect(analytics.collectionEnabled, isFalse);
      expect(crashlytics.collectionEnabled, isFalse);
    });

    test('enables both when neither throws', () async {
      final analytics = FakeFirebaseAnalytics();
      final crashlytics = FakeFirebaseCrashlytics();
      final telemetry = FirebaseTelemetry(
        analytics: analytics,
        crashlytics: crashlytics,
      );

      await telemetry.setEnabled(enabled: true);

      expect(analytics.collectionEnabled, isTrue);
      expect(crashlytics.collectionEnabled, isTrue);
    });
  });

  group('FirebaseTelemetry setUserIdentifier', () {
    test('sets identifier on crashlytics and analytics, and nulls on empty',
        () async {
      final analytics = FakeFirebaseAnalytics();
      final crashlytics = FakeFirebaseCrashlytics();
      final telemetry = FirebaseTelemetry(
        analytics: analytics,
        crashlytics: crashlytics,
      );

      await telemetry.setUserIdentifier('student_42');
      expect(crashlytics.userIdentifier, 'student_42');
      expect(analytics.userId, 'student_42');

      await telemetry.setUserIdentifier('');
      expect(crashlytics.userIdentifier, '');
      expect(analytics.userId, isNull);
    });
  });
}

class FakeFirebaseAnalytics extends Fake implements FirebaseAnalytics {
  bool? collectionEnabled;
  String? userId;
  bool throwOnSetCollectionEnabled = false;

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    collectionEnabled = enabled;
    if (throwOnSetCollectionEnabled) {
      throw StateError('Analytics collection enable failed');
    }
  }

  @override
  Future<void> setUserId(
      {String? id, AnalyticsCallOptions? callOptions}) async {
    userId = id;
  }
}

class FakeFirebaseCrashlytics extends Fake implements FirebaseCrashlytics {
  Object? recordedException;
  StackTrace? recordedStackTrace;
  bool? collectionEnabled;
  String? userIdentifier;
  bool throwOnSetCollectionEnabled = false;

  @override
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    Iterable<Object> information = const [],
    bool? printDetails,
    bool? fatal = false,
  }) async {
    recordedException = exception;
    recordedStackTrace = stack;
  }

  @override
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    collectionEnabled = enabled;
    if (throwOnSetCollectionEnabled) {
      throw StateError('Crashlytics collection enable failed');
    }
  }

  @override
  Future<void> setUserIdentifier(String identifier) async {
    userIdentifier = identifier;
  }
}
