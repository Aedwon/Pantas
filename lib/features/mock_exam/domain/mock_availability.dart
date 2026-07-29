import 'package:cse_cet_reviewer/features/mock_exam/domain/mock_attempt.dart';
import 'package:meta/meta.dart';

enum MockAvailabilityState { available, cooldown, inProgress, noBlueprint }

class MockAvailability {
  const MockAvailability({
    required this.state,
    this.cooldownRemaining,
    this.activeAttempt,
  });

  const MockAvailability.available()
      : state = MockAvailabilityState.available,
        cooldownRemaining = null,
        activeAttempt = null;

  const MockAvailability.cooldown(this.cooldownRemaining)
      : state = MockAvailabilityState.cooldown,
        activeAttempt = null;

  const MockAvailability.inProgress(this.activeAttempt)
      : state = MockAvailabilityState.inProgress,
        cooldownRemaining = null;

  const MockAvailability.noBlueprint()
      : state = MockAvailabilityState.noBlueprint,
        cooldownRemaining = null,
        activeAttempt = null;

  final MockAvailabilityState state;
  final Duration? cooldownRemaining;
  final MockAttempt? activeAttempt;
}

@immutable
class MockAvailabilityRequest {
  const MockAvailabilityRequest({
    required this.userId,
    required this.examId,
  });

  final String userId;
  final String examId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MockAvailabilityRequest &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          examId == other.examId;

  @override
  int get hashCode => Object.hash(userId, examId);
}

class MockEntitlementSnapshot {
  const MockEntitlementSnapshot({required this.proIsActive});

  final bool proIsActive;
}
