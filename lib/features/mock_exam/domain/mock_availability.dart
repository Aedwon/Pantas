import 'package:meta/meta.dart';
import 'package:pantas/features/mock_exam/domain/mock_attempt.dart';

enum MockAvailabilityState { available, cooldown, inProgress, noBlueprint }

class MockAvailability {
  const MockAvailability({
    required this.state,
    this.cooldownRemaining,
    this.activeAttempt,
    this.serverMockId,
    this.serverExamId,
    this.nextOpensAt,
  });

  const MockAvailability.available()
      : state = MockAvailabilityState.available,
        cooldownRemaining = null,
        activeAttempt = null,
        serverMockId = null,
        serverExamId = null,
        nextOpensAt = null;

  const MockAvailability.cooldown(this.cooldownRemaining)
      : state = MockAvailabilityState.cooldown,
        activeAttempt = null,
        serverMockId = null,
        serverExamId = null,
        nextOpensAt = null;

  const MockAvailability.inProgress(this.activeAttempt)
      : state = MockAvailabilityState.inProgress,
        cooldownRemaining = null,
        serverMockId = null,
        serverExamId = null,
        nextOpensAt = null;

  const MockAvailability.noBlueprint()
      : state = MockAvailabilityState.noBlueprint,
        cooldownRemaining = null,
        activeAttempt = null,
        serverMockId = null,
        serverExamId = null,
        nextOpensAt = null;

  final String? serverMockId;
  final String? serverExamId;
  final DateTime? nextOpensAt;
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
