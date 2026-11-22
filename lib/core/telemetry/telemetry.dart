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
  questionAnswered('question_answered'),

  // Where do students stop in the study loop? Added with the load speed and
  // telemetry spec (2026-11-07). Parameters are the exam id, the kind of
  // session or reading origin, and an item count, never anything a student
  // wrote or scored. Mocks already have their own events above.
  studySessionStart('study_session_start'),
  studySessionFinish('study_session_finish'),
  lessonOpen('lesson_open'),
  lessonFinish('lesson_finish'),
  proView('pro_view'),

  // Where do students stop, and what do they open first? Added with the usage
  // telemetry step (2026-11-14). One property, `screen`, a name from the
  // closed set in `screen_ids.dart`, never an address or anything typed. The
  // wire name avoids `screen_view`, which the analytics provider reserves.
  screenViewed('pantas_screen_view');

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

/// The longest identifier a property may carry: the analytics provider's
/// limit on an event parameter value (100 characters). The old limit, 64, had
/// no source; prod question ids run past it, and on Nov 22 2026 every answer to
/// those 261 questions failed to save because this check threw.
const kMaxPropertyIdentifierLength = 100;

final _keyPattern = RegExp(r'^[a-z][a-z0-9_]*$');
final _identifierPattern =
    RegExp('^[a-zA-Z0-9_-]{1,$kMaxPropertyIdentifierLength}\$');

/// Why a property may not be sent, or null when it may.
String? _propertyProblem(String key, Object value) {
  if (!_keyPattern.hasMatch(key) || _forbiddenKeys.contains(key)) {
    return 'keys must be permitted snake_case identifiers';
  }
  if (value is int || value is bool) return null;
  if (value is String) {
    return _identifierPattern.hasMatch(value)
        ? null
        : 'string values must be short identifiers, never free text';
  }
  return 'values must be int, bool or a short identifier';
}

/// A property value must be an int, a bool, or a short identifier drawn from a
/// closed set or identifier pattern. Throws [ArgumentError] otherwise.
///
/// For tests and code review only. The app sends events through
/// [allowedProperties], which drops a bad property instead of throwing, so
/// analytics can never stop the action that logged it.
///
/// Item analytics properties (`question_id`, `is_correct`, `chosen_label`,
/// `origin`) describe the question rather than the person and are permitted.
///
/// **Still forbidden:**
/// - Any question or answer text
/// - A student's name, email or any free text
/// - Any aggregate score for a student, their accuracy, their streak, or rank
void assertPropertiesAllowed(Map<String, Object> properties) {
  for (final entry in properties.entries) {
    final problem = _propertyProblem(entry.key, entry.value);
    if (problem != null) {
      throw ArgumentError.value(entry.key, 'properties', problem);
    }
  }
}

/// The properties that may be sent, in order. Each one that may not is left
/// out and its key handed to [onDropped]; the value is never passed on, since
/// it may be free text.
Map<String, Object> allowedProperties(
  Map<String, Object> properties, {
  void Function(String key)? onDropped,
}) {
  final allowed = <String, Object>{};
  for (final entry in properties.entries) {
    if (_propertyProblem(entry.key, entry.value) == null) {
      allowed[entry.key] = entry.value;
    } else {
      onDropped?.call(entry.key);
    }
  }
  return allowed;
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
