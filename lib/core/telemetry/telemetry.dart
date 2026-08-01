import 'package:pantas/core/telemetry/crash_reporting.dart';

/// The six questions this app needs answered at launch, and nothing beyond
/// them. Section 3 of
/// `docs/superpowers/specs/2026-08-03-platform-foundations-design.md`.
///
/// Analytics exists to answer questions that were written down first. Without
/// that rule it becomes a landfill of events nobody reads, and it costs a
/// privacy disclosure to keep. **An event that answers no question on that
/// list does not get added here.**
enum TelemetryEvent {
  // Do students finish onboarding?
  onboardingStepReached('onboarding_step_reached'),
  onboardingCompleted('onboarding_completed'),

  // Do they come back?
  sessionStarted('session_started'),

  // Does anyone reach the paywall?
  paywallShown('paywall_shown'),

  // Does anyone buy?
  purchaseStarted('purchase_started'),
  purchaseCompleted('purchase_completed'),
  purchaseFailed('purchase_failed'),

  // Which surfaces are dead?
  tabOpened('tab_opened'),

  // Does the mock work at all?
  mockStarted('mock_started'),
  mockCompleted('mock_completed'),
  mockAbandoned('mock_abandoned'),

  // How do questions perform?
  questionAnswered('question_answered');

  const TelemetryEvent(this.name);

  /// The wire name. Snake case, under 40 characters, and never one of the
  /// analytics provider's reserved names, which are rejected silently.
  final String name;
}

const _forbiddenKeys = {
  'score',
  'accuracy',
  'streak',
  'rank',
  'name',
  'email',
  'stem',
  'text',
  'answer',
};

/// A property value must be an int, a bool, or a short identifier drawn from a
/// closed set or identifier pattern. Throws [ArgumentError] otherwise.
///
/// Item analytics properties (`question_id`, `is_correct`, `chosen_label`,
/// `origin`) describe the question rather than the person and are permitted.
///
/// **Still forbidden and enforced by a throw:**
/// - Any question or answer text
/// - A student's name, email or any free text
/// - Any aggregate score for a student, their accuracy, their streak, or rank
void assertPropertiesAllowed(Map<String, Object> properties) {
  final keyPattern = RegExp(r'^[a-z][a-z0-9_]*$');
  final identifierPattern = RegExp(r'^[a-zA-Z0-9_-]{1,64}$');

  for (final entry in properties.entries) {
    if (!keyPattern.hasMatch(entry.key) || _forbiddenKeys.contains(entry.key)) {
      throw ArgumentError.value(
        entry.key,
        'properties',
        'keys must be permitted snake_case identifiers',
      );
    }

    final value = entry.value;
    if (value is int || value is bool) continue;

    if (value is String) {
      if (identifierPattern.hasMatch(value)) continue;
      throw ArgumentError.value(
        entry.key,
        'properties',
        'string values must be short identifiers, never free text',
      );
    }

    throw ArgumentError.value(
      entry.key,
      'properties',
      'values must be int, bool or a short identifier',
    );
  }
}

/// The seam. No feature imports an analytics or crash package directly, which
/// is what keeps the layering check passing and makes the consent gate
/// testable with a fake.
abstract interface class Telemetry implements CrashReportingSink {
  Future<void> log(TelemetryEvent event, {Map<String, Object>? properties});
  Future<void> recordError(Object error, StackTrace stack);
  Future<void> setEnabled({required bool enabled});
}

/// Collects nothing. The default until the student has answered the switch,
/// and the implementation in use whenever they have answered it with no.
class DisabledTelemetry implements Telemetry {
  const DisabledTelemetry();

  @override
  Future<void> log(
    TelemetryEvent event, {
    Map<String, Object>? properties,
  }) async {}

  @override
  Future<void> recordError(Object error, StackTrace stack) async {}

  @override
  Future<void> setEnabled({required bool enabled}) async {}

  @override
  Future<void> setUserIdentifier(String identifier) async {}
}
