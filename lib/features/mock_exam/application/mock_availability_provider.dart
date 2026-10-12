import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/mock_exam/data/mock_attempt_repo.dart';
import 'package:pantas/features/mock_exam/domain/mock_availability.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';

final mockAttemptRepoProvider = Provider<MockAttemptRepo>(
  (ref) => MockAttemptRepo(ref.watch(appDatabaseProvider)),
);

final mockEntitlementProvider = Provider<MockEntitlementSnapshot>(
  (ref) => const MockEntitlementSnapshot(proIsActive: false),
);

final mockAvailabilityClockProvider = Provider<DateTime Function()>(
  (ref) => () => DateTime.now().toUtc(),
);

final mockAvailabilityProvider =
    FutureProvider.family<MockAvailability, MockAvailabilityRequest>(
  (ref, request) async {
    final repo = ref.watch(mockAttemptRepoProvider);
    final active = await repo.findInProgress(request.userId);
    if (active != null) return MockAvailability.inProgress(active);

    final blueprintRepo = ref.watch(mockBlueprintRepoProvider);
    final blueprints = await blueprintRepo.byExam(request.examId);
    if (blueprints.isEmpty) return const MockAvailability.noBlueprint();

    final entitlement = ref.watch(mockEntitlementProvider);
    if (entitlement.proIsActive) return const MockAvailability.available();

    final cooldownAttempt = await repo.lastCooldownAttempt(
      request.userId,
      request.examId,
    );
    final submittedAt = cooldownAttempt?.submittedAt;
    if (submittedAt == null) return const MockAvailability.available();

    final now = ref.watch(mockAvailabilityClockProvider).call();
    final availableAt = const Entitlement.free()
        .mockLimit(
          request.examId,
          at: now,
          lastMockAt: submittedAt,
        )
        .nextMockOpensAt!;
    if (!now.isBefore(availableAt)) return const MockAvailability.available();

    return MockAvailability.cooldown(availableAt.difference(now));
  },
);
